# frozen_string_literal: true

module Trailblazer
  class Finder
    module Helpers
      module Sorting
        def sorting
          return if @errors.any?
          return if @find.sorting.empty?

          @sorting ||= Utils::Hash.remove_keys_from_hash(@find.sorting, [:handler]).map { |r| r.join(" ") }.join(", ")
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
            params.merge! sort: sorting.gsub(
              /#{attribute} #{sort_direction_for(attribute)}/,
              "#{attribute} #{reverse_sort_direction_for(attribute)}"
            )
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
end
