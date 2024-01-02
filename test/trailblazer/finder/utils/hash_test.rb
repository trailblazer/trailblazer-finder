# frozen_string_literal: true

require 'test_helper'

module Trailblazer
  class Finder
    module Utils
      class HashTest < Minitest::Test
        def setup
          @hash = [{ id: 1, value: 'Test 1' }, { id: 2, value: 'Test 2' }, { id: 3, value: '' },
                   { id: 4, value: 'Test 4' }]
        end

        def test_deep_locate
          expected_result = [{ id: 2, value: 'Test 2' }]
          actual_result = Hash.deep_locate(->(k, v, _) { k == :value && v.to_s == 'Test 2' && !v.nil? }, @hash)
          assert_equal expected_result, actual_result
        end

        def test_returns_empty_when_nothing_found
          expected_result = []
          actual_result = Hash.deep_locate(:muff, foo: 'bar')
          assert_equal expected_result, actual_result
        end
      end
    end
  end
end
