require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "spec/test_app_templates"

  def install_devise_multi_auth
    generate 'devise:multi_auth:install --install_devise'
  end

  def install_migrations
    rake "orcid:install:migrations"
  end

  def install_omniauth_strategies
    config_code = ", :omniauthable, :omniauth_providers => [:orcid]"
    insert_into_file 'app/models/user.rb', config_code, { :after => /:validatable *$/, :verbose => false }

    init_code = %(
      config.omniauth(:orcid, ENV['ORCID_APP_ID'], ENV['ORCID_APP_SECRET'],
                      scope: ENV['ORCID_APP_AUTHENTICATION_SCOPE'],
                      client_options: {
                        site: ENV['ORCID_SITE_URL'],
                        authorize_url: ENV['ORCID_AUTHORIZE_URL'],
                        token_url: ENV['ORCID_TOKEN_URL']
                      }
                      )
    )
    insert_into_file 'config/initializers/devise.rb', init_code, {after: /Devise\.setup.*$/, verbose: true}
  end

  def create_shims
    create_file 'app/assets/javascripts/jquery.js'
    create_file 'app/assets/javascripts/jquery_ujs.js'
    create_file 'app/assets/javascripts/turbolinks.js'
    copy_file "/Users/jfriesen/Repositories/orcid_integration/config/application.yml", 'config/application.yml'
  end

  def insert_home_route
    route 'root :to => "application#index"'
    content = %(
      def index
        render text: 'This page is left intentionally blank'
      end
    )
    inject_into_file 'app/controllers/application_controller.rb', content, after: '< ActionController::Base'
  end

  def mount_orcid_engine
    route 'mount Orcid::Engine => "/orcid"'
  end
end
