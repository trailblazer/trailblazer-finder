require 'spec_helper_active_record'

module Trailblazer
  class Finder
    module Adapters
      describe FriendlyId do
        after do
          Product.delete_all
        end

        def finder_class
          Class.new(Trailblazer::Finder) do
            adapters ActiveRecord, FriendlyId

            entity_type { Product }

            filter_by :name
            filter_by :price
          end
        end

        def finder_with_slug(slug = nil, filters = {})
          finder_class.new filter: { id: slug }.merge(filters)
        end

        it 'filters by slug' do
          2.times { |i| Product.create name: "Product #{i}", price: i, slug: "product_#{i}" }
          finder = finder_with_slug 'product_1'
          expect(finder.results.map(&:name)).to eq ['Product 1']
        end

        it 'filters by id' do
          2.times { |i| Product.create name: "Product #{i}", price: i, slug: "product_#{i}" }
          finder = finder_with_slug Product.last.id
          expect(finder.results.map(&:name)).to match_array([Product.last.name])
        end

        it 'returns no records when slug is not found' do
          2.times { |i| Product.create name: "Product #{i}", price: i, slug: "product_#{i}" }
          finder = finder_with_slug 'unknown_1'
          expect(finder.count).to eq 0
        end
      end
    end
  end
end
