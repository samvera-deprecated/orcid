require 'spec_helper'

module Orcid
  describe RemoteWorkService do
    let(:payload) { %(<?xml version="1.0" encoding="UTF-8"?>) }
    let(:token) { double("Token") }
    let(:orcid_profile_id) { '0000-0003-1495-7122' }
    let(:request_headers) { { 'Content-Type' => 'application/orcid+xml', 'Accept' => 'application/xml' } }
    let(:response) { double("Response", body: 'Body') }

    context '.call' do
      it 'instantiates and calls underlying instance' do
        token.should_receive(:request).
          with(:post, "v1.1/#{orcid_profile_id}/orcid-works/", body: payload, headers: request_headers).
          and_return(response)

        expect(
          described_class.call(
            orcid_profile_id,
            body: payload,
            request_method: :post,
            token: token,
            headers: request_headers
          )
        ).to eq(response.body)
      end
    end

  end
end
