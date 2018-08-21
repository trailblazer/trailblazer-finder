require "spec_helper"

module Trailblazer
  class Finder # rubocop:disable Metrics/ClassLength
    describe Base do
      def define_finder_class(&block)
        Class.new(Trailblazer::Finder) do
          class_eval(&block)
        end
      end

      def finder_class(default_entity = [], &block)
        define_finder_class do
          entity { default_entity }

          if block.nil?
            filter_by :value do |entity, _attribute, value|
              entity.select { |v| v == value }
            end
          else
            class_eval(&block)
          end
        end
      end

      def new_finder(default_entity = [], filter = {}, &block)
        finder_class(default_entity, &block).new params: filter
      end

      it "can have its #initialize method overwritten" do
        finder = new_finder do
          attr_reader :initialized

          alias_method :initialized?, :initialized

          def initialize(filter = {})
            @initialized = true
            super filter
          end
        end

        expect(finder).to be_initialized
      end

      it "can have multiple subclasses" do
        finder_1 = new_finder [1, 2, 3], filter: 1 do
          filter_by :filter do |entity, _attribute, value|
            entity.select { |v| v == value }
          end
        end

        finder_2 = new_finder [1, 2, 3], other_filter: 1 do
          filter_by :other_filter do |entity, _attribute, value|
            entity.reject { |v| v == value }
          end
        end

        expect(finder_1.result).not_to eq finder_2.result
      end

      describe ".result" do
        it "returns only the filtered finder results" do
          finder = new_finder [1, 2, 3], value: 1
          expect(finder.result).to eq [1]
        end

        it "can apply several filters" do
          values = [1, 2, 3, 4, 5, 6, 7]
          finder = new_finder values, bigger_than: 3, odd: true do
            filter_by :bigger_than do |entity, _attribute, value|
              entity.select { |v| v > value }
            end

            filter_by :odd do |entity, _attribute, value|
              entity.select(&:odd?) if value
            end
          end

          expect(finder.result).to eq [5, 7]
        end

        it "ignores invalid filters" do
          finder = new_finder [1, 2, 3], invalid: "filter_by"
          expect(finder.result).to eq [1, 2, 3]
        end

        it "can be overwritten by overwriting #fetch_result" do
          finder = new_finder [1, 2, 3], value: 1 do
            filter_by :value do |entity, _attribute, value|
              entity.select { |v| v == value }
            end

            def fetch_result
              super.map { |v| "~#{v}~" }
            end
          end

          expect(finder.result).to eq ["~1~"]
        end

        it "applies to default filters" do
          finder = new_finder [1, 2, 3], value: 1 do
            filter_by :value do |entity, _attribute, value|
              entity.select { |v| v == value }
            end
          end
          expect(finder.result).to eq [1]
        end

        it "shows the all results if no paging options are specified" do
          entity = [
            {id: 1, value: "Test 1"},
            {id: 2, value: "Test 2"},
            {id: 3, value: "Test 1"},
            {id: 4, value: "Test 4"},
            {id: 5, value: "Test 1"},
            {id: 6, value: "Test 1"},
            {id: 7, value: "Test 2"},
            {id: 8, value: "Test 1"},
            {id: 9, value: "Test 4"},
            {id: 10, value: "Test 1"}
          ]

          finder = new_finder entity, value_cont: "Test", sort: "id desc" do
            property :value, type: Types::String, sortable: true
            property :id, type: Types::Integer, sortable: true
          end

          expect(finder.count).to eq 10
        end
      end

      describe ".result?" do
        it "has a result" do
          finder = new_finder [1, 2, 3], value: 1 do
            filter_by :value do |entity, _attribute, value|
              entity.select { |v| v == value }
            end
          end
          expect(finder.result?).to eq true
        end

        it "has no result" do
          finder = new_finder [1, 2, 3], value: 4 do
            filter_by :value do |entity, _attribute, value|
              entity.select { |v| v == value }
            end
          end
          expect(finder.result?).to eq false
        end
      end

      describe ".count" do
        it "can apply several filters and have a correct count" do
          values = [1, 2, 3, 4, 5, 6, 7]
          finder = new_finder values, bigger_than: 3, odd: true do
            filter_by :bigger_than do |entity, _attribute, value|
              entity.select { |v| v > value }
            end

            filter_by :odd do |entity, _attribute, value|
              entity.select(&:odd?) if value
            end
          end

          expect(finder.count).to eq 2
        end
      end

      describe ".params" do
        it "shows the default parameters when none are given" do
          entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: "Test 3"}]
          finder = new_finder entity do
            paging per_page: 2, min_per_page: 1, max_per_page: 5
            property :value, type: Types::String
          end

          expect(finder.params).to eq per_page: 2, page: 1, sort: nil
        end

        it "shows the parameters that are given" do
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

          expect(finder.result.map { |n| n[:id] }).to eq [1]
          expect(finder.params).to eq value_eq: "Test 1", sort: "id desc", page: 2, per_page: 2
        end
      end

      describe ".sorting" do
        it "shows the sorters that have been applied on the result" do
          entity = [
            {id: 1, value: "Test 1"},
            {id: 2, value: "Test 2"},
            {id: 3, value: "Test 1"},
            {id: 4, value: "Test 4"},
            {id: 5, value: "Test 1"}
          ]

          finder = new_finder entity, value_eq: "Test 1", sort: "value asc, id desc", page: 2 do
            paging per_page: 2, min_per_page: 1, max_per_page: 5
            property :value, type: Types::String, sortable: true
            property :id, type: Types::Integer, sortable: true
          end

          expect(finder.params).to eq value_eq: "Test 1", sort: "value asc, id desc", page: 2, per_page: 2
          expect(finder.sorting).to eq "value asc, id desc"
        end
      end

      describe ".filters" do
        it "shows the filters that have been applied on the result" do
          entity = [
            {id: 1, value: "Test 1"},
            {id: 2, value: "Test 2"},
            {id: 3, value: "Test 1"},
            {id: 4, value: "Test 4"},
            {id: 5, value: "Test 1"}
          ]

          finder = new_finder entity, value_eq: "Test 1", sort: "value asc, id desc", page: 2 do
            paging per_page: 2, min_per_page: 1, max_per_page: 5
            property :value, type: Types::String, sortable: true
            property :id, type: Types::Integer, sortable: true
          end

          expect(finder.params).to eq value_eq: "Test 1", sort: "value asc, id desc", page: 2, per_page: 2
          expect(finder.filters[:value_eq][:predicate]).to eq "eq"
        end
      end

      describe ".signal" do
        it "shows the end signal from the trailblazer activity" do
          entity = [
            {id: 1, value: "Test 1"},
            {id: 2, value: "Test 2"},
            {id: 3, value: "Test 1"},
            {id: 4, value: "Test 4"},
            {id: 5, value: "Test 1"}
          ]

          finder = new_finder entity, value_eq: "Test 1", sort: "value asc, id desc", page: 2 do
            paging per_page: 2, min_per_page: 1, max_per_page: 5
            property :value, type: Types::String, sortable: true
            property :id, type: Types::Integer, sortable: true
          end

          expect(finder.params).to eq value_eq: "Test 1", sort: "value asc, id desc", page: 2, per_page: 2
          expect(finder.signal.to_json).to include("success")
        end
      end

      describe ".sort?" do
        it "returns if an attribute is sorted on or not" do
          entity = [
            {id: 1, value: "Test 1"},
            {id: 2, value: "Test 2"},
            {id: 3, value: "Test 1"},
            {id: 4, value: "Test 4"},
            {id: 5, value: "Test 1"}
          ]

          finder = new_finder entity, value_eq: "Test 1", sort: "value asc", page: 2 do
            paging per_page: 2, min_per_page: 1, max_per_page: 5
            property :value, type: Types::String, sortable: true
            property :id, type: Types::Integer, sortable: true
          end

          expect(finder.params).to eq value_eq: "Test 1", sort: "value asc", page: 2, per_page: 2
          expect(finder.sort?(:id)).to eq false
          expect(finder.sort?(:value)).to eq true
        end
      end

      describe ".sort_direction_for" do
        it "shows the sort direction for an attribute" do
          entity = [
            {id: 1, value: "Test 1"},
            {id: 2, value: "Test 2"},
            {id: 3, value: "Test 1"},
            {id: 4, value: "Test 4"},
            {id: 5, value: "Test 1"}
          ]

          finder = new_finder entity, value_eq: "Test 1", sort: "value asc, id desc", page: 2 do
            paging per_page: 2, min_per_page: 1, max_per_page: 5
            property :value, type: Types::String, sortable: true
            property :id, type: Types::Integer, sortable: true
          end

          expect(finder.params).to eq value_eq: "Test 1", sort: "value asc, id desc", page: 2, per_page: 2
          expect(finder.sort_direction_for(:id)).to eq "desc"
          expect(finder.sort_direction_for(:value)).to eq "asc"
        end
      end

      describe ".reverse_sort_direction_for" do
        it "shows the reversed sort direction for an attribute" do
          entity = [
            {id: 1, value: "Test 1"},
            {id: 2, value: "Test 2"},
            {id: 3, value: "Test 1"},
            {id: 4, value: "Test 4"},
            {id: 5, value: "Test 1"}
          ]

          finder = new_finder entity, value_eq: "Test 1", sort: "value asc, id desc", page: 2 do
            paging per_page: 2, min_per_page: 1, max_per_page: 5
            property :value, type: Types::String, sortable: true
            property :id, type: Types::Integer, sortable: true
          end

          expect(finder.params).to eq value_eq: "Test 1", sort: "value asc, id desc", page: 2, per_page: 2
          expect(finder.reverse_sort_direction_for(:id)).to eq "asc"
          expect(finder.reverse_sort_direction_for(:value)).to eq "desc"
        end
      end

      describe ".sort_params_for" do
        it "returns the sort parameters for a requested attribute (added to existing ones)" do
          entity = [
            {id: 1, value: "Test 1"},
            {id: 2, value: "Test 2"},
            {id: 3, value: "Test 1"},
            {id: 4, value: "Test 4"},
            {id: 5, value: "Test 1"}
          ]

          finder = new_finder entity, value_eq: "Test 1", sort: "value asc", page: 2 do
            paging per_page: 2, min_per_page: 1, max_per_page: 5
            property :value, type: Types::String, sortable: true
            property :id, type: Types::Integer, sortable: true
          end

          expect(finder.params).to eq value_eq: "Test 1", sort: "value asc", page: 2, per_page: 2
          expect(finder.sort_params_for(:id)[:sort]).to eq "value asc, id desc"
          expect(finder.sort_params_for(:value)[:sort]).to eq "value desc"
        end

        it "returns the sort parameters for a requested attribute (when none existed)" do
          entity = [
            {id: 1, value: "Test 1"},
            {id: 2, value: "Test 2"},
            {id: 3, value: "Test 1"},
            {id: 4, value: "Test 4"},
            {id: 5, value: "Test 1"}
          ]

          finder = new_finder entity, value_eq: "Test 1", page: 2 do
            paging per_page: 2, min_per_page: 1, max_per_page: 5
            property :value, type: Types::String, sortable: true
            property :id, type: Types::Integer, sortable: true
          end

          expect(finder.params).to eq value_eq: "Test 1", sort: nil, page: 2, per_page: 2
          expect(finder.sort_params_for(:id)[:sort]).to eq "id desc"
          expect(finder.sort_params_for(:value)[:sort]).to eq "value desc"
        end
      end

      describe ".new_sort_params_for" do
        it "returns the sort parameters for a requested attribute while cleaning old ones" do
          entity = [
            {id: 1, value: "Test 1"},
            {id: 2, value: "Test 2"},
            {id: 3, value: "Test 1"},
            {id: 4, value: "Test 4"},
            {id: 5, value: "Test 1"}
          ]

          finder = new_finder entity, value_eq: "Test 1", sort: "value asc", page: 2 do
            paging per_page: 2, min_per_page: 1, max_per_page: 5
            property :value, type: Types::String, sortable: true
            property :id, type: Types::Integer, sortable: true
          end

          expect(finder.params).to eq value_eq: "Test 1", sort: "value asc", page: 2, per_page: 2
          expect(finder.new_sort_params_for(:id)[:sort]).to eq "id desc"
        end
      end

      describe ".remove_sort_params_for" do
        it "returns the sort parameters for a requested attribute while cleaning old ones" do
          entity = [
            {id: 1, value: "Test 1"},
            {id: 2, value: "Test 2"},
            {id: 3, value: "Test 1"},
            {id: 4, value: "Test 4"},
            {id: 5, value: "Test 1"}
          ]

          finder = new_finder entity, value_eq: "Test 1", sort: "value asc, id desc", page: 2 do
            paging per_page: 2, min_per_page: 1, max_per_page: 5
            property :value, type: Types::String, sortable: true
            property :id, type: Types::Integer, sortable: true
          end

          expect(finder.params).to eq value_eq: "Test 1", sort: "value asc, id desc", page: 2, per_page: 2
          expect(finder.remove_sort_params_for(:id)[:sort]).to eq "value asc"
        end
      end
    end
  end
end
