# frozen_string_literal: true

module Trailblazer
  class Finder
    module Activities
      class PreparePaging < Trailblazer::Activity::Railway
        def check_paging(ctx, **)
          paging = ctx[:config][:paging] || nil
          return false if ctx[:config][:paging].empty? || paging.nil?

          true
        end

        def set_paging(ctx, **)
          ctx[:paging] = ctx.dig(:config,:paging) || {}
          ctx[:paging][:current_page] = ctx.dig(:params,:page) || 1
          return true unless ctx[:params][:per_page]

          ctx[:paging][:per_page] = ctx[:params][:per_page].to_i || ctx[:paging][:per_page]
          ctx[:paging][:per_page] = ctx[:paging][:max_per_page] if ctx[:paging][:per_page] > ctx[:paging][:max_per_page]
          ctx[:paging][:per_page] = ctx[:paging][:min_per_page] if ctx[:paging][:per_page] < ctx[:paging][:min_per_page]
          true
        end

        def clear_paging(ctx, **)
          ctx[:params].delete(:page) unless ctx[:params][:page].nil?
          true
        end

        step :check_paging, Output(:failure) => Track(:end_paging)
        step :set_paging
        step :clear_paging, magnetic_to: :end_paging
      end
    end
  end
end
