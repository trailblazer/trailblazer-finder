# frozen_string_literal: true

require 'test_helper'
require 'sequel'
Sequel::Model.plugin :timestamps

DB = if RUBY_ENGINE == 'jruby'
       Sequel.connect('jdbc:sqlite::memory:')
     else
       Sequel.sqlite
     end

DB.create_table :s_products do
  primary_key :id
  String :name
  String :slug
  Integer :s_category_id
  Integer :price
  DateTime :created_at
  DateTime :updated_at
end

DB.create_table :s_categories do
  primary_key :id
  String :title
  String :slug
  DateTime :created_at
  DateTime :updated_at
end

class SProduct < Sequel::Model
  many_to_one :s_category
end

class SCategory < Sequel::Model
  one_to_many :s_product
end

module Trailblazer
  class Finder
    module Adapters
      class SequelSpec < Minitest::TrailblazerSpec
        after do
          SProduct.order(:id).delete
          DB.run "update sqlite_sequence set seq = 0 where name = 's_products';"
        end

        def define_finder_class(&block)
          Class.new(Trailblazer::Finder) do
            adapter 'Sequel'
            entity { SProduct }

            class_eval(&block)
          end
        end

        def finder_class(&block)
          define_finder_class do
            class_eval(&block) unless block.nil?
          end
        end

        def new_finder(filter = {}, &block)
          finder_class(&block).new params: filter
        end

        describe '#property' do
          it 'sets the property and works with eq predicate' do
            10.times { |i| SProduct.create name: "product_#{i}" }
            finder = new_finder name_eq: 'product_2' do
              property :name, type: Types::String
            end

            assert_equal finder.result.first.id, 3
            assert_equal finder.result.count, 1
          end

          it 'sets the property and works with not_eq predicate' do
            10.times { |i| SProduct.create name: "product_#{i}" }
            finder = new_finder name_not_eq: 'product_2' do
              property :name, type: Types::String
            end

            assert_equal finder.result.count, 9
          end

          it 'sets the property and works with blank predicate' do
            9.times { |i| SProduct.create name: "product_#{i}" }
            SProduct.create name: '', slug: 'Blank Test'
            finder = new_finder name_blank: true do
              property :name, type: Types::String
            end

            assert_equal finder.result.count, 1
            assert_equal finder.result.first.slug, 'Blank Test'
          end

          it 'sets the property and works with not blank predicate' do
            9.times { |i| SProduct.create name: "product_#{i}" }
            SProduct.create name: '', slug: 'Blank Test'
            finder = new_finder name_not_blank: true do
              property :name, type: Types::String
            end

            assert_equal finder.result.count, 9
            assert_equal finder.result.first.name, 'product_0'
          end

          it 'sets the property and works with gt (greater than) predicate' do
            10.times { |i| SProduct.create name: "product_#{i}" }
            finder = new_finder id_gt: 3 do
              property :id, type: Types::Integer
            end

            assert_equal finder.result.count, 7
          end

          it 'sets the property and works with gte (greater than or equal to) predicate' do
            10.times { |i| SProduct.create name: "product_#{i}" }
            finder = new_finder id_gte: 3 do
              property :id, type: Types::Integer
            end

            assert_equal finder.result.count, 8
          end

          it 'sets the property and works with lt (less than) predicate' do
            10.times { |i| SProduct.create name: "product_#{i}" }
            finder = new_finder id_lt: 3 do
              property :id, type: Types::Integer
            end

            assert_equal finder.result.count, 2
          end

          it 'sets the property and works with lte (less than or equal to) predicate' do
            10.times { |i| SProduct.create name: "product_#{i}" }
            finder = new_finder id_lte: 3 do
              property :id, type: Types::Integer
            end

            assert_equal finder.result.count, 3
          end

          it 'sets the property and works with cont predicate' do
            5.times { |i| SProduct.create name: "product_#{i}" }
            5.times { |i| SProduct.create name: "none_#{i}" }
            finder = new_finder name_cont: 'product' do
              property :name, type: Types::String
            end

            assert_equal finder.result.first.id, 1
            assert_equal finder.result.count, 5
          end

          it 'sets the property and works with not_cont predicate' do
            5.times { |i| SProduct.create name: "product_#{i}" }
            5.times { |i| SProduct.create name: "none_#{i}" }
            finder = new_finder name_not_cont: 'product' do
              property :name, type: Types::String
            end

            assert_equal finder.result.first.id, 6
            assert_equal finder.result.count, 5
          end

          it 'sets the property and works with sw predicate' do
            5.times { |i| SProduct.create name: "product_#{i}" }
            SProduct.create name: 'predicate_0'
            4.times { |i| SProduct.create name: "none_#{i}" }
            finder = new_finder name_sw: 'pr' do
              property :name, type: Types::String
            end

            assert_equal finder.result.first.id, 1
            assert_equal finder.result.count, 6
          end

          it 'sets the property and works with not_sw predicate' do
            5.times { |i| SProduct.create name: "product_#{i}" }
            SProduct.create name: 'predicate_0'
            4.times { |i| SProduct.create name: "none_#{i}" }
            finder = new_finder name_not_sw: 'pr' do
              property :name, type: Types::String
            end

            assert_equal finder.result.first.id, 7
            assert_equal finder.result.count, 4
          end

          it 'sets the property and works with ew predicate' do
            5.times { |i| SProduct.create name: "product_#{i}_end" }
            SProduct.create name: 'predicate_0_endwow'
            4.times { |i| SProduct.create name: "none_#{i}" }
            finder = new_finder name_ew: 'end' do
              property :name, type: Types::String
            end

            assert_equal finder.result.first.id, 1
            assert_equal finder.result.count, 5
          end

          it 'sets the property and works with not_ew predicate' do
            5.times { |i| SProduct.create name: "product_#{i}_end" }
            SProduct.create name: 'predicate_0_endwow'
            4.times { |i| SProduct.create name: "none_#{i}" }
            finder = new_finder name_not_ew: 'end' do
              property :name, type: Types::String
            end

            assert_equal finder.result.first.id, 6
            assert_equal finder.result.count, 5
          end
        end

        describe '#paging' do
          it 'sets the paging values and shows only the first page results' do
            10.times { |i| SProduct.create name: "product_#{i}" }
            finder = new_finder do
              paging per_page: 2, min_per_page: 1, max_per_page: 5
            end

            assert_equal finder.result.map { |n| n[:name] }, %w[product_0 product_1]
          end

          it 'accepts per_page as a parameter' do
            10.times { |i| SProduct.create name: "product_#{i}" }
            finder = new_finder page: 2, per_page: 4 do
              paging per_page: 5, min_per_page: 2, max_per_page: 8
            end

            assert_equal finder.result.first.id, 5
            assert_equal finder.result.map(&:id), [5, 6, 7, 8]
          end

          it 'uses max_per_page in finder as maximum per_page' do
            10.times { |i| SProduct.create name: "product_#{i}" }
            finder = new_finder page: 2, per_page: 9 do
              paging per_page: 5, min_per_page: 2, max_per_page: 8
            end

            assert_equal finder.result.first.id, 9
            assert_equal finder.result.map(&:id), [9, 10]
          end

          it 'uses min_per_page in finder as minimum per_page' do
            10.times { |i| SProduct.create name: "product_#{i}" }
            finder = new_finder page: 2, per_page: 1 do
              paging per_page: 5, min_per_page: 2, max_per_page: 8
            end

            assert_equal finder.result.first.id, 3
            assert_equal finder.result.map(&:id), [3, 4]
          end
        end

        describe '#sorting' do
          it 'sets the property and works with eq predicate and sorting' do
            5.times { |i| SProduct.create name: "product_#{i}" }
            5.times { |_i| SProduct.create name: 'product' }
            finder = new_finder name_eq: 'product', sort: 'id desc' do
              property :name, type: Types::String
              property :id, type: Types::Integer, sortable: true
            end

            assert_equal finder.result.first.id, 10
            assert_equal finder.result.count, 5
          end

          it 'sets the property and sorts by multiple columns' do
            5.times { |i| SProduct.create name: "product_#{i}", slug: "slug #{i}" }
            5.times { |i| SProduct.create name: 'product', slug: "slug #{i}" }
            finder = new_finder sort: 'name asc, slug desc' do
              property :name, type: Types::String, sortable: true
              property :slug, type: Types::String, sortable: true
              property :id, type: Types::Integer, sortable: true
            end

            assert_equal finder.result.map { |n| n[:id] }, [10, 9, 8, 7, 6, 1, 2, 3, 4, 5]
            assert_equal finder.result.count, 10
          end
        end

        describe 'Predicates, Paging and Sorting together' do
          it 'sets the property and works with eq predicate and paging' do
            5.times { |i| SProduct.create name: "product_#{i}" }
            5.times { |_i| SProduct.create name: 'product' }
            finder = new_finder name_eq: 'product', sort: 'id desc', page: 2 do
              paging per_page: 2, min_per_page: 1, max_per_page: 5
              property :name, type: Types::String
              property :id, type: Types::Integer, sortable: true
            end

            assert_equal finder.result.first.id, 8
            assert_equal finder.result.map(&:id), [8, 7]
          end
        end
      end
    end
  end
end
