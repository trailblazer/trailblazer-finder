require 'spec_helper_sequel'

module Trailblazer
  class Finder
    module Adapters
      module Sequel
        describe Sorting do
          def finder_class
            Class.new do
              include Trailblazer::Finder::Base
              include Trailblazer::Finder::Features::Sorting
              include Trailblazer::Finder::Adapters::Sequel

              entity_type { SProduct }

              sortable_by :name, :price, :created_at

              filter_by :name
              filter_by :price
              filter_by(:s_category) { |entity_type, _| entity_type.association_join(:s_category) }
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
            before do
              SProduct.order(:id).delete
            end

            after do
              SProduct.order(:id).delete
            end

            it 'sorts results based on the sort option desc' do
              5.times { |i| SProduct.create price: i }

              finder = finder_with_sort 'price desc'
              expect(finder.results.map(&:price)).to eq [4, 3, 2, 1, 0]
            end

            it 'sorts results based on the sort option asc' do
              5.times { |i| SProduct.create price: i }

              finder = finder_with_sort 'price asc'
              expect(finder.results.map(&:price)).to eq [0, 1, 2, 3, 4]
            end

            it 'defaults to first sort by option' do
              5.times { |i| SProduct.create name: "Name#{i}" }

              finder = finder_with_sort
              expect(finder.results.map(&:name)).to eq %w[Name4 Name3 Name2 Name1 Name0]
            end

            it 'ignores invalid sort values' do
              finder = finder_with_sort 'invalid attribute'
              expect { finder.results.to_a }.not_to raise_error
            end

            it 'can handle renames of sorting in joins' do
              older_category = SCategory.create title: 'older'
              newer_category = SCategory.create title: 'newer'

              product_of_newer_category = SProduct.create name: 'older product', s_category: newer_category
              product_of_older_category = SProduct.create name: 'newer product', s_category: older_category

              finder = finder_with_sort 'created_at desc', s_category: ''

              expect(finder.results.map(&:name)).to eq [product_of_older_category.name, product_of_newer_category.name]
            end
          end

          it_behaves_like 'a sorting feature'
        end
      end
    end
  end
end
