require 'spec_helper'
require 'support/sorting_shared_example'

module Trailblazer
  class Finder
    module Features
      describe Sorting do
        it 'uses a pre-defined Hash entity_type instead of any ORM' do
          true
        end

        def finder_class
          Class.new(Trailblazer::Finder) do
            features Sorting

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
                }
              ]
            end

            sortable_by :name, :price, :created_at

            filter_by :name
            filter_by :price
            filter_by(:category) { |entity_type, _| entity_type.joins(:category) }
          end
        end

        def finder_with_sort(sort = nil, filters = {})
          finder_class.new filter: { sort: sort }.merge(filters)
        end

        it 'can be inherited' do
          child_class = Class.new(finder_class)
          expect(child_class.new.sort_attribute).to eq 'name'
        end

        describe 'sorting' do
          it 'sorts results based on the sort option desc' do
            finder = finder_with_sort 'price desc'
            expect(finder.results.map { |n| n[:price] }).to eq %w[15 14 13 12 11]
          end

          it 'sorts results based on the sort option asc' do
            finder = finder_with_sort 'price asc'
            expect(finder.results.map { |n| n[:price] }).to eq %w[11 12 13 14 15]
          end

          it 'defaults to first sort by option' do
            finder = finder_with_sort
            expect(finder.results.map { |n| n[:name] }).to eq %w[product_5 product_4 product_3 product_2 product_1]
          end

          it 'ignores invalid sort values' do
            finder = finder_with_sort 'invalid attribute'
            expect { finder.results.to_a }.not_to raise_error
          end
        end

        it_behaves_like 'a sorting feature'
      end
    end
  end
end
