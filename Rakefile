# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format documentation --format RspecJunitFormatter --out test-reports/spec.xml"
end

desc "Running Tests"
task default: %i[spec]
