# frozen_string_literal: true

require 'test_helper'

class ProjectTest < Minitest::Test
  def setup
    path = File.join(File.dirname(__dir__), 'CHANGELOG.md')

    @changelog = File.read(path)
    @lines = @changelog.each_line
    @entries = @lines.grep(/^\*/).map(&:chomp)

    @issues = @entries.map do |entry|
      entry.match(/\[(?<number>[#\d]+)\]\((?<url>[^\)]+)\)/)
    end.compact

    @bodies = @entries.map do |entry|
      entry.gsub(/`[^`]+`/, '``').sub(
        /^\*\s*(?:\[.+?\):\s*)?/, ''
      ).sub(
        /\s*\([^\)]+\)$/, ''
      )
    end
  end

  def test_changelog_has_newline_at_end_of_file
    assert(@changelog.end_with?("\n"))
  end

  def test_changelog_has_either_entries_headers_or_empty_lines
    non_reference_lines = @lines.take_while { |line| !line.start_with?('[@') }

    non_reference_lines.each do |line|
      assert_match(/^(\*|#|$)/, line)
    end
  end

  def test_changelog_has_link_definitions_for_all_implicit_links
    implicit_link_names = @changelog.scan(/\[([^\]]+)\]\[\]/).flatten.uniq
    implicit_link_names.each do |name|
      assert_includes(
        @changelog, "[#{name}]: http",
        "CHANGELOG.md is missing a link for #{name}. " \
        'Please add this link to the bottom of the file.'
      )
    end
  end

  def test_entry_has_a_whitespace_between_the_asterisk_and_the_body
    @entries.each do |entry|
      assert_match(/^\* \S/, entry)
    end
  end

  def test_entry_has_a_link_to_the_contributors_at_the_end
    @entries.each do |entry|
      assert_match(/\(\[@\S+\]\[\](?:, \[@\S+\]\[\])*\)$/, entry)
    end
  end

  def test_entry_has_an_issue_number_prefixed_with_sharp
    @issues.each do |issue|
      assert_match(/^#\d+$/, issue[:number])
    end
  end

  def test_entry_has_a_valid_url
    @issues.each do |issue|
      number = issue[:number].gsub(/\D/, '')
      pattern =
        %r{^https://github\.com/rubocop-hq/rubocop-minitest/(?:issues|pull)/#{number}$}
      assert_match(pattern, issue[:url])
    end
  end

  def test_entry_has_a_colon_and_a_whitespace_at_the_end
    entries_including_issue_links = @entries.select do |entry|
      entry.match(/^\*\s*\[/)
    end

    entries_including_issue_links.each do |link|
      assert_includes(link, '): ')
    end
  end

  def test_entry_has_a_unique_contributor_name
    contributor_names = @lines.grep(/\A\[@/).map(&:chomp)

    assert_equal(contributor_names.size, contributor_names.uniq.size)
  end

  def test_body_does_not_start_with_a_lower_case
    @bodies.each do |body|
      refute_match(/^[a-z]/, body)
    end
  end

  def test_body_ends_with_a_punctuation
    @bodies.each do |body|
      assert_match(/[\.\!]$/, body)
    end
  end
end
