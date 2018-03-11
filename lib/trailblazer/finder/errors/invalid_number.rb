module Trailblazer
  class Finder
    module Error
      class InvalidNumber < ArgumentError
        attr_reader :field, :number

        def initialize(field, number)
          @field  = field
          @number = number

          super "#{field} should be more than 0. Currently '#{number}' is given."
        end
      end
    end
  end
end
