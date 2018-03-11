require 'delegate'
require 'trailblazer'
require 'spec_helper_active_record'

class Product::PagingFinderNoEntity < Trailblazer::Finder
  features Paging

  adapters ActiveRecord

  per_page 2
  min_per_page 2
  max_per_page 10

  filter_by :id
  filter_by :name
end

class Product::PagingFinderWithEntity < Trailblazer::Finder
  features Paging

  adapters ActiveRecord

  entity_type { Product }

  per_page 2
  min_per_page 2
  max_per_page 10

  filter_by :id
  filter_by :name
end

class Product::PagingIndex < Trailblazer::Operation
  step Finder(Product::PagingFinderNoEntity, :all, Product)
end

class Product::PagingIndexNoEntity < Trailblazer::Operation
  step Finder(Product::PagingFinderWithEntity, :all)
end

describe 'Trailblazer::Operation - Finder Macro - Paging' do
  before do
    Product.destroy_all
    Product.reset_pk_sequence
    20.times { |i| Product.create name: "product_#{i}" }
  end

  after do
    Product.destroy_all
    Product.reset_pk_sequence
  end

  it 'Can paginate results' do
    params = { page: 2 }
    result = Product::PagingIndex.call(params: params)

    expect(result[:finder].count).to eq 20
    expect(result[:finder].results).to eq Product.limit(2).offset(2)
  end

  it 'Can paginate results when no entity type is given in macro' do
    params = { page: 2 }
    result = Product::PagingIndexNoEntity.call(params: params)

    expect(result[:finder].count).to eq 20
    expect(result[:finder].results).to eq Product.limit(2).offset(2)
  end
end
