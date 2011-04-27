require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'jasmine'
load 'jasmine/tasks/jasmine.rake'

desc "Run RSpec"
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

task :default => [:spec, "jasmine:ci"]
