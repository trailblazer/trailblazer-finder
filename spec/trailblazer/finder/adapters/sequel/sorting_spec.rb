require 'spec_helper_sequel'

describe 'Trailblazer::Finder::Adapters::Sequel::Sorting', :sorting do
  after do
    SProduct.order(:id).delete
  end

  before do
    SProduct.order(:id).delete
  end

  class TestSequelSortFinder < Trailblazer::Finder
    features Sorting
    adapters Sequel

    entity_type { SProduct }

    sortable_by :name, :price, :created_at

    filter_by :name, with: :apply_name_filter
    filter_by :price
    filter_by(:s_category) { |entity_type, _| entity_type.association_join(:s_category) }

    def apply_name_filter(entity_type, value)
    end
  end

  def finder_with_sort(sort = nil, filters = {})
    TestSequelSortFinder.new filter: (sort.nil? ? {} : { name: 'test', sort: sort }).merge(filters)
  end

  def finder_with_nil_sort
    TestSequelSortFinder.new filter: { sort: nil }
  end

  describe 'sorting' do
    it 'loads results if no sort options are supplied in the params' do
      5.times { |i| SProduct.create price: i }
      finder = finder_with_nil_sort
      expect(finder.results.map(&:price)).to eq [0, 1, 2, 3, 4]
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
      expect(finder.results.map(&:name)).to eq %w[Name0 Name1 Name2 Name3 Name4]
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

  describe 'sorting by multiple' do
    before do
      5.times do |i|
        SProduct.create name: "Name#{i}", price: "1#{i}"
      end
      SProduct.create name: 'Name3', price: '8'
    end

    it 'sorts by multiple columns name asc and price asc' do
      finder = finder_with_sort 'name asc, price asc'
      expect(finder.results.map(&:name)).to eq %w[Name0 Name1 Name2 Name3 Name3 Name4]
      expect(finder.results.map(&:price)).to eq [10, 11, 12, 8, 13, 14]
    end

    it 'sorts by multiple columns name asc and price desc' do
      finder = finder_with_sort 'name asc, price desc'
      expect(finder.results.map(&:name)).to eq %w[Name0 Name1 Name2 Name3 Name3 Name4]
      expect(finder.results.map(&:price)).to eq [10, 11, 12, 13, 8, 14]
    end

    it 'sorts by multiple columns name desc and price desc' do
      finder = finder_with_sort 'name desc, price desc'
      expect(finder.results.map(&:name)).to eq %w[Name4 Name3 Name3 Name2 Name1 Name0]
      expect(finder.results.map(&:price)).to eq [14, 13, 8, 12, 11, 10]
    end
  end

  it_behaves_like 'a sorting feature'
end
