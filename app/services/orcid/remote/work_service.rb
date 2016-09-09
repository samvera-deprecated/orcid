require 'orcid/exceptions'
module Orcid
  module Remote
    # Responsible for interacting with the Orcid works endpoint
    class WorkService
      def self.call(orcid_profile_id, options = {})
        new(orcid_profile_id, options).call
      end

      attr_reader(
        :headers, :token, :orcid_profile_id, :body, :request_method, :path
      )
      def initialize(orcid_profile_id, options = {})
        @orcid_profile_id = orcid_profile_id
        @request_method = options.fetch(:request_method) { :get }
        @body = options.fetch(:body) { '' }
        @token = options.fetch(:token) { default_token }
        @headers = options.fetch(:headers) { default_headers }
        @path = options.fetch(:path) { default_path }
      end

      # :post will append works to the Orcid Profile
      # :put will replace the existing Orcid Profile works with the payload
      # :get will retrieve the Orcid Profile
      # http://support.orcid.org/knowledgebase/articles/177528-add-works-technical-developer
      def call
        response = deliver
        response.body
      end

      protected

      def deliver
        token.request(request_method, path, body: body, headers: headers)
      rescue OAuth2::Error => e
        handle_oauth_error(e)
      end

      def handle_oauth_error(e)
        fail Orcid::RemoteServiceError,
             response_body:    e.response.body,
             response_status:  e.response.status,
             client:           token.client,
             token:            token,
             request_method:   request_method,
             request_path:     path,
             request_body:     body,
             request_headers:  headers
      end

      def default_token
        Orcid.access_token_for(orcid_profile_id)
      end

      def default_headers
        { 'Accept' => 'application/xml', 'Content-Type' => 'application/orcid+xml' }
      end

      def default_path
        "v1.2/#{orcid_profile_id}/orcid-works/"
      end
    end
  end
end
