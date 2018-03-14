# require 'spec_helper_sequel'
require 'spec_helper'

module Trailblazer
  class Finder
    module Features
      describe Predicate do
        class TestFinder < Trailblazer::Finder
          features Predicate

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
            Array.new(10) do |i|
              next create_product(i+1, "", "1#{i}".to_i)if i == 7
              next create_product(i+1, nil, "1#{i}".to_i) if i == 8
              next create_product(i+1, "product_4", "1#{i}".to_i) if i == 9
              create_product(i+1, "product_#{i}", "1#{i}".to_i)
            end
          end

          predicates_for :name, :price, :created_at
        end

        def finder_with_predicate(filter = nil, value = nil, filters = {})
          TestFinder.new filter: { filter => value }.merge(filters)
        end

        describe 'eqauls' do
          it 'it finds single row with name equal to product_5' do
            finder = finder_with_predicate 'name_eq', 'product_5'
            expect(finder.results.map { |n| n[:price] }).to eq [15]
          end

          it 'it finds multiple rows with name equal to product_4' do
            finder = finder_with_predicate 'name_eq', 'product_4'
            expect(finder.results.map { |n| n[:price] }).to eq [14, 19]
          end

          it 'it finds rows with name not equal to product_4' do
            finder = finder_with_predicate 'name_not_eq', 'product_4'
            expect(finder.results.map { |n| n[:name] }).to eq ["product_0", "product_1", "product_2", "product_3", "product_5", "product_6", ""]
            expect(finder.results.map { |n| n[:price] }).to eq [10, 11, 12, 13, 15, 16, 17]
          end

          it 'it finds multiple rows with name blank (empty/nil)' do
            finder = finder_with_predicate 'name_blank', ''
            expect(finder.results.map { |n| n[:price] }).to eq [17, 18]
          end

          it 'it finds multiple rows with name not blank (empty/nil)' do
            finder = finder_with_predicate 'name_not_blank', ''
            expect(finder.results.map { |n| n[:name] }).to eq ["product_0", "product_1", "product_2", "product_3", "product_4", "product_5", "product_6", "product_4"]
          end

          it 'it finds multiple rows with price less than 15' do
            finder = finder_with_predicate 'price_lt', 15
            expect(finder.results.map { |n| n[:name] }).to eq ["product_0", "product_1", "product_2", "product_3", "product_4"]
            expect(finder.results.map { |n| n[:price] }).to eq [10, 11, 12, 13, 14]
          end

          it 'it finds multiple rows with price equal to and less than 15' do
            finder = finder_with_predicate 'price_lte', 15
            expect(finder.results.map { |n| n[:name] }).to eq ["product_0", "product_1", "product_2", "product_3", "product_4", "product_5"]
            expect(finder.results.map { |n| n[:price] }).to eq [10, 11, 12, 13, 14, 15]
          end

          it 'it finds multiple rows with price greater than 15' do
            finder = finder_with_predicate 'price_gt', 15
            expect(finder.results.map { |n| n[:name] }).to eq ["product_6", "", nil, "product_4"]
            expect(finder.results.map { |n| n[:price] }).to eq [16, 17, 18, 19]
          end

          it 'it finds multiple rows with price equal to and greater than 15' do
            finder = finder_with_predicate 'price_gte', 15
            expect(finder.results.map { |n| n[:name] }).to eq ["product_5", "product_6", "", nil, "product_4"]
            expect(finder.results.map { |n| n[:price] }).to eq [15, 16, 17, 18, 19]
          end

          it 'it finds rows with name not equal to product_4 and name not blank and price greater than 14' do
            params = { name_not_blank: true, price_gt: 14 }
            finder = finder_with_predicate 'name_not_eq', 'product_4', params

            expect(finder.results.map { |n| n[:name] }).to eq ["product_5", "product_6"]
            expect(finder.results.map { |n| n[:price] }).to eq [15, 16]
          end
        end
      end
    end
  end
end
