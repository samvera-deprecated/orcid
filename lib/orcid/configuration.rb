module Orcid
  class Configuration
    attr_reader :mapper
    def initialize(options = {})
      @mapper = options.fetch(:mapper) { ::Mappy }
      @provider = Configuration::Provider.new
    end

    attr_reader :provider

    attr_writer :provider_name
    def provider_name
      @provider_name ||= 'orcid'
    end

    attr_writer :authentication_model
    def authentication_model
      @authentication_model ||= Devise::MultiAuth::Authentication
    end

  end
end
require 'orcid/configuration/provider'
