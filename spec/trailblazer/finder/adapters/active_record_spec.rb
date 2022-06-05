# frozen_string_literal: true

require "spec_helper_active_record"

module Trailblazer
  class Finder
    module Adapters
      RSpec.describe ActiveRecord do
        after do
          Product.delete_all
          Product.reset_pk_sequence
        end

        def define_finder_class(&block)
          Class.new(Trailblazer::Finder) do
            adapter "ActiveRecord"
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

        describe "#property" do
          it "sets the property and works with eq predicate" do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder name_eq: "product_2" do
              property :name, type: Types::String
            end

            expect(finder.result.first.id).to eq 3
            expect(finder.result.count).to eq 1
          end

          it "sets the property and works with not_eq predicate" do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder name_not_eq: "product_2" do
              property :name, type: Types::String
            end

            expect(finder.result.count).to eq 9
          end

          it "sets the property and works with blank predicate" do
            9.times { |i| Product.create name: "product_#{i}" }
            Product.create name: "", slug: "Blank Test"
            finder = new_finder name_blank: true do
              property :name, type: Types::String
            end

            expect(finder.result.count).to eq 1
            expect(finder.result.first.slug).to eq "Blank Test"
            expect(finder.result.first.id).to eq 10
          end

          it "sets the property and works with not blank predicate" do
            9.times { |i| Product.create name: "product_#{i}" }
            Product.create name: "", slug: "Blank Test"
            finder = new_finder name_not_blank: true do
              property :name, type: Types::String
            end

            expect(finder.result.count).to eq 9
          end

          it "sets the property and works with gt (greater than) predicate" do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder id_gt: 3 do
              property :id, type: Types::Integer
            end

            expect(finder.result.count).to eq 7
          end

          it "sets the property and works with gte (greater than or equal to) predicate" do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder id_gte: 3 do
              property :id, type: Types::Integer
            end

            expect(finder.result.count).to eq 8
          end

          it "sets the property and works with lt (less than) predicate" do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder id_lt: 3 do
              property :id, type: Types::Integer
            end

            expect(finder.result.count).to eq 2
          end

          it "sets the property and works with lte (less than or equal to) predicate" do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder id_lte: 3 do
              property :id, type: Types::Integer
            end

            expect(finder.result.count).to eq 3
          end

          it "sets the property and works with cont predicate" do
            5.times { |i| Product.create name: "product_#{i}" }
            5.times { |i| Product.create name: "none_#{i}" }
            finder = new_finder name_cont: "product" do
              property :name, type: Types::String
            end

            expect(finder.result.first.id).to eq 1
            expect(finder.result.count).to eq 5
          end

          it "sets the property and works with not_cont predicate" do
            5.times { |i| Product.create name: "product_#{i}" }
            5.times { |i| Product.create name: "none_#{i}" }
            finder = new_finder name_not_cont: "product" do
              property :name, type: Types::String
            end

            expect(finder.result.first.id).to eq 6
            expect(finder.result.count).to eq 5
          end

          it "sets the property and works with sw predicate" do
            5.times { |i| Product.create name: "product_#{i}" }
            Product.create name: "predicate_0"
            4.times { |i| Product.create name: "none_#{i}" }
            finder = new_finder name_sw: "pr" do
              property :name, type: Types::String
            end

            expect(finder.result.first.id).to eq 1
            expect(finder.result.count).to eq 6
          end

          it "sets the property and works with not_sw predicate" do
            5.times { |i| Product.create name: "product_#{i}" }
            Product.create name: "predicate_0"
            4.times { |i| Product.create name: "none_#{i}" }
            finder = new_finder name_not_sw: "pr" do
              property :name, type: Types::String
            end

            expect(finder.result.first.id).to eq 7
            expect(finder.result.count).to eq 4
          end

          it "sets the property and works with ew predicate" do
            5.times { |i| Product.create name: "product_#{i}_end" }
            Product.create name: "predicate_0_endwow"
            4.times { |i| Product.create name: "none_#{i}" }
            finder = new_finder name_ew: "end" do
              property :name, type: Types::String
            end

            expect(finder.result.first.id).to eq 1
            expect(finder.result.count).to eq 5
          end

          it "sets the property and works with not_ew predicate" do
            5.times { |i| Product.create name: "product_#{i}_end" }
            Product.create name: "predicate_0_endwow"
            4.times { |i| Product.create name: "none_#{i}" }
            finder = new_finder name_not_ew: "end" do
              property :name, type: Types::String
            end

            expect(finder.result.first.id).to eq 6
            expect(finder.result.count).to eq 5
          end
        end

        describe "#paging" do
          it "sets the paging values and shows only the first page results" do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder do
              paging per_page: 2, min_per_page: 1, max_per_page: 5
            end

            expect(finder.result.map { |n| n[:name] }).to eq %w[product_0 product_1]
          end

          it "accepts per_page as a parameter" do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder page: 2, per_page: 4 do
              paging per_page: 5, min_per_page: 2, max_per_page: 8
            end

            expect(finder.result.first.id).to eq 5
            expect(finder.result.map(&:id)).to eq [5, 6, 7, 8]
          end

          it "uses max_per_page in finder as maximum per_page" do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder page: 2, per_page: 9 do
              paging per_page: 5, min_per_page: 2, max_per_page: 8
            end

            expect(finder.result.first.id).to eq 9
            expect(finder.result.map(&:id)).to eq [9, 10]
          end

          it "uses min_per_page in finder as minimum per_page" do
            10.times { |i| Product.create name: "product_#{i}" }
            finder = new_finder page: 2, per_page: 1 do
              paging per_page: 5, min_per_page: 2, max_per_page: 8
            end

            expect(finder.result.first.id).to eq 3
            expect(finder.result.map(&:id)).to eq [3, 4]
          end
        end

        describe "#sorting" do
          it "sets the property and works with eq predicate and sorting" do
            5.times { |i| Product.create name: "product_#{i}" }
            5.times { |_i| Product.create name: "product" }
            finder = new_finder name_eq: "product", sort: "id desc" do
              property :name, type: Types::String
              property :id, type: Types::Integer, sortable: true
            end

            expect(finder.result.first.id).to eq 10
            expect(finder.result.count).to eq 5
          end

          it "sets the property and sorts by multiple columns" do
            5.times { |i| Product.create name: "product_#{i}", slug: "slug #{i}" }
            5.times { |i| Product.create name: "product", slug: "slug #{i}" }
            finder = new_finder sort: "name asc, slug desc" do
              property :name, type: Types::String, sortable: true
              property :slug, type: Types::String, sortable: true
              property :id, type: Types::Integer, sortable: true
            end

            expect(finder.result.map { |n| n[:id] }).to eq [10, 9, 8, 7, 6, 1, 2, 3, 4, 5]
            expect(finder.result.count).to eq 10
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

            expect(finder.result.first.id).to eq 8
            expect(finder.result.map(&:id)).to eq [8, 7]
          end
        end
      end
    end
  end
end
