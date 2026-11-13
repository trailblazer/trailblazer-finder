# frozen_string_literal: true

module Trailblazer
  class Finder

    module Base
      def self.included(base)
        base.include Helpers::Basic
        base.include Helpers::Sorting
        base.extend Dsl
      end

      attr_reader :signal, :errors

      def initialize(options = {}) # rubocop:disable Style/OptionHash
        result = Activities::Find.(config: self.class.config, options: options)
        @signal = result.terminus
        @options = options
        @errors = result[:errors] || {}
        @find = result[:finder]
      end

      def fetch_result
        result = @find.query self
        result = Utils::Array.convert_hashes_in_array_to_struct(result) if result.first.is_a?(Hash)
        result
      end
    end
  end
end
