require 'delegate'
require 'trailblazer'
require 'spec_helper_active_record'

class Product::SortFinderNoEntity < Trailblazer::Finder
  features Sorting

  adapters ActiveRecord

  sortable_by :id, :name

  filter_by :id
  filter_by :name
end

class Product::SortFinderWithEntity < Trailblazer::Finder
  features Sorting

  adapters ActiveRecord

  entity_type { Product }

  sortable_by :id, :name

  filter_by :id
  filter_by :name
end

class Product::SortIndex < Trailblazer::Operation
  step Finder(Product::SortFinderNoEntity, :all, Product)
end

class Product::SortIndexNoEntity < Trailblazer::Operation
  step Finder(Product::SortFinderWithEntity, :all)
end

describe 'Trailblazer::Operation - Finder Macro - Sorting' do
  before do
    Product.destroy_all
    Product.reset_pk_sequence
    20.times { |i| Product.create name: "product_#{i}" }
  end

  after do
    Product.destroy_all
    Product.reset_pk_sequence
  end

  it 'Can sort results by name descending' do
    params = { f: { sort: 'name desc' } }
    result = Product::SortIndex.call(params: params)

    expect(result[:finder].count).to eq 20
    expect(result[:finder].results.last.name).to eq 'product_0'
  end

  it 'Can sort results by name descending when no entity type is given in macro' do
    params = { f: { sort: 'name desc' } }
    result = Product::SortIndexNoEntity.call(params: params)

    expect(result[:finder].count).to eq 20
    expect(result[:finder].results.last.name).to eq 'product_0'
  end

  it 'Can sort results by id ascending' do
    params = { f: { sort: 'id asc' } }
    result = Product::SortIndex.call(params: params)

    expect(result[:finder].count).to eq 20
    expect(result[:finder].results.last.name).to eq 'product_19'
  end

  it 'Can sort results by id ascending when no entity type is given in macro' do
    params = { f: { sort: 'id asc' } }
    result = Product::SortIndexNoEntity.call(params: params)

    expect(result[:finder].count).to eq 20
    expect(result[:finder].results.last.name).to eq 'product_19'
  end
end
