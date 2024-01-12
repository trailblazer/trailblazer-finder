# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
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
