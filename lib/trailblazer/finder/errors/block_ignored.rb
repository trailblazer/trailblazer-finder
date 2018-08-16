module Trailblazer
  class Finder
    module Error
      class BlockIgnored < ArgumentError
        def initialize(message = "defined_by filter_by's don't accept blocks")
          super message
        end
      end
    end
  end
end
