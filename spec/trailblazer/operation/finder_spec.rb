require 'delegate'
require 'trailblazer'
require 'spec_helper_active_record'

class Product::FinderNoEntity < Trailblazer::Finder
  adapters ActiveRecord

  filter_by :id
  filter_by :name
  filter_by :escaped_name, with: :apply_escaped_name

  def apply_escaped_name(entity_type, value)
    return unless value.present?
    entity_type.where 'lower(name) LIKE ?', Utils::Parse.term(value.downcase)
  end
end

class Product::FinderWithEntity < Trailblazer::Finder
  adapters ActiveRecord

  entity_type { Product }

  filter_by :id
  filter_by :name
  filter_by :escaped_name, with: :apply_escaped_name

  def apply_escaped_name(entity_type, value)
    return unless value.present?
    entity_type.where 'lower(name) LIKE ?', Utils::Parse.term(value.downcase)
  end
end

class Product::Index < Trailblazer::Operation
  step Finder(Product::FinderNoEntity, :all, Product)
end

class Product::Show < Trailblazer::Operation
  step Finder(Product::FinderNoEntity, :single, Product)
end

class Product::IndexNoEntity < Trailblazer::Operation
  step Finder(Product::FinderWithEntity, :all)
end

class Product::ShowNoEntity < Trailblazer::Operation
  step Finder(Product::FinderWithEntity, :single)
end


describe 'Trailblazer::Operation - Finder Macro' do
  before do
    Product.destroy_all
    Product.reset_pk_sequence
    20.times { |i| Product.create name: "product_#{i}" }
  end

  after do
    Product.destroy_all
    Product.reset_pk_sequence
  end

  it 'Can find a single row by id' do
    params = { id: 5 }
    result = Product::Show.call(params: params)

    expect(result[:finder].name).to eq 'product_4'
  end

  it 'Can find a single row by name' do
    params = { f: { name: 'product_2' } }
    result = Product::Show.call(params: params)

    expect(result[:finder].name).to eq 'product_2'
  end

  it 'Can find multiple rows by escaped name' do
    params = { f: { escaped_name: 'product_1' } }
    result = Product::Index.call(params: params)

    expect(result[:finder].results.last.name).to eq 'product_19'
  end

  it 'Can find a single row by id when no entity type is given in macro' do
    params = { id: 8 }
    result = Product::ShowNoEntity.call(params: params)

    expect(result[:finder].name).to eq 'product_7'
  end

  it 'Can find a single row by name when no entity type is given in macro' do
    params = { f: { name: 'product_2' } }
    result = Product::ShowNoEntity.call(params: params)

    expect(result[:finder].name).to eq 'product_2'
  end

  it 'Can find multiple rows by escaped name when no entity type is given in macro' do
    params = { f: { escaped_name: 'product_1' } }
    result = Product::IndexNoEntity.call(params: params)

    expect(result[:finder].results.last.name).to eq 'product_19'
  end
end
