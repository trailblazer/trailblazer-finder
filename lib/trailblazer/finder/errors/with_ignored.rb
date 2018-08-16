module Trailblazer
  class Finder
    module Error
      class WithIgnored < ArgumentError
        def initialize(message = "defined_by filter_by's don't accept :with")
          super message
        end
      end
    end
  end
end
