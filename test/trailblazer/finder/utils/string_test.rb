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
