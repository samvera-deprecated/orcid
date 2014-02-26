require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "spec/test_app_templates"

  def run_install_oricd
    generate 'orcid:install --devise'
  end

  def create_shims
    create_file 'app/assets/javascripts/jquery.js'
    create_file 'app/assets/javascripts/jquery_ujs.js'
    create_file 'app/assets/javascripts/turbolinks.js'
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
end
