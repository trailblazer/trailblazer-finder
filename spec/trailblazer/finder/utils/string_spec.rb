# frozen_string_literal: true

require "spec_helper"

module Trailblazer
  class Finder
    module Utils
      describe String do
        describe ".blank?" do
          it "checks if value is blank or nil" do
            expect(described_class.blank?("")).to eq true
            expect(described_class.blank?(nil)).to eq true
            expect(described_class.blank?("what")).to eq false
            expect(described_class.blank?(1)).to eq false
          end
        end

        describe ".numeric?" do
          it "checks if value is numeric" do
            expect(described_class.numeric?("")).to eq false
            expect(described_class.numeric?(nil)).to eq false
            expect(described_class.numeric?(1)).to eq true
            expect(described_class.numeric?(0)).to eq true
            expect(described_class.numeric?(1.00000)).to eq true
            expect(described_class.numeric?("1")).to eq true
          end
        end

        describe ".date?" do
          it "checks if value is a date" do
            expect(described_class.date?("2018-01-01")).to eq true
            expect(described_class.date?(nil)).to eq false
            expect(described_class.date?("random")).to eq false
            expect(described_class.date?(1)).to eq false
            expect(described_class.date?("2018/01/01")).to eq true
            expect(described_class.date?("2018.01.01")).to eq true
            expect(described_class.date?("21-12-2018")).to eq true
            expect(described_class.date?("0fae2de1-6537-4d36-9cdb-30edf1e37990")).to eq false
          end
        end

        describe ".to_date" do
          it "transforms a date like value to a valid date" do
            expect(described_class.to_date("28/09/2018")).to eq "2018-09-28"
            expect(described_class.to_date("2018/09/28")).to eq "2018-09-28"
            expect(described_class.to_date("28 september 2018")).to eq "2018-09-28"
            expect(described_class.to_date("third month of this year")).to eq nil
          end
        end

        describe ".camelize" do
          it "transforms a string by capatalizing each word's first letter" do
            expect(described_class.camelize(:paging)).to eq "Paging"
            expect(described_class.camelize(:some_random_test)).to eq "SomeRandomTest"
          end
        end

        describe ".underscore" do
          it "transforms a string by dividing words with underscores" do
            expect(described_class.underscore(:veryPopular)).to eq "very_popular"
            expect(described_class.underscore(:VeryPopular)).to eq "very_popular"
            expect(described_class.underscore(:SomethingveryPopularButRandom)).to eq "somethingvery_popular_but_random"
            expect(described_class.underscore("Very Popular")).to eq "very_popular"
          end
        end
      end
    end
  end
end
