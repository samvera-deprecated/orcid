require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "spec/test_app_templates"

  def create_application_yml
    application_yml_file = File.expand_path("../../../../../config/application.yml", __FILE__)
    application_yml_example_file = File.expand_path("../../../../../config/application.yml.example", __FILE__)
    if File.exist?(application_yml_file)
      create_link 'config/application.yml', application_yml_file, symbolic:true
    else
      create_link 'config/application.yml', application_yml_example_file, symbolic:true
    end
  end

  def run_install_oricd
    generate 'orcid:install --devise --skip_application_yml '
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
