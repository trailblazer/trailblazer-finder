require 'trailblazer/finder/features/paging'
require 'trailblazer/finder/features/sorting'
require 'trailblazer/finder/features/predicate'

module Trailblazer
  class Finder
    # Features
    module Features
      def self.included(base)
        base.extend ClassMethods
      end

      # ClassMethods
      module ClassMethods
        def features(*mods)
          mods.each do |mod|
            include mod
          end
        end
      end
    end
  end
end
