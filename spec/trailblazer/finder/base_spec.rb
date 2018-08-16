require 'spec_helper'
puts 'AR is loaded' if Gem.loaded_specs.key?('active_record')
module Trailblazer
  class Finder # rubocop:disable Metrics/ClassLength
    describe Base do
      def define_finder_class(&block)
        Class.new do
          include Finder::Base

          class_eval(&block)
        end
      end

      def finder_class(default_entity_type = [], &block)
        define_finder_class do
          entity_type { default_entity_type }

          if block.nil?
            filter_by :value do |entity_type, value|
              entity_type.select { |v| v == value }
            end
          else
            class_eval(&block)
          end
        end
      end

      def new_finder(default_entity_type = [], filter = {}, &block)
        finder_class(default_entity_type, &block).new filter: filter
      end

      it 'can have its #initialize method overwritten' do
        finder = new_finder do
          attr_reader :initialized

          alias_method :initialized?, :initialized

          def initialize(filter = {})
            @initialized = true
            super filter
          end
        end

        expect(finder).to be_initialized
      end

      it 'can have multiple subclasses' do
        finder1 = new_finder [1, 2, 3], filter: 1 do
          filter_by :filter do |entity_type, value|
            entity_type.select { |v| v == value }
          end
        end

        finder2 = new_finder [1, 2, 3], filter: 1 do
          filter_by :filter, 2 do |entity_type, value|
            entity_type.reject { |v| v == value }
          end
        end

        expect(finder1.results).not_to eq finder2.results
      end

      it 'can be inherited' do
        equality_finder = Class.new(finder_class([1, 2, 3])) do
          filter_by :value do |entity_type, value|
            entity_type.select { |v| v == value }
          end
        end

        inequality_finder = Class.new(finder_class([1, 2, 3])) do
          filter_by :value do |entity_type, value|
            entity_type.select { |v| v > value }
          end
        end

        expect(equality_finder.new(filter: { value: 1 }).results).to eq [1]
        expect(inequality_finder.new(filter: { value: 1 }).results).to eq [2, 3]
      end

      describe 'entity_type' do
        def finder_class
          define_finder_class do
            filter_by :name do
            end
          end
        end

        it 'accepts entity_type as argument' do
          expect(finder_class.new(entity_type: 'entity_type').results).to eq 'entity_type'
        end

        it 'raises an error if no entity_type is provided' do
          expect { finder_class.new }.to raise_error Finder::Error::MissingEntityType
        end

        it 'can overwrite the finder entity_type' do
          finder_class = define_finder_class do
            entity_type { 'entity_type' }
          end

          expect(finder_class.new(entity_type: 'other entity_type').results).to eq 'other entity_type'
        end

        it 'accepts a block in context of finder object' do
          finder_class = define_finder_class do
            entity_type { inner_entity_type }

            attr_reader :inner_entity_type

            def initialize
              @inner_entity_type = 'entity_type'
              super
            end
          end

          expect(finder_class.new.results).to eq 'entity_type'
        end

        it 'passing nil as entity_type in constructor, falls back to default entity_type' do
          finder_class = define_finder_class do
            entity_type { 'entity_type' }
          end

          expect(finder_class.new(entity_type: nil).results).to eq 'entity_type'
        end
      end

      describe 'filter_by' do
        it 'has a default filter' do
          entity_type = [{ id: 1, value: 'Test 1' }, { id: 2, value: 'Test 2' }, { id: 3, value: 'Test 3' }]
          finder = new_finder entity_type, value: 'Test 1' do
            filter_by :value
          end

          expect(finder.results.map { |n| n[:value] }).to eq ['Test 1']
        end

        it 'has a default filter working when it\'s nested' do
          entity_type = [{ id: 1, value: [id: 4, value: 'Test 1'] }, { id: 2, value: 'Test 2' }, { id: 3, value: 'Test 3' }]
          finder = new_finder entity_type, value: 'Test 1' do
            filter_by :value
          end

          expect(finder.results.map { |n| n[:value] }).to eq ['Test 1']
          expect(finder.results.map { |n| n[:id] }).to eq [4]
        end

        it 'has another default filter' do
          entity_type = [{ id: 1, value: 'Test 1' }, { id: 2, value: 'Test 2' }, { id: 3, value: 'Test 3' }]
          finder = new_finder entity_type, id: 2 do
            filter_by :id
          end

          expect(finder.results.map { |n| n[:value] }).to eq ['Test 2']
        end

        it 'returns the entity_type if nil is returned' do
          entity_type = [1, 2, 3]
          finder = new_finder entity_type, value: 'some' do
            filter_by :value do
              nil
            end
          end

          expect(finder.results).to eq entity_type
        end

        it 'can use methods from the object' do
          finder1 = new_finder [1, 2, 3], filter: 1 do
            filter_by :filter do |entity_type, value|
              some_instance_method(entity_type, value)
            end

            private

            def some_instance_method(entity_type, value)
              entity_type.select { |v| v == value }
            end
          end

          expect(finder1.results).to eq [1]
        end

        it 'can dispatch with instance methods' do
          finder = new_finder [1, 2, 3], filter: 1 do
            filter_by :filter, with: :some_instance_method

            private

            def some_instance_method(entity_type, value)
              entity_type.select { |v| v == value }
            end
          end

          expect(finder.results).to eq [1]
        end
      end

      describe 'filter_by attributes' do
        it 'accesses filter values' do
          finder = new_finder [], value: 1
          expect(finder.value).to eq 1
        end

        it 'returns default filter value if filter_by is not specified' do
          finder = new_finder do
            filter_by :value, 1
          end
          expect(finder.value).to eq 1
        end

        it 'does not include invalid filters' do
          finder = new_finder [], invalid: 'option'
          expect { finder.invalid }.to raise_error NoMethodError
        end
      end

      describe '.results' do
        it 'shortcut for creating new finder and immediately returning results' do
          klass = finder_class [1, 2, 3]
          expect(klass.results(filter: { value: 1 })).to eq [1]
        end
      end

      describe '#results' do
        it 'returns only the filtered finder results' do
          finder = new_finder [1, 2, 3], value: 1
          expect(finder.results).to eq [1]
        end

        it 'can apply several filters' do
          values = [1, 2, 3, 4, 5, 6, 7]
          finder = new_finder values, bigger_than: 3, odd: true do
            filter_by :bigger_than do |entity_type, value|
              entity_type.select { |v| v > value }
            end

            filter_by :odd do |entity_type, value|
              entity_type.select(&:odd?) if value
            end
          end

          expect(finder.results).to eq [5, 7]
        end

        it 'ignores invalid filters' do
          finder = new_finder [1, 2, 3], invalid: 'filter_by'
          expect(finder.results).to eq [1, 2, 3]
        end

        it 'can be overwritten by overwriting #fetch_results' do
          finder = new_finder [1, 2, 3], value: 1 do
            filter_by :value do |entity_type, value|
              entity_type.select { |v| v == value }
            end

            def fetch_results
              super.map { |v| "~#{v}~" }
            end
          end

          expect(finder.results).to eq ['~1~']
        end

        it 'applies to default filters' do
          finder = new_finder [1, 2, 3] do
            filter_by :value, 1 do |entity_type, value|
              entity_type.select { |v| v == value }
            end
          end
          expect(finder.results).to eq [1]
        end
      end

      describe '#results?' do
        it 'returns true if there are results' do
          expect(new_finder([1, 2, 3], value: 1)).to be_results
        end

        it 'returns false if there are no results' do
          expect(new_finder([1, 2, 3], value: 4)).not_to be_results
        end
      end

      describe '#count' do
        it 'counts the number of results' do
          expect(new_finder([1, 2, 3], value: 1).count).to eq 1
        end

        it 'can not be bypassed by features' do
          finder = new_finder [1, 2, 3] do
            def fetch_results; end
          end

          expect(finder.count).to eq 3
        end
      end

      describe '#params' do
        it 'exports filters as params' do
          finder = new_finder [], value: 1
          expect(finder.params).to eq 'value' => 1
        end

        it 'can overwrite filters (mainly used for url handers)' do
          finder = new_finder [], value: 1
          expect(finder.params(value: 2)).to eq 'value' => 2
        end

        it 'ignores missing filters' do
          finder = new_finder
          expect(finder.params).to eq({})
        end

        it 'ignores invalid filters' do
          finder = new_finder [], invalid: 'option'
          expect(finder.params).to eq({})
        end

        it 'includes default filters' do
          finder = new_finder do
            filter_by :value, 1
          end
          expect(finder.params).to eq 'value' => 1
        end
      end
    end
  end
end
