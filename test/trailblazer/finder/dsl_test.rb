# frozen_string_literal: true

require 'test_helper'
require 'support/operations'

module Trailblazer
  class Finder
    class DslTest < Minitest::TrailblazerSpec
      def define_finder_class(&block)
        Class.new(Trailblazer::Finder) do
          class_eval(&block)
        end
      end

      def finder_class(default_entity = [], &block)
        define_finder_class do
          entity { default_entity }

          class_eval(&block) unless block.nil?
        end
      end

      def new_finder(default_entity = [], filter = {}, &block)
        finder_class(default_entity, &block).new params: filter
      end

      describe '#adapters' do
        it 'checks for a valid adapter and returns an error' do
          entity = [{ id: 1, value: 'Test 1' }, { id: 2, value: 'Test 2' }, { id: 3, value: 'Test 3' }]
          finder = new_finder entity, value_eq: 'Test 1' do
            adapter :NonExisting
          end

          # expect(finder.errors).to eq [{adapter: "The specified adapter are invalid"}]
          assert_equal finder.errors, [{ adapter: 'The specified adapter are invalid' }]
        end

        it 'sets the adapter in the config' do
          entity = [{ id: 1, value: 'Test 1' }, { id: 2, value: 'Test 2' }, { id: 3, value: 'Test 3' }]
          finder = new_finder entity, value_eq: 'Test 1' do
            adapter 'ActiveRecord'
            property :value, type: Base
          end

          assert_equal finder.class.config[:adapter], 'ActiveRecord'
        end
      end

      describe '#property' do
        it 'checks for a valid property type and returns an error' do
          entity = [{ id: 1, value: 'Test 1' }, { id: 2, value: 'Test 2' }, { id: 3, value: 'Test 3' }]
          finder = new_finder entity, value_eq: 'Test 1' do
            property :value, type: Base
          end

          assert_equal finder.errors, [{ properties: 'One or more properties are missing a valid type' }]
        end

        it "sets the property and it's type properly in the config" do
          entity = [{ id: 1, value: 'Test 1' }, { id: 2, value: 'Test 2' }, { id: 3, value: 'Test 3' }]
          finder = new_finder entity, value_eq: 'Test 1' do
            property :value, type: Base
          end

          assert_equal finder.class.config[:properties], value: { type: Trailblazer::Finder::Base }
        end
      end

      describe '#paging' do
        it 'sets the paging values' do
          entity = [{ id: 1, value: 'Test 1' }, { id: 2, value: 'Test 2' }, { id: 3, value: 'Test 3' }]
          finder = new_finder entity do
            paging per_page: 2, min_per_page: 1, max_per_page: 5
            property :value, type: Types::String
          end

          assert_equal finder.class.config[:paging][:per_page], 2
          assert_equal finder.class.config[:paging][:min_per_page], 1
          assert_equal finder.class.config[:paging][:max_per_page], 5
        end

        it "does not load paging stuff if paging isn't called in the finder class" do
          entity = [{ id: 1, value: 'Test 1' }, { id: 2, value: 'Test 2' }, { id: 3, value: 'Test 3' }]
          finder = new_finder entity do
            property :value, type: Types::String
          end

          assert_empty finder.class.config[:paging]
        end
      end

      describe '#filter_by' do
        it 'returns an error when supplied with a non symbol' do
          entity = [1, 2, 3]
          finder = new_finder entity, value_test: 'some' do
            filter_by :value_test, with: 'test'
          end

          assert_equal finder.result, errors: [{ filters: 'One or more filters are missing a with method definition' }]
        end

        it 'has a default filter' do
          entity = [{ id: 1, value: 'Test 1' }, { id: 2, value: 'Test 2' }, { id: 3, value: 'Test 3' }]
          finder = new_finder entity, value: 'Test 1' do
            filter_by :value
          end

          assert_equal finder.result.map { |n| n[:value] }, ['Test 1']
        end

        it "has a default filter working when it's nested" do
          entity = [{ id: 1, value: [id: 4, value: 'Test 1'] }, { id: 2, value: 'Test 2' }, { id: 3, value: 'Test 3' }]
          finder = new_finder entity, value: 'Test 1' do
            filter_by :value
          end

          assert_equal finder.result.map { |n| n[:value] }, ['Test 1']
          assert_equal finder.result.map { |n| n[:id] }, [4]
        end

        it 'has another default filter' do
          entity = [{ id: 1, value: 'Test 1' }, { id: 2, value: 'Test 2' }, { id: 3, value: 'Test 3' }]
          finder = new_finder entity, id: 2 do
            filter_by :id
          end

          assert_equal finder.result.map { |n| n[:value] }, ['Test 2']
        end

        it 'returns the entity if nil is returned' do
          entity = [1, 2, 3]
          finder = new_finder entity, value_test: 'some' do
            filter_by :value_test do
              nil
            end
          end

          assert_equal finder.result, entity
        end

        it 'can use methods from the object' do
          finder1 = new_finder [1, 2, 3], filter: 1 do
            filter_by :filter do |entity, attribute, value|
              some_instance_method(entity, attribute, value)
            end

            private

            def some_instance_method(entity, _attribute, _value)
              entity - [2, 3]
            end
          end

          assert_equal finder1.result, [1]
        end

        it 'can dispatch with instance methods' do
          finder = new_finder [1, 2, 3], filter: 1 do
            filter_by :filter, with: :some_instance_method

            private

            def some_instance_method(entity, _attribute, value)
              entity.select { |v| v == value }
            end
          end

          assert_equal finder.result, [1]
        end
      end
    end
  end
end
