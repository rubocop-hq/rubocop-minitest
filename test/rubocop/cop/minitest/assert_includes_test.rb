# frozen_string_literal: true

require 'test_helper'

class AssertIncludesTest < Minitest::Test
  def setup
    @cop = RuboCop::Cop::Minitest::AssertIncludes.new
  end

  def test_registers_offense_when_using_assert_with_includes
    assert_offense(<<~RUBY, @cop)
      class FooTest < Minitest::Test
        def test_do_something
          assert(collection.includes?(actual))
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_includes(collection, actual)` over `assert(collection.includes?(actual))`.
        end
      end
    RUBY

    assert_correction(<<~RUBY, @cop)
      class FooTest < Minitest::Test
        def test_do_something
          assert_includes(collection, actual)
        end
      end
    RUBY
  end

  def test_registers_offense_when_using_assert_with_includes_and_message
    assert_offense(<<~RUBY, @cop)
      class FooTest < Minitest::Test
        def test_do_something
          assert(collection.includes?(actual), 'the message')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_includes(collection, actual, 'the message')` over `assert(collection.includes?(actual), 'the message')`.
        end
      end
    RUBY

    assert_correction(<<~RUBY, @cop)
      class FooTest < Minitest::Test
        def test_do_something
          assert_includes(collection, actual, 'the message')
        end
      end
    RUBY
  end

  def test_registers_offense_when_using_assert_with_includes_and_variable_message
    assert_offense(<<~RUBY, @cop)
      class FooTest < Minitest::Test
        def test_do_something
          message = 'the message'
          assert(collection.includes?(actual), message)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_includes(collection, actual, message)` over `assert(collection.includes?(actual), message)`.
        end
      end
    RUBY

    assert_correction(<<~RUBY, @cop)
      class FooTest < Minitest::Test
        def test_do_something
          message = 'the message'
          assert_includes(collection, actual, message)
        end
      end
    RUBY
  end

  def test_registers_offense_when_using_assert_with_includes_and_constant_message
    assert_offense(<<~RUBY, @cop)
      class FooTest < Minitest::Test
        MESSAGE = 'the message'

        def test_do_something
          assert(collection.includes?(actual), MESSAGE)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_includes(collection, actual, MESSAGE)` over `assert(collection.includes?(actual), MESSAGE)`.
        end
      end
    RUBY

    assert_correction(<<~RUBY, @cop)
      class FooTest < Minitest::Test
        MESSAGE = 'the message'

        def test_do_something
          assert_includes(collection, actual, MESSAGE)
        end
      end
    RUBY
  end

  def test_does_not_register_offense_when_using_assert_nil_method
    assert_no_offenses(<<~RUBY, @cop)
      class FooTest < Minitest::Test
        def test_do_something
          assert_includes(collection, actual)
        end
      end
    RUBY
  end
end