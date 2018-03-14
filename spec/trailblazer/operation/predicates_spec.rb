require 'delegate'
require 'trailblazer'
require 'spec_helper_active_record'

class Product::PredicateFinderNoEntity < Trailblazer::Finder
  features Predicate
  adapters ActiveRecord

  predicates_for :name, :price, :created_at

  filter_by(:category) { |entity_type, _| entity_type.joins(:category) }
end

class Product::PredicateFinderWithEntity < Trailblazer::Finder
  features Predicate
  adapters ActiveRecord

  entity_type { Product }

  predicates_for :name, :price, :created_at

  filter_by(:category) { |entity_type, _| entity_type.joins(:category) }
end

class Product::PredicateIndex < Trailblazer::Operation
  step Finder(Product::PredicateFinderNoEntity, :all, Product)
end

class Product::PredicateIndexNoEntity < Trailblazer::Operation
  step Finder(Product::PredicateFinderWithEntity, :all)
end

describe 'Trailblazer::Operation - Finder Macro - Sorting' do
  before do
    Product.destroy_all
    Product.reset_pk_sequence
    Product.delete_all
    10.times do |i|
      next Product.create name: "", price: "1#{i}" if i == 7
      next Product.create name: nil, price: "1#{i}" if i == 8
      next Product.create name: "product_4", price: "1#{i}" if i == 9
      Product.create name: "product_#{i}", price: "1#{i}"
    end
  end

  after do
    Product.destroy_all
    Product.reset_pk_sequence
  end

  it 'it finds single row with name equal to product_5' do
    params = { f: { name_eq: 'product_5' } }
    result = Product::PredicateIndex.call(params: params)

    expect(result[:finder].results.first.name).to eq "product_5"
  end

  it 'it finds multiple rows with name equal to product_4' do
    params = { f: { name_eq: 'product_4' } }
    result = Product::PredicateIndex.call(params: params)

    expect(result[:finder].results.first.price).to eq 14
    expect(result[:finder].results.last.price).to eq 19
  end

  it 'it finds rows with name not equal to product_4' do
    params = { f: { name_not_eq: 'product_4' } }
    result = Product::PredicateIndex.call(params: params)

    expect(result[:finder].results.map(&:name)).to eq ["product_0", "product_1", "product_2", "product_3", "product_5", "product_6", ""]
    expect(result[:finder].results.map(&:price)).to eq [10, 11, 12, 13, 15, 16, 17]
  end

  it 'it finds multiple rows with name blank (empty/nil)' do
    params = { f: { name_blank: true } }
    result = Product::PredicateIndex.call(params: params)

    expect(result[:finder].results.map(&:price)).to eq [17, 18]
  end

  it 'it finds multiple rows with name not blank (empty/nil)' do
    params = { f: { name_not_blank: true } }
    result = Product::PredicateIndex.call(params: params)

    expect(result[:finder].results.map(&:name)).to eq ["product_0", "product_1", "product_2", "product_3", "product_4", "product_5", "product_6", "product_4"]
  end

  it 'it finds multiple rows with price less than 15' do
    params = { f: { price_lt: 15 } }
    result = Product::PredicateIndex.call(params: params)

    expect(result[:finder].results.map(&:name)).to eq ["product_0", "product_1", "product_2", "product_3", "product_4"]
    expect(result[:finder].results.map(&:price)).to eq [10, 11, 12, 13, 14]
  end

  it 'it finds multiple rows with price equal to and less than 15' do
    params = { f: { price_lte: 15 } }
    result = Product::PredicateIndex.call(params: params)

    expect(result[:finder].results.map(&:name)).to eq ["product_0", "product_1", "product_2", "product_3", "product_4", "product_5"]
    expect(result[:finder].results.map(&:price)).to eq [10, 11, 12, 13, 14, 15]
  end

  it 'it finds multiple rows with price greater than 15' do
    params = { f: { price_gt: 15 } }
    result = Product::PredicateIndex.call(params: params)

    expect(result[:finder].results.map(&:name)).to eq ["product_6", "", nil, "product_4"]
    expect(result[:finder].results.map(&:price)).to eq [16, 17, 18, 19]
  end

  it 'it finds multiple rows with price equal to and greater than 15' do
    params = { f: { price_gte: 15 } }
    result = Product::PredicateIndex.call(params: params)

    expect(result[:finder].results.map(&:name)).to eq ["product_5", "product_6", "", nil, "product_4"]
    expect(result[:finder].results.map(&:price)).to eq [15, 16, 17, 18, 19]
  end

  it 'it finds rows with name not equal to product_4 and name not blank and price greater than 14' do
    params = { f: { name_not_eq: 'product_4', name_not_blank: true, price_gt: 14 } }
    result = Product::PredicateIndex.call(params: params)

    expect(result[:finder].results.map(&:name)).to eq ["product_5", "product_6"]
    expect(result[:finder].results.map(&:price)).to eq [15, 16]
  end
end
