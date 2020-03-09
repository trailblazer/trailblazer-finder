# frozen_string_literal: true

require_relative "process_adapters"
require_relative "process_predicates"
require_relative "process_paging"
require_relative "process_sorting"
require_relative "process_filters"

module Trailblazer
  class Finder
    module Activity
      # Process Activity
      class Process < Trailblazer::Activity::Railway
        step Subprocess(ProcessAdapters)
        step Subprocess(ProcessPredicates)
        step Subprocess(ProcessFilters)
        step Subprocess(ProcessPaging)
        step Subprocess(ProcessSorting)
      end
    end
  end
end
