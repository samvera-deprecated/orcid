require 'fast_helper'
require 'oauth2/error'
require 'orcid/remote/work_service'

module Orcid::Remote
  describe WorkService do
    let(:payload) { %(<?xml version="1.0" encoding="UTF-8"?>) }
    let(:token) { double("Token") }
    let(:orcid_profile_id) { '0000-0003-1495-7122' }
    let(:request_headers) { { 'Content-Type' => 'application/orcid+xml', 'Accept' => 'application/xml' } }
    let(:response) { double("Response", body: 'Body') }

    context '.call' do
      let(:token) { double('Token', client: client, token: 'access_token', refresh_token: 'refresh_token')}
      let(:client) { double('Client', id: '123', site: 'URL', options: {})}
      it 'raises a more helpful message' do
        response = double("Response", status: '100', body: 'body')
        response.stub(:error=)
        response.stub(:parsed)
        token.should_receive(:request).and_raise(OAuth2::Error.new(response))

        expect {
          described_class.call(orcid_profile_id, token: token)
        }.to raise_error(Orcid::RemoteServiceError)
      end
      it 'instantiates and calls underlying instance' do
        token.should_receive(:request).
          with(:post, "v1.2/#{orcid_profile_id}/orcid-works/", body: payload, headers: request_headers).
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
