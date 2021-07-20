# frozen_string_literal: true

module RuboCop
  module Cop
    module Minitest
      # This cop enforces the test to use `assert_includes`
      # instead of using `assert(object.in?(collection))`.
      #
      # @example
      #   # bad
      #   assert(object.in?(collection))
      #   assert(object.in?(collection), 'message')
      #
      #   # good
      #   assert_includes(collection, object)
      #   assert_includes(collection, object, 'message')
      #
      class AssertIn < Base
        extend MinitestCopRule

        define_rule :assert, target_method: :in?, preferred_method: :assert_includes, inverse: true
      end
    end
  end
end
