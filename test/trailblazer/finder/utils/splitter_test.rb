# frozen_string_literal: true

require 'test_helper'

module Trailblazer
  module Finder::Utils
    class SplitterTest < Minitest::Test
      def test_initialize
        splitter = Splitter.new 'attribute_eq', 'value'

        assert_equal splitter.key, 'attribute_eq'
        assert_equal splitter.value, 'value'
      end

      def test_split_key_exists
        splitter = Splitter.new 'attribute_eq', 'value'

        refute splitter.split_key('random')
        assert splitter.split_key('eq')
      end

      def test_field_value_when_split_key_exists
        splitter = Splitter.new 'attribute_eq', 'value'
        splitter.split_key('eq')

        assert_equal splitter.field, 'attribute'
      end

      def test_predicate_value_when_split_key_exists
        splitter = Splitter.new 'attribute_eq', 'value'
        splitter.split_key('eq')

        assert_equal splitter.predicate, :eq
      end
    end
  end
end
