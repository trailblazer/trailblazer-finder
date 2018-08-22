# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      module Prepare
        # Paging Activity
        module Paging
          extend Trailblazer::Activity::Railway()

          module_function

          def check_paging(ctx, **)
            paging = ctx[:config][:paging] || nil
            return false if ctx[:config][:paging].empty? || paging.nil?
            true
          end

          def set_paging(ctx, **)
            ctx[:paging] = ctx[:config][:paging] || {}
            ctx[:paging][:current_page] = ctx[:params][:page] || 1
            return true unless ctx[:params][:per_page]
            ctx[:paging][:per_page] = ctx[:params][:per_page].to_i || ctx[:paging][:per_page]
            ctx[:paging][:per_page] = ctx[:paging][:max_per_page] if ctx[:params][:per_page] > ctx[:paging][:max_per_page]
            ctx[:paging][:per_page] = ctx[:paging][:min_per_page] if ctx[:params][:per_page] < ctx[:paging][:min_per_page]
            true
          end

          def clear_paging(ctx, **)
            ctx[:params].delete(:page) unless ctx[:params][:page].nil?
            true
          end

          step method(:check_paging), id: :check_paging,
            Output(:success) => Track(:paging),
            Output(:failure) => Track(:end_paging)
          step method(:set_paging), id: :set_paging, magnetic_to: [:paging],
            Output(:success) => Track(:end_paging),
            Output(:failure) => Track(:failure)
          step method(:clear_paging), id: :clear_paging, magnetic_to: [:end_paging],
            Output(:success) => Track(:success),
            Output(:failure) => Track(:failure)
        end
      end
    end
  end
end
