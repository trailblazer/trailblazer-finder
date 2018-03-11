require 'spec_helper'
require 'support/paging_shared_example'

module Trailblazer
  class Finder
    module Features
      describe Paging do
        it_behaves_like 'a paging feature'

        it 'uses a pre-defined Hash entity_type instead of any ORM' do
          true
        end

        def define_finder_class(&block)
          Class.new do
            include Trailblazer::Finder::Base
            include Trailblazer::Finder::Features::Paging

            instance_eval(&block) if block_given?
          end
        end

        def finder_class # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
          define_finder_class do
            entity_type do
              [
                {
                  id: 1,
                  name: 'product_1',
                  price: '11',
                  created_at: Time.now,
                  updated_at: Time.now
                },
                {
                  id: 2,
                  name: 'product_2',
                  price: '12',
                  created_at: Time.now,
                  updated_at: Time.now
                },
                {
                  id: 3,
                  name: 'product_3',
                  price: '13',
                  created_at: Time.now,
                  updated_at: Time.now
                },
                {
                  id: 4,
                  name: 'product_4',
                  price: '14',
                  created_at: Time.now,
                  updated_at: Time.now
                },
                {
                  id: 5,
                  name: 'product_5',
                  price: '15',
                  created_at: Time.now,
                  updated_at: Time.now
                },
                {
                  id: 6,
                  name: 'product_6',
                  price: '15',
                  created_at: Time.now,
                  updated_at: Time.now
                }
              ]
            end

            per_page 2

            min_per_page 2
            max_per_page 10
          end
        end

        def finder_with_page(page = nil, per_page = nil)
          finder_class.new page: page, per_page: per_page
        end

        it 'can be inherited' do
          child_class = Class.new(finder_class)
          expect(child_class.new.per_page).to eq 2
        end

        describe '#results' do
          it 'paginates results' do
            finder = finder_with_page 2, 2
            expect(finder.results.map { |n| n[:name] }).to eq %w[product_3 product_4]
          end
        end

        describe '#count' do
          it 'gives the real count' do
            finder = finder_with_page 1
            expect(finder.count).to eq 6
          end
        end
      end
    end
  end
end
