# frozen_string_literal: true

require "forwardable"
require "trailblazer"
require "dry-types"
require "ostruct"

require_relative "finder/utils/array"
require_relative "finder/utils/hash"
require_relative "finder/utils/string"
require_relative "finder/utils/splitter"
require_relative "finder/utils/extra"
require_relative "finder/adapters/active_record/predicates"
require_relative "finder/adapters/active_record/paging"
require_relative "finder/adapters/active_record/sorting"
require_relative "finder/adapters/kaminari/paging"
require_relative "finder/adapters/will_paginate/paging"
require_relative "finder/adapters/sequel/predicates"
require_relative "finder/adapters/sequel/paging"
require_relative "finder/adapters/sequel/sorting"
require_relative "finder/adapters/basic/predicates"
require_relative "finder/adapters/basic/paging"
require_relative "finder/adapters/basic/sorting"
require_relative "finder/activities/prepare"
require_relative "finder/activities/process"
require_relative "finder/activities/find"
require_relative "finder/helpers/basic"
require_relative "finder/helpers/sorting"
require_relative "finder/dsl"
require_relative "finder/find"
require_relative "finder/base"
require_relative "operation/finder"

module Trailblazer
  class Finder
    module Types
      include Dry.Types(default: :nominal)
    end
    EXT_ORM_ADAPTERS = Types::Strict::String.enum("ActiveRecord", "Sequel")
    ORM_ADAPTERS = EXT_ORM_ADAPTERS | Types::Strict::String.enum("Basic")
    PAGING_ADAPTERS = Types::Strict::String.enum("Kaminari", "WillPaginate")

    include Base
  end
end
