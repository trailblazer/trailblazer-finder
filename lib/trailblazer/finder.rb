# frozen_string_literal: true

require "forwardable"
require "trailblazer"
require "dry-types"
require "ostruct"

require "trailblazer/finder/utils/array"
require "trailblazer/finder/utils/hash"
require "trailblazer/finder/utils/string"
require "trailblazer/finder/utils/splitter"
require "trailblazer/finder/utils/extra"
require "trailblazer/finder/adapters/active_record/predicates"
require "trailblazer/finder/adapters/active_record/paging"
require "trailblazer/finder/adapters/active_record/sorting"
require "trailblazer/finder/adapters/kaminari/paging"
require "trailblazer/finder/adapters/will_paginate/paging"
require "trailblazer/finder/adapters/sequel/predicates"
require "trailblazer/finder/adapters/sequel/paging"
require "trailblazer/finder/adapters/sequel/sorting"
require "trailblazer/finder/adapters/basic/predicates"
require "trailblazer/finder/adapters/basic/paging"
require "trailblazer/finder/adapters/basic/sorting"
require "trailblazer/finder/activities/prepare"
require "trailblazer/finder/activities/process"
require "trailblazer/finder/activities/find"
require "trailblazer/finder/helpers/basic"
require "trailblazer/finder/helpers/sorting"
require "trailblazer/finder/dsl"
require "trailblazer/finder/find"
require "trailblazer/finder/base"
require "trailblazer/operation/finder"

module Trailblazer
  class Finder
    DRY_TYPES_VERSION = Gem::Version.new(Dry::Types::VERSION)
    LEGACY_DRY_TYPES = DRY_TYPES_VERSION <= Gem::Version.new('1')
    module Types
      if LEGACY_DRY_TYPES
        include Dry::Types.module
      else
        include Dry.Types(default: :nominal)
      end
    end

    include Base
  end
end
