# frozen_string_literal: true

require 'test_helper'
module Trailblazer
  class Finder
    module Utils
      class StringTest < Minitest::Test
        def test_blank
          assert_equal true, String.blank?('')
          assert_equal true, String.blank?(nil)
          assert_equal false, String.blank?('what')
          assert_equal false, String.blank?(1)
        end

        def test_numeric
          assert_equal false, String.numeric?('')
          assert_equal false, String.numeric?(nil)
          assert_equal true, String.numeric?(1)
          assert_equal true, String.numeric?(0)
          assert_equal true, String.numeric?(1.00000)
          assert_equal true, String.numeric?('1')
        end

        def test_date
          assert_equal true, String.date?('2024-01-01')
          assert_equal false, String.date?(nil)
          assert_equal false, String.date?('random')
          assert_equal false, String.date?(1)
          assert_equal true, String.date?('2024/01/01')
          assert_equal true, String.date?('2024.01.01')
          assert_equal true, String.date?('21-12-2024')
          assert_equal false, String.date?('0fae2de1-6537-4d36-9cdb-30edf1e37990')
        end

        def test_to_date
          assert_equal '2024-09-28', String.to_date('28/09/2024')
          assert_equal '2024-09-28', String.to_date('2024/09/28')
          assert_equal '2024-09-28', String.to_date('28 september 2024')
          assert_nil String.to_date('third month of this year')
        end

        def test_camelize
          assert_equal 'Paging', String.camelize(:paging)
          assert_equal 'SomeRandomTest', String.camelize(:some_random_test)
        end

        def test_underscore
          assert_equal 'very_popular', String.underscore(:veryPopular)
          assert_equal 'very_popular', String.underscore(:VeryPopular)
          assert_equal 'somethingvery_popular_but_random', String.underscore(:SomethingveryPopularButRandom)
          assert_equal 'very_popular', String.underscore('Very Popular')
        end
      end
    end
  end
end
