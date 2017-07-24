require 'orcid/exceptions'
module Orcid
  class Configuration
    # Responsible for negotiating the retrieval of Orcid provider information.
    # Especially important given that you have private auth keys.
    # Also given that you may want to request against the sandbox versus the
    # production Orcid service.
    class Provider
      attr_reader :store
      def initialize(store = ::ENV)
        @store = store
      end

      # See http://tools.ietf.org/html/draft-ietf-oauth-v2-10#section-3 for
      # how to formulate scopes
      attr_writer :authentication_scope
      def authentication_scope
        @authentication_scope ||=
        store.fetch('ORCID_APP_AUTHENTICATION_SCOPE') do
          '/read-limited /activities/update'
        end
      end

      attr_writer :site_url
      def site_url
        @site_url ||= store.fetch('ORCID_SITE_URL') do
          'http://api.sandbox.orcid.org'
        end
      end

      attr_writer :token_url
      def token_url
        @token_url ||= store.fetch('ORCID_TOKEN_URL') do
          'https://api.sandbox.orcid.org/oauth/token'
        end
      end

      attr_writer :signin_via_json_url
      def signin_via_json_url
        @signin_via_json_url ||= store.fetch('ORCID_REMOTE_SIGNIN_URL') do
          'https://sandbox.orcid.org/signin/auth.json'
        end
      end

      attr_writer :host_url
      def host_url
        @host_url ||= store.fetch('ORCID_HOST_URL') do
          uri = URI.parse(signin_via_json_url)
          "#{uri.scheme}://#{uri.host}"
        end
      end

      attr_writer :authorize_url
      def authorize_url
        @authorize_url ||= store.fetch('ORCID_AUTHORIZE_URL') do
          'https://sandbox.orcid.org/oauth/authorize'
        end
      end

      attr_writer :id
      def id
        @id ||= store.fetch('ORCID_APP_ID')
      rescue KeyError
        raise ConfigurationError, 'ORCID_APP_ID'
      end

      attr_writer :secret
      def secret
        @secret ||= store.fetch('ORCID_APP_SECRET')
      rescue KeyError
        raise ConfigurationError, 'ORCID_APP_SECRET'
      end
    end
  end
end
