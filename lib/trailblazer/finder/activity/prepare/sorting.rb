# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activity
      module Prepare
        # Paging Activity
        module Sorting
          extend Trailblazer::Activity::Railway()

          module_function

          def check_sorting(ctx, **)
            sorting = ctx[:config][:sorting] || nil
            return true unless ctx[:config][:sorting].empty? || sorting.nil?
          end

          def set_sorting(ctx, **)
            return true if ctx[:params][:sort].nil?
            sorting = ctx[:params][:sort]
            config = ctx[:config][:sorting]
            ctx[:sorting] = ctx[:sorting] || {}
            sorting.split(",").each do |sorter|
              spt = sorter.split
              ctx[:sorting][spt[0]] = fetch_sort_direction(config[spt[0].to_sym], spt[1]) if config.include?(spt[0].to_sym)
            end
          end

          def fetch_sort_direction(config_direction, params_direction = nil)
            return config_direction == :asc ? :asc : :desc if params_direction.nil?
            case params_direction
              when ":asc", :asc, "asc" then :asc
              else :desc
            end
          end

          def clear_sorting(ctx, **)
            ctx[:params].delete(:sort) unless ctx[:params][:sort].nil?
            true
          end

          step method(:check_sorting), id: :check_sorting,
            Output(:success) => Track(:paging),
            Output(:failure) => Track(:end_sorting)
          step method(:set_sorting), id: :set_sorting, magnetic_to: [:paging],
            Output(:success) => Track(:end_sorting),
            Output(:failure) => Track(:failure)
          step method(:clear_sorting), id: :clear_sorting, magnetic_to: [:end_sorting],
            Output(:success) => Track(:success),
            Output(:failure) => Track(:failure)
        end
      end
    end
  end
end
