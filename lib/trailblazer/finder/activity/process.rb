# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      # Process Activity
      module Process
        extend Trailblazer::Activity::Railway()

        step Subprocess(Process::Adapters), id: :process_adapters
        step Subprocess(Process::Predicates), id: :process_predicates
        step Subprocess(Process::Filters), id: :process_filters
        step Subprocess(Process::Paging), id: :process_paging
        step Subprocess(Process::Sorting), id: :process_sorting
      end
    end
  end
end
