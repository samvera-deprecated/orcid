require 'spec_helper'
require 'orcid/remote/profile_query_service'
require 'ostruct'

module Orcid::Remote
  describe ProfileQueryService do
    Given(:parser) { double('Parser', call: parsed_response)}
    Given(:config) {
      {
        token: token,
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
      context 'with at least one found' do
        before(:each) do
          query_parameter_builder.should_receive(:call).with(parameters).and_return(normalized_parameters)
          token.should_receive(:get).with(kind_of(String), headers: kind_of(Hash), params: normalized_parameters).and_return(response)
        end
        When(:result) { described_class.call(parameters, config, &callback_config) }
        Then { expect(result).to eq(parsed_response) }
        And { expect(callback.invoked).to eq [:found, parsed_response] }
      end

      context 'with no objects found' do
        before(:each) do
          query_parameter_builder.should_receive(:call).with(parameters).and_return(normalized_parameters)
          token.should_receive(:get).with(kind_of(String), headers: kind_of(Hash), params: normalized_parameters).and_return(response)
        end
        When(:parsed_response) { '' }
        When(:result) { described_class.call(parameters, config, &callback_config) }
        Then { expect(result).to eq(parsed_response) }
        And { expect(callback.invoked).to eq [:not_found] }

      end
    end
  end
end
