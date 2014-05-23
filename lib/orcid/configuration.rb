module Orcid
  # Responsible for exposing the customization mechanism
  class Configuration
    attr_reader :mapper
    def initialize(collaborators = {})
      @mapper = collaborators.fetch(:mapper) { default_mapper }
      @provider = collaborators.fetch(:provider) { default_provider }
      @authentication_model = collaborators.fetch(:authentication_model) { default_authenticaton_model }
      @parent_controller = collaborators.fetch(:parent_controller) { default_parent_controller }
    end

    attr_accessor :provider
    attr_accessor :authentication_model
    attr_accessor :parent_controller

    def register_mapping_to_orcid_work(source_type, legend)
      mapper.configure do |config|
        config.register(source: source_type, target: 'orcid/work', legend: legend)
      end
    end

    private

    def default_parent_controller
      '::ApplicationController'
    end

    def default_mapper
      require 'mappy'
      ::Mappy
    end

    def default_provider
      require 'orcid/configuration/provider'
      Provider.new
    end

    def default_authenticaton_model
      require 'devise-multi_auth'
      ::Devise::MultiAuth::Authentication
    end
  end
end
