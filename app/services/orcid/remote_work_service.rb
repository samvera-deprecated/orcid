module Orcid
  class RemoteWorkService
    def self.call(orcid_profile_id, options = {})
      new(orcid_profile_id, options).call
    end

    attr_reader :headers, :token, :orcid_profile_id, :body, :request_method, :path
    def initialize(orcid_profile_id, options = {})
      @orcid_profile_id = orcid_profile_id
      @request_method = options.fetch(:request_method) { :get }
      @body = options.fetch(:body) { "" }
      @token = options.fetch(:token) { Orcid.access_token_for(orcid_profile_id) }
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
    end

    def default_headers
      { 'Accept' => 'application/xml', 'Content-Type'=>'application/orcid+xml' }
    end

    def default_path
      "v1.1/#{orcid_profile_id}/orcid-works/"
    end

  end
end
