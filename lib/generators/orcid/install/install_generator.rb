require 'rails/generators'

module Orcid
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    class_option :devise, default: false, type: :boolean

    def install_devise_multi_auth
      if options[:devise]
        generate 'devise:multi_auth:install --install_devise'
      else
        generate 'devise:multi_auth:install'
      end
    end

    def install_migrations
      rake "orcid:install:migrations"
      rake "db:migrate"
    end

    def install_omniauth_strategies
      config_code = ", :omniauthable, :omniauth_providers => [:orcid]"
      insert_into_file 'app/models/user.rb', config_code, { :after => /:validatable/, :verbose => false }

      init_code = %(
        config.omniauth(:orcid, Orcid.provider.id, Orcid.provider.secret,
                        scope: Orcid.provider.authentication_scope,
                        client_options: {
                          site: Orcid.provider.site_url,
                          authorize_url: Orcid.provider.authorize_url,
                          token_url: Orcid.provider.token_url
                        }
                        )
      )
      insert_into_file 'config/initializers/devise.rb', init_code, {after: /Devise\.setup.*$/, verbose: true}
    end

    def mount_orcid_engine
      route 'mount Orcid::Engine => "/orcid"'
    end

    def install_initializer
      template 'orcid_initializer.rb.erb', 'config/orcid_initializer.rb'
    end

  end
end
