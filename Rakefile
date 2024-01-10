# frozen_string_literal: true

require "bundler/gem_tasks"
# Add minitest tasks
require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb", "test/**/*_spec.rb"]
  t.verbose = true
end

desc "Running Tests"
task default: %i[test]
