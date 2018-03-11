require 'trailblazer/finder/adapters/active_record'
require 'trailblazer/finder/adapters/sequel'
require 'trailblazer/finder/adapters/data_mapper'
require 'trailblazer/finder/adapters/kaminari'
require 'trailblazer/finder/adapters/will_paginate'
require 'trailblazer/finder/adapters/friendly_id'

module Trailblazer
  class Finder
    # Adapters
    module Adapters
      def self.included(base)
        base.extend ClassMethods
      end

      # ClassMethods
      module ClassMethods
        def adapters(*mods)
          mods.each do |mod|
            include mod
          end
        end
      end
    end
  end
end
