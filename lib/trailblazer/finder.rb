require "trailblazer/finder/version"
require "trailblazer/finder/errors/block_ignored"
require "trailblazer/finder/errors/invalid_defined_by_value"
require "trailblazer/finder/errors/invalid_number"
require "trailblazer/finder/errors/missing_entity_type"
require "trailblazer/finder/errors/with_ignored"
require "trailblazer/finder"
require "trailblazer/finder/utils/params"
require "trailblazer/finder/utils/parse"
require "trailblazer/finder/utils/string"
require "trailblazer/finder/utils/extra"
require "trailblazer/finder/utils/splitter"
require "trailblazer/finder/utils/deep_locate"
require "trailblazer/finder/base"
require "trailblazer/finder/find"
require "trailblazer/finder/filter"
require "trailblazer/finder/features"
require "trailblazer/finder/adapters"
require "trailblazer/finder/predicates"

# :nocov:
require "trailblazer/operation/finder" if Gem.loaded_specs.key?("trailblazer")
# :nocov:

module Trailblazer
  class Finder
    include Base
    include Filter
    include Features
    include Adapters
  end
end
