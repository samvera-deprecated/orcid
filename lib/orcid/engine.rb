module Orcid
  class Engine < ::Rails::Engine
    isolate_namespace Orcid

    initializer 'orcid.initializers' do |app|
      app.config.paths.add 'app/services', eager_load: true
      app.config.paths.add 'app/runners', eager_load: true
      app.config.autoload_paths += %W(
        #{config.root}/app/services
        #{config.root}/app/runners
      )
    end

  end
end
