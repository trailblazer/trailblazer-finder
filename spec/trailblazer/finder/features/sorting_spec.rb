# require 'spec_helper_sequel'
require 'spec_helper'

module Trailblazer
  class Finder
    module Features
      describe Sorting, :sorting do
        class TestSortingFinder < Trailblazer::Finder
          features Sorting

          def create_product(id, name, price)
            {
              id: id,
              name: name,
              price: price,
              created_at: Time.now,
              updated_at: Time.now
            }
          end

          entity_type do
            Array.new(5) do |i|
              next create_product(i + 1, '', "1#{i}".to_i) if i == 7
              next create_product(i + 1, 'Name4', "1#{i}".to_i) if i == 9
              create_product(i + 1, "Name#{i}", "1#{i}".to_i)
            end.push(create_product(6, 'Name3', 8))
          end

          sortable_by :name, :price, :created_at, :id

          filter_by :name
          filter_by :price
          filter_by(:category) { |entity_type, _| entity_type.joins(:category) }
        end

        def finder_with_sort(sort = nil, filters = {})
          TestSortingFinder.new filter: (sort.nil? ? {} : { sort: sort }).merge(filters)
        end

        def finder_with_nil_sort
          TestSortingFinder.new filter: { sort: nil }
        end

        describe 'sorting' do
          it 'loads results if no sort options are supplied in the params' do
            finder = finder_with_nil_sort
            expect(finder.results.map { |n| n[:price] }).to eq [14, 13, 8, 12, 11, 10]
          end

          it 'sorts results based on the sort option desc' do
            finder = finder_with_sort 'price desc'
            expect(finder.results.map { |n| n[:price] }).to eq [14, 13, 12, 11, 10, 8]
          end

          it 'sorts results based on the sort option asc' do
            finder = finder_with_sort 'price asc'
            expect(finder.results.map { |n| n[:price] }).to eq [8, 10, 11, 12, 13, 14]
          end

          it 'defaults to original sorted hash' do
            finder = finder_with_sort
            expect(finder.results.map { |n| n[:name] }).to eq ['Name0', 'Name1', 'Name2', 'Name3', 'Name4', 'Name3']
          end

          it 'ignores invalid sort values' do
            finder = finder_with_sort 'invalid attribute'
            expect { finder.results.to_a }.not_to raise_error
          end
        end

        describe 'sorting by multiple' do

          it 'sorts by multiple columns name asc and price asc' do
            finder = finder_with_sort 'name asc, price asc'
            expect(finder.results.map { |n| n[:name] }).to eq ['Name0', 'Name1', 'Name2', 'Name3', 'Name3', 'Name4']
            expect(finder.results.map { |n| n[:price] }).to eq [10, 11, 12, 8, 13, 14]
          end

          it 'sorts by multiple columns name asc and price desc' do
            finder = finder_with_sort 'name asc, price desc'
            expect(finder.results.map { |n| n[:name] }).to eq ['Name0', 'Name1', 'Name2', 'Name3', 'Name3', 'Name4']
            expect(finder.results.map { |n| n[:price] }).to eq [10, 11, 12, 13, 8, 14]
          end

          it 'sorts by multiple columns name desc and price desc' do
            finder = finder_with_sort 'name desc, price desc'
            expect(finder.results.map { |n| n[:name] }).to eq ['Name4', 'Name3', 'Name3', 'Name2', 'Name1', 'Name0']
            expect(finder.results.map { |n| n[:price] }).to eq [14, 13, 8, 12, 11, 10]
          end
        end

        it_behaves_like 'a sorting feature'
      end
    end
  end
end
