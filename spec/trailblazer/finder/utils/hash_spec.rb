require "spec_helper"

module Trailblazer
  class Finder
    module Utils
      describe Hash do
        let(:hash) do
          [{id: 1, value: "Test 1"}, {id: 2, value: "Test 2"}, {id: 3, value: ""}, {id: 4, value: "Test 4"}]
        end

        describe ".deep_locate" do
          it "locates enumerables for which the given comparator returns true for at least one element" do
            expect(Utils::Hash.deep_locate(->(k, v, _) { k == :value && v.to_s == "Test 2" && !v.nil? }, hash))
              .to eq [{id: 2, value: "Test 2"}]
          end
        end

        it "returns an empty array if nothing was found" do
          expect(Utils::Hash.deep_locate(:muff, foo: "bar")).to eq([])
        end
      end
    end
  end
end
