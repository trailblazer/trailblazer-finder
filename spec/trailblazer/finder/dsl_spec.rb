# frozen_string_literal: true

require "spec_helper"

module Trailblazer
  class Finder # rubocop:disable Metrics/ClassLength
    describe Dsl do
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

      describe "entity" do
        def empty_finder_class
          define_finder_class do
            filter_by :name do
            end
          end
        end

        it "accepts entity as argument" do
          expect(finder_class.new(entity: "entity").result).to eq "entity"
        end

        it "raises an error if no entity is provided" do
          expect(empty_finder_class.new.errors).to eq [{entity: "Invalid entity specified"}]
        end

        it "can overwrite the finder entity" do
          finder_class = define_finder_class do
            entity { "entity" }
          end

          expect(finder_class.new(entity: "other entity").result).to eq "other entity"
        end

        it "passing nil as entity in constructor, falls back to default entity" do
          finder_class = define_finder_class do
            entity { "entity" }
          end

          expect(finder_class.new(entity: nil).result).to eq "entity"
        end
      end

      describe "#adapters" do
        it "checks for a valid adapter and returns an error" do
          entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: "Test 3"}]
          finder = new_finder entity, value_eq: "Test 1" do
            adapters :NonExisting
          end

          expect(finder.errors).to eq [{adapters: "One or more of the specified adapters are invalid"}]
        end

        it "checks if multiple orm adapters are requested and returns an error" do
          entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: "Test 3"}]
          finder = new_finder entity, value_eq: "Test 1" do
            adapters :ActiveRecord, :Sequel
          end

          expect(finder.errors).to eq [{adapters: "More then one ORM adapter specified"}]
        end

        it "sets the adapter in the config" do
          entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: "Test 3"}]
          finder = new_finder entity, value_eq: "Test 1" do
            adapters ActiveRecord
            property :value, type: Base
          end

          expect(finder.class.config[:adapters]).to eq ["ActiveRecord"]
        end
      end

      describe "#property" do
        it "checks for a valid property type and returns an error" do
          entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: "Test 3"}]
          finder = new_finder entity, value_eq: "Test 1" do
            property :value, type: Base
          end

          expect(finder.errors).to eq [{properties: "One or more properties are missing a valid type"}]
        end

        it "sets the property and it's type properly in the config" do
          entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: "Test 3"}]
          finder = new_finder entity, value_eq: "Test 1" do
            property :value, type: Base
          end

          expect(finder.class.config[:properties]).to eq value: {type: Trailblazer::Finder::Base}
        end
      end

      describe "#paging" do
        it "sets the paging values" do
          entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: "Test 3"}]
          finder = new_finder entity do
            paging per_page: 2, min_per_page: 1, max_per_page: 5
            property :value, type: Types::String
          end

          expect(finder.class.config[:paging][:per_page]).to eq 2
          expect(finder.class.config[:paging][:min_per_page]).to eq 1
          expect(finder.class.config[:paging][:max_per_page]).to eq 5
        end

        it "does not load paging stuff if paging isn't called in the finder class" do
          entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: "Test 3"}]
          finder = new_finder entity do
            property :value, type: Types::String
          end

          expect(finder.class.config[:paging]).to be_empty
        end
      end

      describe "#filter_by" do
        it "returns an error when supplied with a non symbol" do
          entity = [1, 2, 3]
          finder = new_finder entity, value_test: "some" do
            filter_by :value_test, with: "test"
          end

          expect(finder.result).to eq errors: [{filters: "One or more filters are missing a with method definition"}]
        end

        it "has a default filter" do
          entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: "Test 3"}]
          finder = new_finder entity, value: "Test 1" do
            filter_by :value
          end

          expect(finder.result.map { |n| n[:value] }).to eq ["Test 1"]
        end

        it "has a default filter working when it's nested" do
          entity = [{id: 1, value: [id: 4, value: "Test 1"]}, {id: 2, value: "Test 2"}, {id: 3, value: "Test 3"}]
          finder = new_finder entity, value: "Test 1" do
            filter_by :value
          end

          expect(finder.result.map { |n| n[:value] }).to eq ["Test 1"]
          expect(finder.result.map { |n| n[:id] }).to eq [4]
        end

        it "has another default filter" do
          entity = [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: "Test 3"}]
          finder = new_finder entity, id: 2 do
            filter_by :id
          end

          expect(finder.result.map { |n| n[:value] }).to eq ["Test 2"]
        end

        it "returns the entity if nil is returned" do
          entity = [1, 2, 3]
          finder = new_finder entity, value_test: "some" do
            filter_by :value_test do
              nil
            end
          end

          expect(finder.result).to eq entity
        end

        it "can use methods from the object" do
          finder_1 = new_finder [1, 2, 3], filter: 1 do
            filter_by :filter do |entity, attribute, value|
              some_instance_method(entity, attribute, value)
            end

            private

            def some_instance_method(entity, _attribute, _value)
              entity - [2, 3]
            end
          end

          expect(finder_1.result).to eq [1]
        end

        it "can dispatch with instance methods" do
          finder = new_finder [1, 2, 3], filter: 1 do
            filter_by :filter, with: :some_instance_method

            private

            def some_instance_method(entity, _attribute, value)
              entity.select { |v| v == value }
            end
          end

          expect(finder.result).to eq [1]
        end
      end
    end
  end
end
