require_dependency 'json'
require 'orcid/remote/service'
module Orcid
  module Remote
    # Responsible for querying Orcid to find various ORCiDs
    class ProfileQueryService < Orcid::Remote::Service
      def self.call(query, config = {}, &callbacks)
        new(config, &callbacks).call(query)
      end

      attr_reader :token, :path, :headers, :response_builder, :query_builder
      attr_reader :parser
      def initialize(config = {}, &callbacks)
        super(&callbacks)
        @query_builder = config.fetch(:query_parameter_builder) { QueryParameterBuilder }
        @token = config.fetch(:token) { default_token }
        @parser = config.fetch(:parser) { ResponseParser }
        @path = config.fetch(:path) { 'v1.2/search/orcid-bio/' }
        @headers = config.fetch(:headers) { default_headers }
      end

      def call(input)
        parameters = query_builder.call(input)
        response = deliver(parameters)
        parsed_response = parse(response.body)
        issue_callbacks(parsed_response)
        parsed_response
      end
      alias_method :search, :call

      protected

      def default_token
        Orcid.client_credentials_token('/read-public')
      end

      def default_headers
        { :accept => 'application/orcid+json', 'Content-Type' => 'application/orcid+xml' }
      end

      def issue_callbacks(search_results)
        if Array.wrap(search_results).any?(&:present?)
          callback(:found, search_results)
        else
          callback(:not_found)
        end
      end

      attr_reader :host, :access_token
      def deliver(parameters)
        token.get(path, headers: headers, params: parameters)
      end

      def parse(document)
        parser.call(document)
      end

    end
  end
end
