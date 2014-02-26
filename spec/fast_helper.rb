require 'rspec/given'
$LOAD_PATH << File.expand_path("../..", __FILE__)
require 'spec/support/stub_callback'

unless defined?(require_dependency)
  def require_dependency(*files)
    require *files
  end
end
