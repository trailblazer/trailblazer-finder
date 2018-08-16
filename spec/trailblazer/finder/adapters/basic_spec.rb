require "spec_helper"

module Trailblazer
  class Finder
    module Adapters
      describe Basic do
        def define_finder_class(&block)
          Class.new(Trailblazer::Finder) do
            class_eval(&block)
          end
        end

        def finder_class(default_entity = [], &block)
          define_finder_class do
            entity { default_entity }

            class_eval(&block) unless block.nil?
          end
        end

        def new_finder(default_entity = [], filter = {}, &block)
          finder_class(default_entity, &block).new params: filter
        end

        describe "#property" do
          it "sets the property and works with eq predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: "Test 3"}]
            finder = new_finder entity, value_eq: "Test 1" do
              property :value, type: Types::String
            end

            expect(finder.result.map { |n| n[:value] }).to eq ["Test 1"]
          end

          it "sets the property and works with not_eq predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: "Test 3"}]
            finder = new_finder entity, value_not_eq: "Test 1" do
              property :value, type: Types::String
            end

            expect(finder.result.map { |n| n[:value] }).to eq ["Test 2", "Test 3"]
          end

          it "sets the property and works with blank predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: ""}, {id: 4, value: "Test 4"}]
            finder = new_finder entity, value_blank: true do
              property :value, type: Types::String
            end

            expect(finder.result.map { |n| n[:id] }).to eq [3]
          end

          it "sets the property and works with not_blank predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: ""}, {id: 4, value: "Test 4"}]
            finder = new_finder entity, value_not_blank: true do
              property :value, type: Types::String
            end

            expect(finder.result.map { |n| n[:id] }).to eq [1, 2, 4]
          end

          it "sets the property and works gt (greater than) predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: ""}, {id: 4, value: "Test 4"}]
            finder = new_finder entity, id_gt: 1 do
              property :id, type: Types::String
            end

            expect(finder.result.map { |n| n[:id] }).to eq [2, 3, 4]
          end

          it "sets the property and works gte (greater than or equal to) predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: ""}, {id: 4, value: "Test 4"}]
            finder = new_finder entity, id_gte: 2 do
              property :id, type: Types::String
            end

            expect(finder.result.map { |n| n[:id] }).to eq [2, 3, 4]
          end

          it "sets the property and works lt (less than) predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: ""}, {id: 4, value: "Test 4"}]
            finder = new_finder entity, id_lt: 4 do
              property :id, type: Types::String
            end

            expect(finder.result.map { |n| n[:id] }).to eq [1, 2, 3]
          end

          it "sets the property and works lte (lesss than or equal to) predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: ""}, {id: 4, value: "Test 4"}]
            finder = new_finder entity, id_lte: 3 do
              property :id, type: Types::String
            end

            expect(finder.result.map { |n| n[:id] }).to eq [1, 2, 3]
          end

          it "sets the property and works lte (lesss than or equal to) predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: ""}, {id: 4, value: "Test 4"}]
            finder = new_finder entity, id_ltse: 3 do
              property :id, type: Types::String
            end

            expect(finder.result.map { |n| n[:id] }).to eq [1, 2, 3, 4]
          end

          it "sets the property and works with cont predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "None 2"}, {id: 3, value: "Test 3"}]
            finder = new_finder entity, value_cont: "Test" do
              property :value, type: Types::String
            end

            expect(finder.result.map { |n| n[:value] }).to eq ["Test 1", "Test 3"]
          end

          it "sets the property and works with not_cont predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "None 2"}, {id: 3, value: "Test 3"}]
            finder = new_finder entity, value_not_cont: "Test" do
              property :value, type: Types::String
            end

            expect(finder.result.map { |n| n[:value] }).to eq ["None 2"]
          end

          it "sets the property and works with sw predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "None 2"}, {id: 3, value: "Testical 3"}]
            finder = new_finder entity, value_sw: "Test" do
              property :value, type: Types::String
            end

            expect(finder.result.map { |n| n[:value] }).to eq ["Test 1", "Testical 3"]
          end

          it "sets the property and works with not_sw predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "None 2"}, {id: 3, value: "ATest 3"}]
            finder = new_finder entity, value_not_sw: "Test" do
              property :value, type: Types::String
            end

            expect(finder.result.map { |n| n[:value] }).to eq ["None 2", "ATest 3"]
          end

          it "sets the property and works with ew predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "None 1"}, {id: 3, value: "Test 3"}]
            finder = new_finder entity, value_ew: "1" do
              property :value, type: Types::String
            end

            expect(finder.result.map { |n| n[:value] }).to eq ["Test 1", "None 1"]
          end

          it "sets the property and works with not_ew predicate" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "None 1"}, {id: 3, value: "ATest 3"}]
            finder = new_finder entity, value_not_ew: "1" do
              property :value, type: Types::String
            end

            expect(finder.result.map { |n| n[:value] }).to eq ["ATest 3"]
          end
        end

        describe "#paging" do
          it "sets the paging values and shows only the first page results" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: "Test 3"}]
            finder = new_finder entity do
              paging per_page: 2, min_per_page: 1, max_per_page: 5
              property :value, type: Types::String
            end

            expect(finder.result.map { |n| n[:value] }).to eq ["Test 1", "Test 2"]
          end
        end

        describe "#sorting" do
          it "sets the property and works with eq predicate and sorting" do
            entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 1"}, {id: 3, value: "Test 3"}]
            finder = new_finder entity, value_eq: "Test 1", sort: "id desc" do
              property :value, type: Types::String, sortable: true
              property :id, type: Types::Integer, sortable: true
            end

            expect(finder.result.map { |n| n[:id] }).to eq [2, 1]
          end

          it "sets the property and works with eq predicate and sorting by multiple columns" do
            entity = [{id: 1, value: "Test 1", slug: 4}, {id: 2, value: "Test 2", slug: 1}, {id: 3, value: "Test 1", slug: 2}]
            finder = new_finder entity, value_eq: "Test 1", sort: "slug asc, id desc" do
              property :value, type: Types::String, sortable: true
              property :id, type: Types::Integer, sortable: true
            end

            expect(finder.result.map { |n| n[:id] }).to eq [3, 1]
          end
        end

        describe "Predicates, Paging and Sorting together" do
          it "sets the property and works with eq predicate and paging" do
            entity = [
              {id: 1, value: "Test 1"},
              {id: 2, value: "Test 2"},
              {id: 3, value: "Test 1"},
              {id: 4, value: "Test 4"},
              {id: 5, value: "Test 1"}
            ]

            finder = new_finder entity, value_eq: "Test 1", sort: "id desc", page: 2 do
              paging per_page: 2, min_per_page: 1, max_per_page: 5
              property :value, type: Types::String, sortable: true
              property :id, type: Types::Integer, sortable: true
            end

            expect(finder.result.map { |n| n[:id] }).to eq [5]
            expect(finder.count).to eq 1
          end
        end
      end
    end
  end
end
