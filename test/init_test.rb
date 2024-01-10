# frozen_string_literal: true

require 'test_helper'
class InitTest < Minitest::TrailblazerTest
  def test_that_it_has_a_version_number
    refute_nil ::Trailblazer::Finder::VERSION
  end
end
