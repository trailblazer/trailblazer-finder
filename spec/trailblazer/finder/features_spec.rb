require 'spec_helper'

module Trailblazer
  class Finder
    describe Features do
      def define_finder_class(&block)
        Class.new do
          include Trailblazer::Finder::Base
          include Trailblazer::Finder::Features

          instance_eval(&block) if block_given?
        end
      end

      it '.adapters' do
        finder_class = define_finder_class do
          entity_type { 'entity_type' }
        end

        expect(finder_class).to respond_to(:features)
      end

      describe Paging do
        it 'can load Paging feature' do
          expect do
            define_finder_class do
              entity_type { 'entity_type' }
              features Paging
            end
          end.not_to raise_error
        end
      end

      describe Sorting do
        it 'can load Sorting feature' do
          expect do
            define_finder_class do
              entity_type { 'entity_type' }
              features Sorting
            end
          end.not_to raise_error
        end
      end

      it 'raises an error on non-existing feature' do
        expect do
          define_finder_class do
            entity_type { 'entity_type' }
            features Unknown
          end
        end.to raise_error NameError
      end
    end
  end
end
