# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

# Add minitest tasks
require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format documentation --format RspecJunitFormatter --out test-reports/spec.xml"
end

desc "Running Tests"
task default: %i[spec test]
