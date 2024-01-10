# frozen_string_literal: true

require 'test_helper'
require 'support/operations'

module Trailblazer
  class Operation::FinderTest < Minitest::TrailblazerSpec
    before do
      Product.destroy_all
      Product.reset_pk_sequence
      22.times { |i| Product.create name: "product_#{i}" }
    end

    after do
      Product.destroy_all
      Product.reset_pk_sequence
    end

    it 'Can find a single row by id' do
      params = { id: 5 }
      result = Product::Operations::Show.call(params: params)

      assert_equal result[:finder].name, 'product_4'
    end

    it 'Can find a single row by id from ActiveSupport::HashWithIndifferentAccess' do
      params = ActiveSupport::HashWithIndifferentAccess.new({ id: 6 })
      result = Product::Operations::Show.call(params: params)

      assert_equal result[:finder].name, 'product_5'
    end

    it 'Can find a single row by name' do
      params = { name_eq: 'product_2' }
      result = Product::Operations::Show.call(params: params)

      assert_equal result[:finder].name, 'product_2'
    end

    it 'Can find multiple rows by escaped name' do
      params = { escaped_name: 'product_1' }
      result = Product::Operations::Index.call(params: params)

      assert_equal result[:finder].result.last.name, 'product_19'
    end

    it 'Can find multiple rows by escaped name if key is string' do
      params = { 'escaped_name' => 'product_1' }
      result = Product::Operations::Index.call(params: params)

      assert_equal result[:finder].result.last.name, 'product_19'
    end

    it 'Can find a single row by id when no entity type is given in macro' do
      params = { id: 8 }
      result = Product::Operations::ShowNoEntity.call(params: params)

      assert_equal result[:finder].name, 'product_7'
    end

    it 'Can find a single row by name when no entity type is given in macro' do
      params = { name_eq: 'product_2' }
      result = Product::Operations::ShowNoEntity.call(params: params)

      assert_equal result[:finder].name, 'product_2'
    end

    it 'Can find multiple rows by escaped name when no entity type is given in macro' do
      params = { escaped_name: 'product_1' }
      result = Product::Operations::IndexNoEntity.call(params: params)

      assert_equal result[:finder].result.count, 11
      assert_equal result[:finder].result.last.name, 'product_19'
    end
  end
end
