module Orcid
  # Responsible for exposing the customization mechanism
  class Configuration
    attr_reader :mapper
    def initialize(options = {})
      @mapper = options.fetch(:mapper) { default_mapper }
      @provider = options.fetch(:provider) { default_provider }
      @authentication_model = options.fetch(:authentication_model) do
        default_authenticaton_model
      end
      @parent_controller = options.fetch(:parent_controller) do
        '::ApplicationController'
      end
    end

    attr_accessor :provider
    attr_accessor :authentication_model
    attr_accessor :parent_controller

    def register_mapping_to_orcid_work(source_type, legend)
      mapper.configure do |config|
        config.register(
          source: source_type,
          target: 'orcid/work',
          legend: legend
        )
      end
    end

    protected

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
