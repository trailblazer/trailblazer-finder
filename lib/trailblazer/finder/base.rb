# frozen_string_literal: true

module Trailblazer
  class Finder
    ORM_ADAPTERS = %w[ActiveRecord Sequel].freeze
    PAGING_ADAPTERS = %w[Kaminari WillPaginate].freeze

    module Base
      def self.included(base)
        base.extend Finder::Dsl
      end

      attr_reader :signal, :errors, :result, :filters

      def initialize(options = {}) # rubocop:disable Style/OptionHash
        config = self.class.config
        ctx = {config: config, options: options}
        @signal, (ctx, *) = Activity::Find.call([ctx, {}])
        @options = options
        @errors = ctx[:errors] || {}
        @find = ctx[:finder]
        @result = @errors.empty? ? fetch_result : {errors: @errors}
        @filters = @find.filters if @errors.empty?
      end

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

      def result?
        return false if @errors.any?
        result.any?
      end

      def fetch_result
        result = @find.query self
        result
      end

      def count
        return if @errors.any?
        @count ||= result.length
      end

      def sorting
        return if @errors.any?
        return if @find.sorting.empty?
        result = @find.sorting
        result = Utils::Hash.remove_keys_from_hash(result, [:handler])
        result.map { |r| r.join(" ") }.join(", ")
      end

      def sort?(attribute)
        sorting.include?(attribute.to_s)
      end

      def sort_direction_for(attribute)
        return "asc" if (!sorting.nil? && sorting.include?("#{attribute} asc")) || @find.config[:sorting][attribute.to_sym] == :asc
        "desc"
      end

      def reverse_sort_direction_for(attribute)
        return "desc" if (!sorting.nil? && sorting.include?("#{attribute} asc")) || @find.config[:sorting][attribute.to_sym] == :asc
        "asc"
      end

      def sort_params_for(attribute)
        if sorting.nil?
          params.merge! sort: "#{attribute} #{sort_direction_for(attribute)}"
        elsif sorting.include?(attribute.to_s)
          params.merge! sort: sorting.gsub(/#{attribute} #{sort_direction_for(attribute)}/, "#{attribute} #{reverse_sort_direction_for(attribute)}")
        else
          params.merge! sort: "#{sorting}, #{attribute} #{sort_direction_for(attribute)}"
        end
      end

      def remove_sort_params_for(attribute)
        return unless sorting.include?(attribute.to_s)
        sort = sorting.gsub(/#{attribute} #{sort_direction_for(attribute)}/, "").split(",")
        sort.delete_if(&:blank?)
        params.merge! sort: sort.join(",")
      end

      def new_sort_params_for(attribute)
        params.merge! sort: "#{attribute} #{sort_direction_for(attribute)}"
      end
    end
  end
end
