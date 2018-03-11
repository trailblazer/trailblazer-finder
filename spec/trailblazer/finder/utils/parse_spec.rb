require 'spec_helper'

module Trailblazer
  class Finder
    module Utils
      describe Parse do
        describe '.parse_date' do
          it 'returns when value is a date' do
            expect(Finder::Utils::Parse.date('2018-01-01')).to eq '2018-01-01'
          end

          it 'returns when value is a screwed up date like 02-2018-01 10:10:10' do
            expect(Finder::Utils::Parse.date('02-2018-01 10:10')).to eq '2018-01-02'
          end

          it 'returns nil value is not date worthy' do
            expect(Finder::Utils::Parse.date('Unknown')).to eq nil
          end
        end

        describe '.escape_term' do
          it 'returns escaped value' do
            expect(Finder::Utils::Parse.term('term')).to eq '%term%'
          end

          it 'returns mutliple escaped values' do
            expect(Finder::Utils::Parse.term('term term')).to eq '%term%term%'
          end
        end
      end
    end
  end
end
