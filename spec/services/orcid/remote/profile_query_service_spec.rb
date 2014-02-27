require 'fast_helper'
require 'orcid/remote/profile_query_service'
require 'ostruct'

module Orcid::Remote
  describe ProfileLookupService do
    Given(:email) { 'corwin@amber.gov' }
    Given(:orcid_profile_id) { '0001-0002' }
    Given(:config) {
      {
        token: token,
        path: 'somehwere',
        headers: 'headers',
        response_builder: OpenStruct,
        query_parameter_builder: query_parameter_builder
      }
    }
    Given(:query_parameter_builder) { double('Query Builder')}
    Given(:response) { double("Response", body: response_body)} # See below
    Given(:token) { double("Token") }
    Given(:json_response) { [ OpenStruct.new({ 'id' => orcid_profile_id, 'label' => "Corwin Amber (#{email}) [ORCID: #{orcid_profile_id}]" }) ] }
    Given(:parameters) { double("Parameters") }
    Given(:normalized_parameters) { double("Normalized Parameters") }
    Given(:callback) { StubCallback.new }
    Given(:callback_config) { callback.configure(:found, :not_found) }

    context '.call' do
      before(:each) do
        query_parameter_builder.should_receive(:call).with(parameters).and_return(normalized_parameters)
        token.should_receive(:get).with(config[:path], headers: config[:headers], params: normalized_parameters).and_return(response)
      end
      When(:result) { described_class.call(parameters, config, &callback_config) }
      Then { expect(result).to eq(json_response) }
      And { expect(callback.invoked).to eq [:found, json_response] }
    end

    Given(:response_body) {
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
