# frozen_string_literal: true

module Trailblazer
  class Finder
    module Helpers
      module Basic
        def paging
          return if @errors.any?
          return if @find.paging.empty?
          result = @find.paging
          result = Utils::Hash.remove_keys_from_hash(result, %i[handler max_per_page min_per_page])
          result[:page] = result[:page] || result.delete(:current_page) || result[:current_page]
          result
        end

        def params
          return @options[:params] if @errors.any?
          result = {}
          result = result.merge paging
          result = result.merge @find.params
          result[:sort] = sorting
          result
        end

        def filters
          @filters ||= @find.filters if @errors.empty?
        end

        def result
          @result ||= @errors.empty? ? fetch_result : {errors: @errors} if respond_to?(:fetch_result)
        end

        def result?
          return false if @errors.any?
          result.any?
        end

        def count
          return if @errors.any?
          @count ||= result.size
        end
      end
    end
  end
end
