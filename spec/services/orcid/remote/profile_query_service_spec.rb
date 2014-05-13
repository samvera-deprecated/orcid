require 'fast_helper'
require 'orcid/remote/profile_query_service'
require 'ostruct'

module Orcid::Remote
  describe ProfileQueryService do
    Given(:parser) { double('Parser', call: parsed_response)}
    Given(:config) {
      {
        token: token,
        path: 'somehwere',
        headers: 'headers',
        parser: parser,
        query_parameter_builder: query_parameter_builder
      }
    }
    Given(:query_parameter_builder) { double('Query Builder') }
    Given(:response) { double("Response", body: 'Response Body') }
    Given(:token) { double("Token") }
    Given(:parameters) { double("Parameters") }
    Given(:normalized_parameters) { double("Normalized Parameters") }
    Given(:callback) { StubCallback.new }
    Given(:callback_config) { callback.configure(:found, :not_found) }
    Given(:parsed_response) { 'HELLO WORLD!' }

    context '.call' do
      before(:each) do
        query_parameter_builder.should_receive(:call).with(parameters).and_return(normalized_parameters)
        token.should_receive(:get).with(config[:path], headers: config[:headers], params: normalized_parameters).and_return(response)
      end
      When(:result) { described_class.call(parameters, config, &callback_config) }
      Then { expect(result).to eq(parsed_response) }
      And { expect(callback.invoked).to eq [:found, parsed_response] }
    end
  end
end
