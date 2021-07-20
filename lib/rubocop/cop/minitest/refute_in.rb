# frozen_string_literal: true

module RuboCop
  module Cop
    module Minitest
      # This cop enforces the test to use `refute_includes`
      # instead of using `refute(object.in?(collection))`.
      #
      # @example
      #   # bad
      #   refute(object.in?(collection))
      #   refute(object.in?(collection), 'message')
      #
      #   # good
      #   refute_includes(collection, object)
      #   refute_includes(collection, object, 'message')
      #
      class RefuteIn < Base
        extend MinitestCopRule

        define_rule :refute, target_method: :in?, preferred_method: :refute_includes, inverse: true
      end
    end
  end
end
