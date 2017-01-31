require 'orcid/remote/service'
require 'oauth2/error'
require 'nokogiri'
module Orcid
  module Remote
    # Responsible for minting a new ORCID for the given payload.
    class ProfileCreationService < Orcid::Remote::Service
      def self.call(payload, config = {}, &callback_config)
        new(config, &callback_config).call(payload)
      end

      attr_reader :token, :path, :headers
      def initialize(config = {}, &callback_config)
        super(&callback_config)
        @token = config.fetch(:token) { default_token }
        @path = config.fetch(:path) { 'v1.1/orcid-profile' }
        @headers = config.fetch(:headers) { default_headers }
      end

      def call(payload)
        response = deliver(payload)
        parse(response)
      rescue ::OAuth2::Error => e
        parse_exception(e)
      end

      protected

      def deliver(body)
        token.post(path, body: body, headers: headers)
      end

      def parse(response)
        uri = URI.parse(response.headers.fetch(:location))
        orcid_profile_id = uri.path.sub(/\A\//, '').split('/').first
        if orcid_profile_id
          callback(:success, orcid_profile_id)
          orcid_profile_id
        else
          callback(:failure)
          false
        end
      end

      def parse_exception(exception)
        doc = Nokogiri::XML.parse(exception.response.body)
        error_text = doc.css('error-desc').text
        if error_text.to_s.size > 0
          callback(:orcid_validation_error, error_text)
          false
        else
          fail exception
        end
      end

      def default_headers
        { 'Accept' => 'application/xml', 'Content-Type' => 'application/vdn.orcid+xml' }
      end

      def default_token
        Orcid.client_credentials_token('/orcid-profile/create')
      end
    end
  end
end
