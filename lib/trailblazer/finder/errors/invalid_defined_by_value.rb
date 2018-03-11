module Trailblazer
  class Finder
    module Error
      class InvalidDefinedByValue < ArgumentError
        def initialize(filter_by, defined_bys, value)
          super "Invalid value '#{value}' used for defined_by #{filter_by} (expected one of #{defined_bys.join(', ')})"
        end
      end
    end
  end
end
