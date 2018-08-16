require 'spec_helper'

module Trailblazer
  class Finder
    module Utils
      describe String do
        describe '.camelize' do
          it "transforms :paging to 'Paging'" do
            expect(Finder::Utils::String.camelize(:paging)).to eq 'Paging'
          end
        end

        describe '.underscore' do
          it "transforms 'veryPopular' to 'very_popular'" do
            expect(Finder::Utils::String.underscore(:veryPopular)).to eq 'very_popular'
          end

          it "transforms 'Very Popular' to 'very_popular'" do
            expect(Finder::Utils::String.underscore('Very Popular')).to eq 'very_popular'
          end
        end
      end
    end
  end
end
