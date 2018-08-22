# frozen_string_literal: true

module Trailblazer
  class Finder
    # Helper module
    module Utils
      module Array
        module_function

        def convert_hashes_in_array_to_struct(hash)
          result = []
          hash.each do |h|
            result << (OpenStruct.new h)
          end
          result
        end
      end
    end
  end
end
