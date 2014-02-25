require 'rspec/given'
require File.expand_path('../support/stub_callback', __FILE__)


unless defined?(require_dependency)
  def require_dependency(*files)
    require *files
  end
end
