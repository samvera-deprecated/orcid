require 'spec_helper'
require 'ostruct'

module Orcid
  describe ProfileLookupService do
    let(:email) { 'corwin@amber.gov' }
    let(:orcid_profile_id) { '0001-0002' }
    let(:config) { { token: token, path: 'somehwere', headers: 'headers', response_builder: OpenStruct } }
    let(:response) { double("Response", body: response_body)} # See below
    let(:token) { double("Token") }
    let(:json_response) { [ OpenStruct.new({ 'id' => orcid_profile_id, 'label' => "Corwin Amber (#{email}) [ORCID: #{orcid_profile_id}]" }) ] }
    let(:parameters) { {q: "email:#{email}"} }

    context '.call' do
      it 'should return a JSON object' do
        token.should_receive(:get).with(config[:path], headers: config[:headers], params: parameters).and_return(response)
        expect(described_class.call(parameters, config)).to eq(json_response)
      end
    end


    let(:response_body) {
      %(
        {
          "message-version": "1.1",
          "orcid-search-results": {
            "orcid-search-result": [
              {
                "relevancy-score": {
                  "value": 14.298138
                },
                "orcid-profile": {
                  "orcid": null,
                  "orcid-identifier": {
                    "value": null,
                    "uri": "http://orcid.org/#{orcid_profile_id}",
                    "path": "#{orcid_profile_id}",
                    "host": "orcid.org"
                  },
                  "orcid-bio": {
                    "personal-details": {
                      "given-names": {
                        "value": "Corwin"
                      },
                      "family-name": {
                        "value": "Amber"
                      }
                    },
                    "biography": {
                      "value": "King of Amber",
                      "visibility": null
                    },
                    "contact-details": {
                      "email": [
                        {
                          "value": "#{email}",
                          "primary": true,
                          "current": true,
                          "verified": true,
                          "visibility": null,
                          "source": null
                        }
                      ],
                      "address": {
                        "country": {
                          "value": "US",
                          "visibility": null
                        }
                      }
                    },
                    "keywords": {
                      "keyword": [
                        {
                          "value": "Lord of Amber"
                        }
                      ],
                      "visibility": null
                    },
                    "delegation": null,
                    "applications": null,
                    "scope": null
                  },
                  "orcid-activities": {
                    "affiliations": null
                  },
                  "type": null,
                  "group-type": null,
                  "client-type": null
                }
              }
            ],
            "num-found": 1
          }
        }
      )
    }
  end
end
