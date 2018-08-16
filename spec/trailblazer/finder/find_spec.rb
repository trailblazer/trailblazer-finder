require 'spec_helper'
require 'ostruct'

module Trailblazer
  describe Finder::Find do
    describe '.params' do
      it 'returns the passed params' do
        finder = Finder::Find.new('entity_type', 'params', {})
        expect(finder.params).to eq 'params'
      end
    end

    describe '.param' do
      it 'returns the param value' do
        finder = Finder::Find.new('entity_type', { name: 'value' }, {})
        expect(finder.param(:name)).to eq 'value'
      end
    end

    describe '.query' do
      it 'returns filtered result' do
        actions = {
          min: ->(entity_type, min) { entity_type.select { |v| v > min } }
        }

        finder = Finder::Find.new [1, 2, 3], { min: 2 }, actions
        expect(finder.query(Object.new)).to eq [3]
      end

      it 'applies actions to params' do
        actions = {
          min: ->(entity_type, min) { entity_type.select { |v| v > min } },
          max: ->(entity_type, max) { entity_type.select { |v| v < max } }
        }

        finder = Finder::Find.new [1, 2, 3, 4, 5], { min: 2, max: 5 }, actions
        expect(finder.query(Object.new)).to eq [3, 4]
      end

      it 'handles nil returned from action' do
        actions = {
          odd: ->(entity_type, odd) { entity_type.select(&:odd?) if odd }
        }

        finder = Finder::Find.new [1, 2, 3, 4, 5], { odd: false }, actions
        expect(finder.query(Object.new)).to eq [1, 2, 3, 4, 5]
      end

      it 'executes action in the passed context' do
        actions = {
          finder: ->(entity_type, _) { entity_type.select { |v| v == target_value } }
        }

        context = OpenStruct.new target_value: 2

        finder = Finder::Find.new [1, 2, 3, 4, 5], { finder: true }, actions
        expect(finder.query(context)).to eq [2]
      end
    end

    describe '.count' do
      it 'counts the results of the query' do
        actions = {
          value: ->(entity_type, value) { entity_type.select { |v| v == value } }
        }

        finder = Finder::Find.new [1, 2, 3], { value: 2 }, actions
        expect(finder.count(Object.new)).to eq 1
      end
    end
  end
end
