require_dependency './app/runners/orcid/runner'
module Orcid
  class ProfileLookupRunner < Runner

    def initialize(config = {}, &block)
      super(&block)
      @query_service = config.fetch(:query_service) { Remote::ProfileLookupService }
      @query_builder = config.fetch(:query_parameter_builder) {
        require_dependency 'orcid/query_parameter_builder'
        Orcid::QueryParameterBuilder
      }
    end
    attr_reader :query_service, :query_builder
    private :query_service, :query_builder

    def call(raw_parameters)
      query_parameters = query_builder.call(raw_parameters)
      response = query_service.call(query_parameters)
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
