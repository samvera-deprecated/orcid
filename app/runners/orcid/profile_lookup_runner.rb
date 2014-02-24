require 'orcid/named_callbacks'
module Orcid
  class ProfileLookupRunner

    def initialize(config = {})
      @callbacks = NamedCallbacks.new
      @query_service = config.fetch(:query_service) { ProfileLookupService }
      yield(@callbacks) if block_given?
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
    end

    def callback(name, *args)
      @callbacks.call(name, *args)
      args
    end
  end
end
