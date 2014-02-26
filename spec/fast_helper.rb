require 'rspec/given'
Dir[File.expand_path("../../app/*", __FILE__)].each do |dir|
  $LOAD_PATH << dir
end
$LOAD_PATH << File.expand_path("../../lib", __FILE__)
require File.expand_path('../support/stub_callback', __FILE__)

unless defined?(require_dependency)
  def require_dependency(*files)
    require *files
  end
end
