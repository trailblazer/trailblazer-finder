# frozen_string_literal: true

require 'test_helper'
module Trailblazer
  module Finder::Utils
    class StringTest < Minitest::TrailblazerTest
      def test_blank
        assert String.blank?('')
        assert String.blank?(nil)
        refute String.blank?('what')
        refute String.blank?(1)
      end

      def test_numeric
        refute String.numeric?('')
        refute String.numeric?(nil)
        assert String.numeric?(1)
        assert String.numeric?(0)
        assert String.numeric?(1.00000)
        assert String.numeric?('1')
      end

      def test_date
        assert String.date?('2024-01-01')
        refute String.date?(nil)
        refute String.date?('random')
        refute String.date?(1)
        assert String.date?('2024/01/01')
        assert String.date?('2024.01.01')
        assert String.date?('21-12-2024')
        refute String.date?('0fae2de1-6537-4d36-9cdb-30edf1e37990')
      end

      def test_to_date
        assert_equal String.to_date('28/09/2024'), '2024-09-28'
        assert_equal String.to_date('2024/09/28'), '2024-09-28'
        assert_equal String.to_date('28 september 2024'), '2024-09-28'
        assert_nil String.to_date('third month of this year')
      end

      def test_camelize
        assert_equal String.camelize(:paging), 'Paging'
        assert_equal String.camelize(:some_random_test), 'SomeRandomTest'
      end

      def test_underscore
        assert_equal String.underscore(:veryPopular), 'very_popular'
        assert_equal String.underscore(:VeryPopular), 'very_popular'
        assert_equal String.underscore(:SomethingveryPopularButRandom), 'somethingvery_popular_but_random'
        assert_equal String.underscore('Very Popular'), 'very_popular'
      end
    end
  end
end
