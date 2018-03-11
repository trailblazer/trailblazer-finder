module Trailblazer
  class Finder
    module Error
      class MissingEntityType < ArgumentError
        def initialize(message = 'No Entity Type provided. Entity Type can be defined on a class level or passed as an option.')
          super message
        end
      end
    end
  end
end
