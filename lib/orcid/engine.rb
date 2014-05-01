# The namespace for all things related to Orcid integration
module Orcid
  module_function

  # As per an isolated_namespace Rails engine.
  # But the isolated namespace creates issues.
  # @api private
  def table_name_prefix
    'orcid_'
  end

  # Because I am not using isolate_namespace for Orcid::Engine
  # I need this for the application router to find the appropriate routes.
  # @api private
  def use_relative_model_naming?
    true
  end

  # While not an isolated namespace engine
  # @See http://guides.rubyonrails.org/engines.html
  class Engine < ::Rails::Engine
    engine_name 'orcid'

    initializer 'orcid.initializers' do |app|
      app.config.paths.add 'app/services', eager_load: true
      app.config.autoload_paths += %W(
        #{config.root}/app/services
      )
    end
  end
end
