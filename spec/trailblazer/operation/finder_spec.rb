# frozen_string_literal: true

require "delegate"
require "trailblazer"
require "spec_helper_active_record"

RSpec.describe "Trailblazer::Operation - Finder Macro" do
  before do
    Product.destroy_all
    Product.reset_pk_sequence
    22.times { |i| Product.create name: "product_#{i}" }
  end

  after do
    Product.destroy_all
    Product.reset_pk_sequence
  end

  it "Can find a single row by id" do
    params = { id: 5 }
    result = Product::Operations::Show.call(params: params)
    expect(result[:finder].name).to eq "product_4"
  end

  it "Can find a single row by id from ActiveSupport::HashWithIndifferentAccess" do
    params = ActiveSupport::HashWithIndifferentAccess.new({ id: 6 })
    result = Product::Operations::Show.call(params: params)

    expect(result[:finder].name).to eq "product_5"
  end

  it "Can find a single row by name" do
    params = { name_eq: "product_2" }
    result = Product::Operations::Show.call(params: params)

    expect(result[:finder].name).to eq "product_2"
  end

  it "Can find multiple rows by escaped name" do
    params = { escaped_name: "product_1" }
    result = Product::Operations::Index.call(params: params)

    expect(result[:finder].result.last.name).to eq "product_19"
  end

  it "Can find multiple rows by escaped name if key is string" do
    params = { "escaped_name" => "product_1" }
    result = Product::Operations::Index.call(params: params)

    expect(result[:finder].result.last.name).to eq "product_19"
  end

  it "Can find a single row by id when no entity type is given in macro" do
    params = { id: 8 }
    result = Product::Operations::ShowNoEntity.call(params: params)

    expect(result[:finder].name).to eq "product_7"
  end

  it "Can find a single row by name when no entity type is given in macro" do
    params = { name_eq: "product_2" }
    result = Product::Operations::ShowNoEntity.call(params: params)

    expect(result[:finder].name).to eq "product_2"
  end

  it "Can find multiple rows by escaped name when no entity type is given in macro" do
    params = { escaped_name: "product_1" }
    result = Product::Operations::IndexNoEntity.call(params: params)

    expect(result[:finder].result.count).to eq 11
    expect(result[:finder].result.last.name).to eq "product_19"
  end
end
