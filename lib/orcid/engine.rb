module Orcid
  class Engine < ::Rails::Engine
    isolate_namespace Orcid

    initializer 'orcid.initializers' do |app|
      app.config.paths.add 'app/services', eager_load: true
      app.config.autoload_paths += %W(
        #{config.root}/app/services
      )
    end

  end
end
