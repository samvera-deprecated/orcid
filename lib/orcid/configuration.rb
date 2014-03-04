module Orcid
  class Configuration
    attr_reader :mapper
    def initialize(options = {})
      @mapper = options.fetch(:mapper) {
        require 'mappy'
        ::Mappy
      }
      @provider = options.fetch(:provider) {
        require 'orcid/configuration/provider'
        Provider.new
      }
      @authentication_model = options.fetch(:authentication_model) {
        require 'devise-multi_auth'
        ::Devise::MultiAuth::Authentication
      }
      @parent_controller = options.fetch(:parent_controller) { '::ApplicationController' }
    end

    attr_accessor :provider
    attr_accessor :authentication_model
    attr_accessor :parent_controller

    def register_mapping_to_orcid_work(source_type, legend)
      mapper.configure do |config|
        config.register(source: source_type, target: 'orcid/work', legend: legend)
      end
    end
  end
end
