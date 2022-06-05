# frozen_string_literal: true

require "spec_helper"

module Trailblazer
  class Finder
    module Utils
      RSpec.describe Splitter do
        describe ".initialize" do
          it "sets key and value" do
            splitter = described_class.new "attribute_eq", "value"
            expect(splitter.key).to eq "attribute_eq"
            expect(splitter.value).to eq "value"
          end
        end

        describe ".split_key" do
          it "checks if specified split key exists" do
            splitter = described_class.new "attribute_eq", "value"
            expect(splitter.split_key("random")).to eq false
            expect(splitter.split_key("eq")).to eq true
          end

          it "fills field value when split key exists" do
            splitter = described_class.new "attribute_eq", "value"
            splitter.split_key("eq")
            expect(splitter.field).to eq "attribute"
          end

          it "fills predicate value when split key exists" do
            splitter = described_class.new "attribute_eq", "value"
            splitter.split_key("eq")
            expect(splitter.predicate).to eq :eq
          end
        end
      end
    end
  end
end
