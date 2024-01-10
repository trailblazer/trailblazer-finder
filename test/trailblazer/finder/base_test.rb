# frozen_string_literal: true

require 'test_helper'

module Trailblazer
  class Finder::BaseTest < Minitest::TrailblazerTest
    attr_reader :finder_class

    def setup
      @finder_class = define_finder_class do
        entity { [] }

        filter_by :value do |entity, _attribute, value|
          entity.select { |v| v == value }
        end
      end
    end

    def define_finder_class(&block)
      Class.new(Trailblazer::Finder) do
        class_eval(&block)
      end
    end

    def new_finder_class(default_entity, filter = {}, &block)
      finder_class = define_finder_class do
        entity { default_entity }

        if block.nil?
          filter_by :value do |entity, _attribute, value|
            entity.select { |v| v == value }
          end
        else
          class_eval(&block)
        end
      end

      finder_class.new params: filter
    end

    def test_can_overwrite_initialize
      finder = new_finder_class([]) do
        attr_reader :initialized
        alias_method :initialized?, :initialized

        def initialize(filter = {})
          @initialized = true
          super(filter)
        end
      end

      assert_predicate finder, :initialized?
    end

    def test_can_have_multiple_subclasses
      finder1 = new_finder_class([1, 2, 3], { filter: 1 }) do
        filter_by :filter do |entity, _attribute, value|
          entity.select { |v| v == value }
        end
      end

      finder2 = new_finder_class([1, 2, 3], { other_filter: 1 }) do
        filter_by :other_filter do |entity, _attribute, value|
          entity.reject { |v| v == value }
        end
      end

      refute_equal finder1.result, finder2.result
    end

    def test_result_returns_only_filtered_finder_results
      finder = new_finder_class([1, 2, 3], { value: 1 })

      assert_equal finder.result, [1]
    end

    def test_can_apply_several_filters
      values = [1, 2, 3, 4, 5, 6, 7]
      finder = new_finder_class(values, { bigger_than: 3, odd: true }) do
        filter_by :bigger_than do |entity, _attribute, value|
          entity.select { |v| v > value }
        end

        filter_by :odd do |entity, _attribute, value|
          entity.select(&:odd?) if value
        end
      end

      assert_equal finder.result, [5, 7]
    end

    def test_ignore_invalid_filters
      finder = new_finder_class([1, 2, 3], { invalid: 'filter_by' })

      assert_equal finder.result, [1, 2, 3]
    end

    def test_can_be_overwritten_by_overwriting_fetch_result
      finder = new_finder_class([1, 2, 3], { value: 1 }) do
        filter_by :value do |entity, _attribute, value|
          entity.select { |v| v == value }
        end

        def fetch_result
          super.map { |v| "~#{v}~" }
        end
      end

      assert_equal finder.result, ['~1~']
    end

    def test_applies_to_default_filters
      finder = new_finder_class([1, 2, 3], { value: 1 }) do
        filter_by :value do |entity, _attribute, value|
          entity.select { |v| v == value }
        end
      end

      assert_equal finder.result, [1]
    end

    def test_has_no_result
      finder = new_finder_class([1, 2, 3], { value: 4 }) do
        filter_by :value do |entity, _attribute, value|
          entity.select { |v| v == value }
        end
      end

      refute_predicate finder, :result?
    end

    def test_can_apply_several_filters_and_have_a_correct_count
      values = [1, 2, 3, 4, 5, 6, 7]
      finder = new_finder_class(values, { bigger_than: 3, odd: true }) do
        filter_by :bigger_than do |entity, _attribute, value|
          entity.select { |v| v > value }
        end

        filter_by :odd do |entity, _attribute, value|
          entity.select(&:odd?) if value
        end
      end

      assert_equal finder.count, 2
    end
  end
end
