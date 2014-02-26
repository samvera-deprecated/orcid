require 'orcid/remote/service'
module Orcid::Remote
  # Responsible for minting a new ORCID for the given payload.
  class ProfileCreationService < Orcid::Remote::Service

    def self.call(payload, config = {}, &callback_config)
      new(config, &callback_config).call(payload)
    end

    attr_reader :token, :path, :headers
    def initialize(config = {}, &callback_config)
      super(&callback_config)
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
      if orcid_profile_id = uri.path.sub(/\A\//, "").split("/").first
        callback(:success, orcid_profile_id)
        orcid_profile_id
      else
        callback(:failure)
        false
      end
    end

    def default_headers
      { "Accept" => 'application/xml', 'Content-Type'=>'application/vdn.orcid+xml' }
    end
  end
end
