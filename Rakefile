begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

require 'engine_cart/rake_task'

require 'rspec/core/rake_task'

desc 'Run rspec tasks'
RSpec::Core::RakeTask.new(:spec)
