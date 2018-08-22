require "forwardable"
require "trailblazer-activity"
require "dry-types"
require "ostruct"

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
require "trailblazer/finder/activity/prepare/entity"
require "trailblazer/finder/activity/prepare/properties"
require "trailblazer/finder/activity/prepare/filters"
require "trailblazer/finder/activity/prepare/params"
require "trailblazer/finder/activity/prepare/adapters"
require "trailblazer/finder/activity/prepare/paging"
require "trailblazer/finder/activity/prepare/sorting"
require "trailblazer/finder/activity/prepare"
require "trailblazer/finder/activity/process/adapters"
require "trailblazer/finder/activity/process/predicates"
require "trailblazer/finder/activity/process/paging"
require "trailblazer/finder/activity/process/sorting"
require "trailblazer/finder/activity/process/filters"
require "trailblazer/finder/activity/process"
require "trailblazer/finder/activity/find"
require "trailblazer/finder/dsl"
require "trailblazer/finder/find"
require "trailblazer/finder/base"

# :nocov:
require "trailblazer/operation/finder" if Gem.loaded_specs.key?("trailblazer")
# :nocov:

module Trailblazer
  class Finder
    module Types
      include Dry::Types.module
    end

    include Base
  end
end
