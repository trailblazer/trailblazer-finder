# TODO: Clean this shit up
module Trailblazer
  class Finder
    # Helper module
    module Utils
      module Params
        module_function

        def stringify_keys(hash)
          hash = hash.to_unsafe_h if hash.respond_to? :to_unsafe_h
          Hash[(hash || {}).map { |k, v| [k.to_s, v] }]
        end

        def slice_keys(hash, keys)
          keys.each_with_object({}) do |key, memo|
            memo[key] = hash[key] if hash.key? key
          end
        end

        def normalize_params(defaults, filters, keys)
          (defaults || {}).merge(
            slice_keys(stringify_keys(filters || {}), keys || [])
          )
        end
      end
    end
  end
end
