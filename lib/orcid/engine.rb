module Orcid
  def self.table_name_prefix
    "orcid_"
  end

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
