# frozen_string_literal: true

require 'test_helper'

module Trailblazer
  class Finder::ConfigInheritanceTest < Minitest::TrailblazerTest
    def test_inherited_finder_config_independence
      # Define parent finder
      parent_finder = Class.new(Trailblazer::Finder) do
        paging per_page: 10, min_per_page: 5, max_per_page: 20
      end
      
      # Define first child finder and modify its paging
      child_finder_a = Class.new(parent_finder) do
        paging per_page: 30, min_per_page: 10, max_per_page: 50
      end
      
      # Define second child finder with no modifications
      child_finder_b = Class.new(parent_finder)
      
      # Verify configurations are independent
      assert_equal 30, child_finder_a.config.paging[:per_page]
      assert_equal 10, child_finder_b.config.paging[:per_page] # Should retain parent's value
      
      # Verify object IDs are different for the paging hashes
      refute_equal child_finder_a.config.paging.object_id, child_finder_b.config.paging.object_id
    end

    def test_inherited_finder_multiple_levels
      # Define parent finder
      parent_finder = Class.new(Trailblazer::Finder) do
        paging per_page: 10, min_per_page: 5, max_per_page: 20
      end
      
      # Define middle-level finder
      middle_finder = Class.new(parent_finder) do
        paging per_page: 15, min_per_page: 5, max_per_page: 20
      end
      
      # Define two child finders of the middle finder
      child_finder_1 = Class.new(middle_finder) do
        paging per_page: 30, min_per_page: 10, max_per_page: 50
      end
      
      child_finder_2 = Class.new(middle_finder)
      
      # Verify configurations are independent across multiple inheritance levels
      assert_equal 30, child_finder_1.config.paging[:per_page]
      assert_equal 15, child_finder_2.config.paging[:per_page]
      assert_equal 15, middle_finder.config.paging[:per_page]
      assert_equal 10, parent_finder.config.paging[:per_page]
    end
  end
end