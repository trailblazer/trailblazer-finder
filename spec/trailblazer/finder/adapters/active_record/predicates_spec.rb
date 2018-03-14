require 'spec_helper_active_record'
# require 'spec_helper'

module Trailblazer
  class Finder
    module Adapters
      module ActiveRecord
        describe Predicates do
          class TestFinder < Trailblazer::Finder
            features Predicate
            adapters ActiveRecord

            entity_type { Product }

            predicates_for :name, :price, :created_at

            filter_by(:category) { |entity_type, _| entity_type.joins(:category) }
          end

          def finder_with_predicate(filter = nil, value = nil, filters = {})
            TestFinder.new filter: { filter => value }.merge(filters)
          end

          describe 'equals' do
            before do
              Product.delete_all
              Product.reset_pk_sequence
              10.times do |i|
                next Product.create name: "", price: "1#{i}" if i == 7
                next Product.create name: nil, price: "1#{i}" if i == 8
                next Product.create name: "product_4", price: "1#{i}" if i == 9
                Product.create name: "product_#{i}", price: "1#{i}"
              end
            end

            it 'it finds single row with name equal to product_5' do
              finder = finder_with_predicate 'name_eq', 'product_5'
              expect(finder.results.map(&:price)).to eq [15]
            end

            it 'it finds multiple rows with name equal to product_4' do
              finder = finder_with_predicate 'name_eq', 'product_4'
              expect(finder.results.map(&:price)).to eq [14, 19]
            end

            it 'it finds rows with name not equal to product_4' do
              finder = finder_with_predicate 'name_not_eq', 'product_4'
              expect(finder.results.map(&:name)).to eq ["product_0", "product_1", "product_2", "product_3", "product_5", "product_6", ""]
              expect(finder.results.map(&:price)).to eq [10, 11, 12, 13, 15, 16, 17]
            end

            it 'it finds multiple rows with name blank (empty/nil)' do
              finder = finder_with_predicate 'name_blank', ''
              expect(finder.results.map(&:price)).to eq [17, 18]
            end

            it 'it finds multiple rows with name not blank (empty/nil)' do
              finder = finder_with_predicate 'name_not_blank', ''
              expect(finder.results.map(&:name)).to eq ["product_0", "product_1", "product_2", "product_3", "product_4", "product_5", "product_6", "product_4"]
            end

            it 'it finds multiple rows with price less than 15' do
              finder = finder_with_predicate 'price_lt', 15
              expect(finder.results.map(&:name)).to eq ["product_0", "product_1", "product_2", "product_3", "product_4"]
              expect(finder.results.map(&:price)).to eq [10, 11, 12, 13, 14]
            end

            it 'it finds multiple rows with price equal to and less than 15' do
              finder = finder_with_predicate 'price_lte', 15
              expect(finder.results.map(&:name)).to eq ["product_0", "product_1", "product_2", "product_3", "product_4", "product_5"]
              expect(finder.results.map(&:price)).to eq [10, 11, 12, 13, 14, 15]
            end

            it 'it finds multiple rows with price greater than 15' do
              finder = finder_with_predicate 'price_gt', 15
              expect(finder.results.map(&:name)).to eq ["product_6", "", nil, "product_4"]
              expect(finder.results.map(&:price)).to eq [16, 17, 18, 19]
            end

            it 'it finds multiple rows with price equal to and greater than 15' do
              finder = finder_with_predicate 'price_gte', 15
              expect(finder.results.map(&:name)).to eq ["product_5", "product_6", "", nil, "product_4"]
              expect(finder.results.map(&:price)).to eq [15, 16, 17, 18, 19]
            end

            it 'it finds rows with name not equal to product_4 and name not blank and price greater than 14' do
              params = { name_not_blank: true, price_gt: 14 }
              finder = finder_with_predicate 'name_not_eq', 'product_4', params

              expect(finder.results.map(&:name)).to eq ["product_5", "product_6"]
              expect(finder.results.map(&:price)).to eq [15, 16]
            end
          end
        end
      end
    end
  end
end
