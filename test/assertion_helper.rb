# frozen_string_literal: true

# Laziness copied from rubocop source code
require 'rubocop/rspec/expect_offense'

module AssertionHelper
  private

  def setup
    cop_name = self.class.to_s.sub(/Test\z/, '')

    @cop = RuboCop::Cop::Minitest.const_get(cop_name).new
  end

  def assert_no_offenses(source, file = nil)
    setup_assertion

    inspect_source(source, @cop, file)

    expected_annotations = RuboCop::RSpec::ExpectOffense::AnnotatedSource.parse(source)
    actual_annotations = expected_annotations.with_offense_annotations(@cop.offenses)

    assert_equal(source, actual_annotations.to_s)
  end

  def assert_offense(source, file = nil)
    setup_assertion

    @cop.instance_variable_get(:@options)[:auto_correct] = true

    expected_annotations = RuboCop::RSpec::ExpectOffense::AnnotatedSource.parse(source)
    if expected_annotations.plain_source == source
      raise 'Use `assert_no_offenses` to assert that no offenses are found'
    end

    @processed_source = inspect_source(expected_annotations.plain_source, @cop, file)

    actual_annotations = expected_annotations.with_offense_annotations(@cop.offenses)

    assert_equal(expected_annotations.to_s, actual_annotations.to_s)
  end

  def assert_correction(correction)
    raise '`assert_correction` must follow `assert_offense`' unless @processed_source

    corrector = RuboCop::Cop::Corrector.new(
      @processed_source.buffer, @cop.corrections
    )
    new_source = corrector.rewrite

    assert_equal(correction, new_source)
  end

  def setup_assertion
    RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
    RuboCop::Formatter::DisabledConfigFormatter.detected_styles = {}
  end

  def inspect_source(source, cop, file = nil)
    processed_source = parse_source!(source, file)

    investigate(cop, processed_source)

    processed_source
  end

  def investigate(cop, processed_source)
    forces = RuboCop::Cop::Force.all.each_with_object([]) do |klass, instances|
      next unless cop.join_force?(klass)

      instances << klass.new([cop])
    end

    commissioner = RuboCop::Cop::Commissioner.new([cop], forces, raise_error: true)
    commissioner.investigate(processed_source)
    commissioner
  end

  def parse_source!(source, file = nil)
    if file&.respond_to?(:write)
      file.write(source)
      file.rewind
      file = file.path
    end
    processed_source = RuboCop::ProcessedSource.new(source, ruby_version, file)
    raise 'Error parsing example code' unless processed_source.valid_syntax?

    processed_source
  end

  def ruby_version
    2.3
  end
end
