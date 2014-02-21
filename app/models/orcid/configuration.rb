module Orcid
  class Configuration
    attr_reader :store
    def initialize(store = ::ENV)
      @store = store
    end

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