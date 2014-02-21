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

    attr_writer :app_authentication_scope
    def app_authentication_scope
      @app_authentication_scope ||= store.fetch('ORCID_APP_AUTHENTICATION_SCOPE')
    end

    attr_writer :app_site_url
    def app_site_url
      @app_site_url ||= store.fetch('ORCID_SITE_URL')
    end

    attr_writer :app_token_url
    def app_token_url
      @app_token_url ||= store.fetch('ORCID_TOKEN_URL')
    end

    attr_writer :app_authorize_url
    def app_authorize_url
      @app_authorize_url ||= store.fetch('ORCID_AUTHORIZE_URL')
    end

    attr_writer :app_id
    def app_id
      @app_id ||= store.fetch('ORCID_APP_ID')
    end

    attr_writer :app_secret
    def app_secret
      @app_secret ||= store.fetch('ORCID_APP_SECRET')
    end

    attr_writer :app_host
    def app_host
      @app_host ||= store.fetch('ORCID_SITE_URL')
    end
  end
end