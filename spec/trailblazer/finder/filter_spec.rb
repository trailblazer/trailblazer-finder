require 'spec_helper'
require 'ostruct'

module Trailblazer
  class Finder
    describe Filter do
      class TestFind
        include Trailblazer::Finder::Base
        include Trailblazer::Finder::Filter

        entity_type { [1, 2, 3, 4, 5] }

        filter_by :filter, defined_by: %w[odd even]

        private

        def apply_filter_with_odd(entity_type)
          entity_type.select(&:odd?)
        end

        def apply_filter_with_even(entity_type)
          entity_type.select(&:even?)
        end

        def handle_invalid_filter(_entity_type, value)
          "invalid filter - #{value}"
        end
      end

      it 'can filter by defined values' do
        expect(TestFind.results(filter: { filter: 'odd' })).to eq [1, 3, 5]
        expect(TestFind.results(filter: { filter: 'even' })).to eq [2, 4]
      end

      it 'ignores blank values' do
        expect(TestFind.results(filter: { filter: nil })).to eq [1, 2, 3, 4, 5]
        expect(TestFind.results(filter: { filter: '' })).to eq [1, 2, 3, 4, 5]
      end

      it 'handles wrongly defined values' do
        expect(TestFind.results(filter: { filter: 'foo' })).to eq 'invalid filter - foo'
      end

      it 'raises when block is passed with defined filter' do
        expect do
          Class.new do
            include Trailblazer::Finder::Base
            include Trailblazer::Finder::Filter

            filter_by(:filter, defined_by: %w[a b]) { |_entity_type, _value| nil }
          end
        end.to raise_error Trailblazer::Finder::Error::BlockIgnored
      end

      it 'raises when :with is passed with defined filter_by' do
        expect do
          Class.new do
            include Trailblazer::Finder::Base
            include Trailblazer::Finder::Filter

            filter_by :filter, defined_by: %w[a b], with: :method_name
          end
        end.to raise_error Trailblazer::Finder::Error::WithIgnored
      end
    end

    describe Filter::Handler do
      describe 'apply_filter' do
        def new_object(&block)
          klass = Class.new(&block)
          klass.new
        end

        def call(object: nil, filter_by: nil, defined_bys: nil, entity_type: nil, value:)
          described_class.apply_filter(
            object: object || new_object,
            filter_by: filter_by || 'filter_by',
            defined_bys: defined_bys || [value],
            entity_type: entity_type || [],
            value: value
          )
        end

        it 'filters by methods based on the defined value' do
          object = new_object do
            private

            def apply_select_with_name(entity_type)
              entity_type.select { |value| value == 'name' }
            end

            def apply_select_with_age(entity_type)
              entity_type.select { |value| value == 'age' }
            end
          end

          entity_type = %w[name age location]

          expect(call(object: object, filter_by: 'select', entity_type: entity_type, value: 'name')).to eq %w[name]
          expect(call(object: object, filter_by: 'select', entity_type: entity_type, value: 'age')).to eq %w[age]
        end

        it 'raises NoMethodError when object can not handle defined method' do
          expect { call(defined_bys: ['a'], value: 'a') }.to raise_error NoMethodError
        end

        it 'raises error when value is not defined' do
          expect { call(defined_bys: [], value: 'invalid') }.to raise_error Trailblazer::Finder::Error::InvalidDefinedByValue
        end

        it 'can delegate missing defined value to object' do
          object = new_object do
            def handle_invalid_filter_by(_entity_type, value)
              "handles #{value} value"
            end
          end

          expect(call(object: object, defined_bys: [], value: 'invalid')).to eq 'handles invalid value'
        end

        it 'can delegate missing defined value to object (cath all)' do
          object = new_object do
            def handle_invalid_defined_by(filter_by, _entity_type, value)
              "handles #{value} value for #{filter_by}"
            end
          end

          expect(call(object: object, defined_bys: [], value: 'invalid')).to eq 'handles invalid value for filter_by'
        end
      end
    end
  end
end
