require_dependency './app/runners/orcid/runner'
module Orcid
  class ProfileLookupRunner < Runner

    def initialize(config = {}, &block)
      super(&block)
      @query_service = config.fetch(:query_service) { Remote::ProfileLookupService }
    end
    attr_reader :query_service
    private :query_service

    def call(parameters)
      email = parameters.fetch(:email)
      response = query_service.call({q: "email:#{email}"})
      handle(response)
    end

    private
    def handle(response)
      if response.any?
        callback(:found, response)
      else
        callback(:not_found)
      end
      response
    end

  end
end
