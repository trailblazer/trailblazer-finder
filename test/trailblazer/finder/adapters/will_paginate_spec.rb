# frozen_string_literal: true

require 'test_helper'
require 'support/operations'
require 'will_paginate'
require 'will_paginate/active_record'

module WillPaginate
  module ActiveRecord
    module RelationMethods
      def per(value = nil)
        per_page(value)
      end
    end
  end
end

module Trailblazer
  class Finder
    module Adapters
      class WillPaginateSpec < Minitest::TrailblazerSpec
        after do
          Product.delete_all
          Product.reset_pk_sequence
        end

        def define_finder_class(&block)
          Class.new(Trailblazer::Finder) do
            entity { Product }

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

        describe '#adapters' do
          it 'cannot use kaminari without an actual orm' do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder do
              paginator 'WillPaginate'
              paging per_page: 2, min_per_page: 1, max_per_page: 5
            end

            assert_equal finder.errors,
                         [{ paginator: "Can't use paginator WillPaginate without using an ORM like ActiveRecord or Sequel" }]
          end
        end

        describe '#paging' do
          it 'sets the paging values and shows only the first page results' do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder do
              adapter 'ActiveRecord'
              paginator 'WillPaginate'
              paging per_page: 2, min_per_page: 1, max_per_page: 5
            end

            assert_equal finder.result.map { |n| n[:name] }, %w[product_0 product_1]
          end

          it 'accepts per_page as a parameter' do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder page: 2, per_page: 4 do
              adapter 'ActiveRecord'
              paginator 'WillPaginate'
              paging per_page: 5, min_per_page: 2, max_per_page: 8
            end

            assert_equal finder.result.first.id, 5
            assert_equal finder.result.map(&:id), [5, 6, 7, 8]
          end

          it 'uses max_per_page in finder as maximum per_page' do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder page: 2, per_page: 9 do
              adapter 'ActiveRecord'
              paginator 'WillPaginate'
              paging per_page: 5, min_per_page: 2, max_per_page: 8
            end

            assert_equal finder.result.first.id, 9
            assert_equal finder.result.map(&:id), [9, 10]
          end

          it 'uses min_per_page in finder as minimum per_page' do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder page: 2, per_page: 1 do
              adapter 'ActiveRecord'
              paginator 'WillPaginate'
              paging per_page: 5, min_per_page: 2, max_per_page: 8
            end

            assert_equal finder.result.first.id, 3
            assert_equal finder.result.map(&:id), [3, 4]
          end
        end

        describe 'Predicates, Paging and Sorting together' do
          it 'sets the property and works with eq predicate and paging' do
            5.times { |i| Product.create name: "product_#{i}" }
            5.times { |_i| Product.create name: 'product' }
            finder = new_finder name_eq: 'product', sort: 'id desc', page: 2 do
              adapter 'ActiveRecord'
              paginator 'WillPaginate'
              paging per_page: 2, min_per_page: 1, max_per_page: 5
              property :name, type: Types::String
              property :id, type: Types::Integer, sortable: true
            end

            assert_equal finder.result.map(&:id), [8, 7]
            assert_equal finder.count, 2
          end
        end
      end
    end
  end
end
