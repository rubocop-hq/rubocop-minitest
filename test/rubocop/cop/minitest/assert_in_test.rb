# frozen_string_literal: true

require 'test_helper'

class AssertInTest < Minitest::Test
  def test_registers_offense_when_using_assert_with_in
    assert_offense(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          assert(object.in?(collection))
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_includes(collection, object)` over `assert(object.in?(collection))`.
        end
      end
    RUBY

    assert_correction(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          assert_includes(collection, object)
        end
      end
    RUBY
  end

  def test_registers_offense_when_using_assert_with_in_and_message
    assert_offense(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          assert(object.in?(collection), 'message')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_includes(collection, object, 'message')` over `assert(object.in?(collection), 'message')`.
        end
      end
    RUBY

    assert_correction(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          assert_includes(collection, object, 'message')
        end
      end
    RUBY
  end

  def test_registers_offense_when_using_assert_with_in_and_heredoc_message
    assert_offense(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          assert(object.in?(collection), <<~MESSAGE
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_includes(collection, object, <<~MESSAGE)` over `assert(object.in?(collection), <<~MESSAGE)`.
            message
          MESSAGE
          )
        end
      end
    RUBY

    assert_correction(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          assert_includes(collection, object, <<~MESSAGE
            message
          MESSAGE
          )
        end
      end
    RUBY
  end

  def test_registers_offense_when_using_assert_with_in_and_redundant_parentheses
    assert_offense(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          assert((object.in?(collection)))
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_includes(collection, object)` over `assert(object.in?(collection))`.
        end
      end
    RUBY

    assert_correction(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          assert_includes((collection, object))
        end
      end
    RUBY
  end

  def test_does_not_register_offense_when_using_assert_includes_method
    assert_no_offenses(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          assert_includes(collection, object)
        end
      end
    RUBY
  end

  def test_does_not_registers_offense_when_using_assert_with_non_in_method
    assert_no_offenses(<<~RUBY)
      class FooTest < Minitest::Test
        def test_do_something
          assert(collection.end_with?(string))
        end
      end
    RUBY
  end
end
