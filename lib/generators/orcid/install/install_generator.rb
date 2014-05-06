require 'rails/generators'

module Orcid
  # If you want to quickly add Orcid integration into your application.
  # This assumes the use of the ubiqutous Devise gem.
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    class_option :devise, default: false, type: :boolean
    class_option :skip_application_yml, default: false, type: :boolean

    def create_application_yml
      unless options[:skip_application_yml]
        create_file 'config/application.yml' do
          orcid_app_id = ask('What is your Orcid Client ID?')
          orcid_app_secret = ask('What is your Orcid Client Secret?')
          [
            '',
            "ORCID_APP_ID: #{orcid_app_id}",
            "ORCID_APP_SECRET: #{orcid_app_secret}",
            ''
          ].join("\n")
        end
      end
    end

    def install_devise_multi_auth
      if options[:devise]
        generate 'devise:multi_auth:install --install_devise'
      else
        generate 'devise:multi_auth:install'
      end
    end

    def copy_locale
      copy_file(
        '../../../../../config/locales/orcid.en.yml',
        'config/locales/orcid.en.yml'
      )
    end

    def install_migrations
      rake 'orcid:install:migrations'
    end

    def update_devise_user
      config_code = ', :omniauthable, :omniauth_providers => [:orcid]'
      insert_into_file(
        'app/models/user.rb',
        config_code, after: /:validatable/, verbose: false
      )
    end

    def update_devise_omniauth_provider
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
      insert_into_file(
        'config/initializers/devise.rb',
        init_code, after: /Devise\.setup.*$/, verbose: true
      )
    end

    def mount_orcid_engine
      route 'mount Orcid::Engine => "/orcid"'
    end

    def migrate_the_database
      rake 'db:migrate'
    end

    def install_initializer
      template(
        'orcid_initializer.rb.erb',
        'config/initializers/orcid_initializer.rb'
      )
    end
  end
end
