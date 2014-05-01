begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks


begin
  APP_RAKEFILE = File.expand_path('../spec/internal/Rakefile', __FILE__)
  load 'rails/tasks/engine.rake'
rescue LoadError
  puts "Unable to load all app tasks for #{APP_RAKEFILE}"
end

require 'engine_cart/rake_task'
require 'rspec/core/rake_task'

namespace :spec do
  RSpec::Core::RakeTask.new(:all) do
    ENV['COVERAGE'] = 'true'
  end
  desc 'Only run specs that do not require net connect'
  RSpec::Core::RakeTask.new(:offline) do |t|
    t.rspec_opts = '--tag ~requires_net_connect'
  end

  desc 'Only run specs that require net connect'
  RSpec::Core::RakeTask.new(:online) do |t|
    t.rspec_opts = '--tag requires_net_connect'
  end

  desc 'Run the Travis CI specs'
  task :travis do
    ENV['RAILS_ENV'] = 'test'
    ENV['SPEC_OPTS'] = '--profile 20'
    ENV['ORCID_APP_ID'] = 'bleck'
    ENV['ORCID_APP_SECRET'] = 'bleck'
    Rake::Task['engine_cart:clean'].invoke
    Rake::Task['engine_cart:generate'].invoke
    Rake::Task['spec:offline'].invoke
  end
end

begin
  Rake::Task['default'].clear
rescue RuntimeError
  # This isn't a big deal if we don't have a default
end

Rake::Task['spec'].clear

task spec: 'spec:offline'
task default: 'spec:travis'
