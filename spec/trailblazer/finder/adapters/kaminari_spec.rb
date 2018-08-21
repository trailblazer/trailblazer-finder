require "spec_helper_active_record"
require "kaminari"
require "kaminari/activerecord"

module Trailblazer
  class Finder
    module Adapters
      describe Kaminari do
        after do
          Product.delete_all
          Product.reset_pk_sequence
        end

        def define_finder_class(&block)
          Class.new(Trailblazer::Finder) do
            adapters ActiveRecord, Kaminari
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

        describe "#paging" do
          it "sets the paging values and shows only the first page results" do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder do
              paging per_page: 2, min_per_page: 1, max_per_page: 5
            end

            expect(finder.result.map { |n| n[:name] }).to eq %w[product_0 product_1]
          end
        end

        describe "Predicates, Paging and Sorting together" do
          it "sets the property and works with eq predicate and paging" do
            5.times { |i| Product.create name: "product_#{i}" }
            5.times { |_i| Product.create name: "product" }
            finder = new_finder name_eq: "product", sort: "id desc", page: 2 do
              paging per_page: 2, min_per_page: 1, max_per_page: 5
              property :name, type: Types::String
              property :id, type: Types::Integer, sortable: true
            end

            expect(finder.result.map(&:id)).to eq [8, 7]
          end
        end
      end
    end
  end
end