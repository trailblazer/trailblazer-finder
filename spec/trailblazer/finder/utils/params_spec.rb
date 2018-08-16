require 'spec_helper'

module Trailblazer
  class Finder
    module Utils
      describe Params do
        describe '.slice_keys' do
          it 'selects only given keys' do
            hash = Finder::Utils::Params.slice_keys({ a: 1, b: 2, c: 3 }, %i[a b])
            expect(hash).to eq a: 1, b: 2
          end

          it 'ignores not existing keys' do
            hash = Finder::Utils::Params.slice_keys({}, %i[a b])
            expect(hash).to eq({})
          end
        end

        describe '.normalize_params' do
          it 'combines defaults and filters' do
            expect(Finder::Utils::Params.normalize_params({ 'a' => 1, 'b' => 2 }, { a: 2 }, %w[a b])).to eq 'a' => 2, 'b' => 2
          end

          it 'excludes non specified keys' do
            expect(Finder::Utils::Params.normalize_params({ 'a' => 1 }, { b: 2 }, %w[a])).to eq 'a' => 1
          end

          it 'handles missing defaults' do
            expect(Finder::Utils::Params.normalize_params(nil, { a: 1 }, %w[a])).to eq 'a' => 1
          end

          it 'handles missing filters' do
            expect(Finder::Utils::Params.normalize_params(nil, nil, ['a'])).to eq({})
          end
        end
      end
    end
  end
end
