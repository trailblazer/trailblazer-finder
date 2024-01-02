# frozen_string_literal: true

require 'test_helper'

module Trailblazer
  class Finder
    module Utils
      class SplitterTest < Minitest::Test
        def test_initialize
          splitter = Splitter.new 'attribute_eq', 'value'
          assert_equal 'attribute_eq', splitter.key
          assert_equal 'value', splitter.value
        end

        def test_split_key_exists
          splitter = Splitter.new 'attribute_eq', 'value'
          assert_equal false, splitter.split_key('random')
          assert_equal true, splitter.split_key('eq')
        end

        def test_field_value_when_split_key_exists
          splitter = Splitter.new 'attribute_eq', 'value'
          splitter.split_key('eq')
          assert_equal 'attribute', splitter.field
        end

        def test_predicate_value_when_split_key_exists
          splitter = Splitter.new 'attribute_eq', 'value'
          splitter.split_key('eq')
          assert_equal :eq, splitter.predicate
        end
      end
    end
  end
end
