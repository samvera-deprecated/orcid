require_dependency 'json'
require 'orcid/remote/service'
module Orcid::Remote
  class ProfileQueryService < Orcid::Remote::Service

    def self.call(query, config = {}, &callbacks)
      new(config, &callbacks).call(query)
    end

    attr_reader :token, :path, :headers, :response_builder, :query_builder
    def initialize(config = {}, &callbacks)
      super(&callbacks)
      @query_builder = config.fetch(:query_parameter_builder) { QueryParameterBuilder }
      @token = config.fetch(:token) { Orcid.client_credentials_token('/read-public') }
      @response_builder = config.fetch(:response_builder) { SearchResponse }
      @path = config.fetch(:path) { "v1.1/search/orcid-bio/" }
      @headers = config.fetch(:headers) {
        {
          :accept => 'application/orcid+json',
          'Content-Type'=>'application/orcid+xml'
        }
      }
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

    def issue_callbacks(search_results)
      if search_results.any?
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
      json = JSON.parse(document)

      json.fetch('orcid-search-results').fetch('orcid-search-result').each_with_object([]) do |result, returning_value|
        profile = result.fetch('orcid-profile')
        identifier = profile.fetch('orcid-identifier').fetch('path')
        orcid_bio = profile.fetch('orcid-bio')
        given_names = orcid_bio.fetch('personal-details').fetch('given-names').fetch('value')
        family_name = orcid_bio.fetch('personal-details').fetch('family-name').fetch('value')
        emails = []
        if contact_details = orcid_bio['contact-details']
          emails = (contact_details['email'] || []).collect {|email| email.fetch('value') }
        end
        label = "#{given_names} #{family_name}"
        label << " (" << emails.join(", ") << ")" if emails.any?
        label << " [ORCID: #{identifier}]"

        returning_value << response_builder.new("id" => identifier, "label" => label)
      end
    end

  end
end
