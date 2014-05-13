require 'fast_helper'
require 'orcid/remote/profile_creation_service'

module Orcid::Remote
  describe ProfileCreationService do
    Given(:payload) { %(<?xml version="1.0" encoding="UTF-8"?>) }
    Given(:config) { {token: token, headers: request_headers, path: 'path/to/somewhere' } }
    Given(:token) { double("Token", post: response) }
    Given(:minted_orcid) { '0000-0001-8025-637X' }
    Given(:request_headers) {
      { 'Content-Type' => 'application/vdn.orcid+xml', 'Accept' => 'application/xml' }
    }
    Given(:callback) { StubCallback.new }
    Given(:callback_config) { callback.configure(:orcid_email_already_exists) }

    Given(:response) {
      double("Response", headers: { location: File.join("/", minted_orcid, "orcid-profile") })
    }


    context 'with orcid created' do
      Given(:response) {
        double("Response", headers: { location: File.join("/", minted_orcid, "orcid-profile") })
      }
      When(:returned_value) { described_class.call(payload, config, &callback_config) }
      Then { returned_value.should eq(minted_orcid)}
      And { expect(callback.invoked).to eq [:success, minted_orcid] }
      And { token.should have_received(:post).with(config.fetch(:path), body: payload, headers: request_headers)}
    end

    context 'with orcid not created' do
      Given(:response) {
        double("Response", headers: { location: "" })
      }
      When(:returned_value) { described_class.call(payload, config, &callback_config) }
      Then { returned_value.should eq(false)}
      And { expect(callback.invoked).to eq [:failure] }
      And { token.should have_received(:post).with(config.fetch(:path), body: payload, headers: request_headers)}
    end

    context 'with requested email already existing' do
      before { token.should_receive(:post).and_raise(error) }
      Given(:token) { double('Token') }
      Given(:error_description) { described_class::USER_WITH_THIS_EMAIL_ALREADY_EXISTS }
      Given(:response) do
        double(
          'Response',
          :body => "<error-desc>#{error_description}</error-desc>",
          :parsed => true,
          :error= => true
        )
      end
      Given(:error) { ::OAuth2::Error.new(response) }
      When(:returned_value) { described_class.call(payload, config, &callback_config) }
      Then { returned_value.should eq(false) }
      And { expect(callback.invoked).to eq [:orcid_email_already_exists, error_description] }
    end

    context 'with another OAuth2 failure' do
      before { token.should_receive(:post).and_raise(error) }
      Given(:token) { double('Token') }
      Given(:error_description) { 'Something Else' }
      Given(:response) do
        double(
          'Response',
          :body => "<error-desc>#{error_description}</error-desc>",
          :parsed => true,
          :error= => true
        )
      end
      Given(:error) { ::OAuth2::Error.new(response) }
      When(:returned_value) { described_class.call(payload, config, &callback_config) }
      Then { expect(returned_value).to have_failed(OAuth2::Error) }
    end
  end
end
