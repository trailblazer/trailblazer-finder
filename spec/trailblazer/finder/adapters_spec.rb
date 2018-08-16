require 'spec_helper'
require 'active_record'

module Trailblazer
  class Finder
    describe Adapters do
      def define_finder_class(&block)
        Class.new do
          include Trailblazer::Finder::Base
          include Trailblazer::Finder::Adapters

          instance_eval(&block) if block_given?
        end
      end

      describe '.adapters' do
        it 'responds to adapters method' do
          finder_class = define_finder_class do
            entity_type { 'entity_type' }
          end

          expect(finder_class).to respond_to(:adapters)
        end
      end

      describe ActiveRecord do
        it 'can load ActiveRecord adapter' do
          expect do
            define_finder_class do
              entity_type { 'entity_type' }
              adapters ActiveRecord
            end
          end.not_to raise_error
        end
      end

      describe Sequel do
        it 'can load Sequel adapter' do
          expect do
            define_finder_class do
              entity_type { 'entity_type' }
              adapters Sequel
            end
          end.not_to raise_error
        end
      end

      describe DataMapper do
        it 'can load DataMapper adapter' do
          expect do
            define_finder_class do
              entity_type { 'entity_type' }
              adapters DataMapper
            end
          end.not_to raise_error
        end
      end

      describe Kaminari do
        it 'can load Kaminari adapter' do
          expect do
            define_finder_class do
              entity_type { 'entity_type' }
              adapters Kaminari
            end
          end.not_to raise_error
        end
      end

      describe WillPaginate do
        it 'can load WillPaginate adapter' do
          expect do
            define_finder_class do
              entity_type { 'entity_type' }
              adapters WillPaginate
            end
          end.not_to raise_error
        end
      end

      describe FriendlyId do
        it 'can load FriendlyId adapter' do
          expect do
            define_finder_class do
              entity_type { 'entity_type' }
              adapters FriendlyId
            end
          end.not_to raise_error
        end
      end

      it 'raises an error on non-existing adapter' do
        expect do
          define_finder_class do
            entity_type { 'entity_type' }
            adapters Unknown
          end
        end.to raise_error NameError
      end

      it 'can load multiple adapters' do
        expect do
          define_finder_class do
            entity_type { 'entity_type' }
            adapters ActiveRecord, Kaminari
          end
        end.not_to raise_error
      end
    end
  end
end
