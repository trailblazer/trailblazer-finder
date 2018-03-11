require 'spec_helper'

module Trailblazer
  class Finder
    module Utils
      describe Extra do
        describe '.deep_copy' do
          it 'returns a deep copy on the given object' do
            original = {
              array: [1, 2, 3],
              hash: { key: 'value' },
              boolean: true,
              number: 1,
              null: nil
            }

            deep_copy = Finder::Utils::Extra.deep_copy(original)

            original[:array][0] = 42
            original[:hash][:key] = 'other value'

            expect(deep_copy).to eq(
              array: [1, 2, 3],
              hash: { key: 'value' },
              boolean: true,
              number: 1,
              null: nil
            )
          end
        end

        describe '.ensure_included' do
          it 'works' do
            str = Utils::Extra.ensure_included '1 2'.to_s.split(' ', 2).last, %w[1]
            expect(str).to eq('1')
          end
        end
      end
    end
  end
end
