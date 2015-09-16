require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake/clean"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

CLEAN.include('pkg')
