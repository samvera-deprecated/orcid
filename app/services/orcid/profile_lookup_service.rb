module Orcid
  class ProfileLookupService
    class SearchResponse
      delegate :fetch, :has_key?, :[], to: :@attributes
      def initialize(attributes = {})
        @attributes = attributes.with_indifferent_access
      end
      def id
        @attributes.fetch(:id)
      end

      def label
        @attributes.fetch(:label)
      end
    end

    def self.call(query, config = {})
      new(config).call(query)
    end

    attr_reader :token, :path, :headers, :response_builder
    def initialize(config = {})
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

    def call(parameters)
      response = deliver(parameters)
      parse(response.body)
    end
    alias_method :search, :call

    protected
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
        emails = orcid_bio.fetch('contact-details').fetch('email').collect {|email| email.fetch('value') }
        label = "#{given_names} #{family_name}"
        label << " (" << emails.join(",") << ")" if emails.present?
        label << " [ORCID: #{identifier}]"

        returning_value << response_builder.new("id" => identifier, "label" => label)
      end
    end

  end
end
