# Responsible for minting a new ORCID for the given payload.
module Orcid
  class ProfileCreationService

    def self.call(payload, config = {})
      new(config).call(payload)
    end

    attr_reader :token, :path, :headers
    def initialize(config = {})
      @token = config.fetch(:token) { Orcid.client_credentials_token('/orcid-profile/create') }
      @path = config.fetch(:path) { "v1.1/orcid-profile" }
      @headers = config.fetch(:headers) { default_headers }
    end

    def call(payload)
      response = deliver(payload)
      parse(response)
    end

    protected
    def deliver(body)
      token.post(path, body: body, headers: headers)
    end

    def parse(response)
      uri = URI.parse(response.headers.fetch(:location))
      uri.path.sub(/\A\//, "").split("/").first
    end

    def default_headers
      { "Accept" => 'application/xml', 'Content-Type'=>'application/vdn.orcid+xml' }
    end
  end
end
