require "spec_helper"

module Trailblazer
  class Finder
    module Utils
      describe String do
        describe ".blank?" do
          it "checks if value is blank or nil" do
            expect(Finder::Utils::String.blank?("")).to eq true
            expect(Finder::Utils::String.blank?(nil)).to eq true
            expect(Finder::Utils::String.blank?("what")).to eq false
            expect(Finder::Utils::String.blank?(1)).to eq false
          end
        end

        describe ".numeric?" do
          it "checks if value is numeric" do
            expect(Finder::Utils::String.numeric?("")).to eq false
            expect(Finder::Utils::String.numeric?(nil)).to eq false
            expect(Finder::Utils::String.numeric?(1)).to eq true
            expect(Finder::Utils::String.numeric?(0)).to eq true
            expect(Finder::Utils::String.numeric?(1.00000)).to eq true
            expect(Finder::Utils::String.numeric?("1")).to eq true
          end
        end

        describe ".date?" do
          it "checks if value is a date" do
            expect(Finder::Utils::String.date?("2018-01-01")).to eq true
            expect(Finder::Utils::String.date?(nil)).to eq false
            expect(Finder::Utils::String.date?("random")).to eq false
            expect(Finder::Utils::String.date?(1)).to eq false
            expect(Finder::Utils::String.date?("2018/01/01")).to eq true
            expect(Finder::Utils::String.date?("2018.01.01")).to eq true
            expect(Finder::Utils::String.date?("21-12-2018")).to eq true
          end
        end

        describe ".to_date" do
          it "transforms a date like value to a valid date" do
            expect(Finder::Utils::String.to_date("28/09/2018")).to eq "2018-09-28"
            expect(Finder::Utils::String.to_date("2018/09/28")).to eq "2018-09-28"
            expect(Finder::Utils::String.to_date("28 september 2018")).to eq "2018-09-28"
            expect(Finder::Utils::String.to_date("third month of this year")).to eq nil
          end
        end

        describe ".camelize" do
          it "transforms a string by capatalizing each word's first letter" do
            expect(Finder::Utils::String.camelize(:paging)).to eq "Paging"
            expect(Finder::Utils::String.camelize(:some_random_test)).to eq "SomeRandomTest"
          end
        end

        describe ".underscore" do
          it "transforms a string by dividing words with underscores" do
            expect(Finder::Utils::String.underscore(:veryPopular)).to eq "very_popular"
            expect(Finder::Utils::String.underscore(:VeryPopular)).to eq "very_popular"
            expect(Finder::Utils::String.underscore(:SomethingveryPopularButRandom)).to eq "somethingvery_popular_but_random"
            expect(Finder::Utils::String.underscore("Very Popular")).to eq "very_popular"
          end
        end
      end
    end
  end
end
