# The namespace for all things related to Orcid integration
module Orcid

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
