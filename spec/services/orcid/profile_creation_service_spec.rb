require 'spec_helper'

describe Orcid::ProfileCreationService do
  let(:payload) { %(<?xml version="1.0" encoding="UTF-8"?>) }
  let(:config) { {token: token, headers: request_headers, path: 'path/to/somewhere' } }
  let(:token) { double("Token") }
  let(:minted_orcid) { '0000-0001-8025-637X' }
  let(:request_headers) {
    { 'Content-Type' => 'application/vdn.orcid+xml', 'Accept' => 'application/xml' }
  }
  let(:response) {
    double("Response", headers: { location: File.join("/", minted_orcid, "orcid-profile") })
  }

  subject { described_class.new(config) }

  context '.call' do
    it 'instantiates and calls underlying instance' do
      token.should_receive(:post).
        with(config.fetch(:path), body: payload, headers: request_headers).
        and_return(response)
      expect(described_class.call(payload, config)).to eq(minted_orcid)
    end
  end

end
