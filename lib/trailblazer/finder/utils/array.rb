# frozen_string_literal: true

module Trailblazer
  class Finder
    # Helper module
    module Utils
      module Array
        module_function

        # Read access by key, as the OpenStruct rows this used to return allowed.
        module Row
          def [](name)
            to_h[name.to_sym]
          end
        end

        # Rows sharing the same keys share one Data class.
        def convert_hashes_in_array_to_struct(hashes)
          types = {}
          hashes.map { |hash| (types[hash.keys] ||= Data.define(*hash.keys) { include Row }).new(**hash) }
        end
      end
    end
  end
end
