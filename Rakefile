begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks


begin
  APP_RAKEFILE = File.expand_path("../spec/internal/Rakefile", __FILE__)
  load 'rails/tasks/engine.rake'
rescue LoadError => e
  require 'byebug'; byebug; true;
  puts "Unable to load all app tasks for #{APP_RAKEFILE}"
end

require 'engine_cart/rake_task'
require 'rspec/core/rake_task'

namespace :spec do
  desc 'Only run specs that do not require net connect'
  RSpec::Core::RakeTask.new(:offline) do |t|
    t.rspec_opts = "--tag ~requires_net_connect"
  end

  desc 'Only run specs that require net connect'
  RSpec::Core::RakeTask.new(:online) do |t|
    t.rspec_opts = "--tag requires_net_connect"
  end

  desc 'Run the Travis CI specs'
  task :travis do
    ENV['RAILS_ENV'] = 'test'
    ENV['SPEC_OPTS'] = "--profile 20"
    Rake::Task['engine_cart:clean'].invoke
    Rake::Task['engine_cart:generate'].invoke
    Rake::Task['spec:offline'].invoke
  end
end
Rake::Task["default"].clear rescue nil
Rake::Task["spec"].clear

task :spec => 'spec:offline'
task :default => :spec