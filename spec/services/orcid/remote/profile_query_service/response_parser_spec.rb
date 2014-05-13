require 'ostruct'
require 'spec_helper'
require 'orcid/remote/profile_query_service/response_parser'

module Orcid
  module Remote
    class ProfileQueryService
      describe ResponseParser do
        context '.call' do
          Given(:response_builder) { OpenStruct }
          Given(:logger) { double(warn: true) }
          Given(:document) do
            File.read(fixture_file(File.join('orcid-remote-profile_query_service-response_parser',response_filename)))
          end
          Given(:subject) { described_class.new(response_builder: response_builder, logger: logger) }

          context 'happy path' do
            let(:response_filename) { 'single-response-with-orcid-valid-profile.json' }
            When(:response) { subject.call(document) }
            Then do
              response.should eq(
                [
                  response_builder.new(
                    id: "MY-ORCID-PROFILE-ID",
                    label: "Corwin Amber (MY-ORCID-EMAIL) [ORCID: MY-ORCID-PROFILE-ID]",
                    biography:"MY-ORCID-BIOGRAPHY"
                  )
                ]
              )
            end
          end

          context 'unhappy path' do
            let(:response_filename) { 'multiple-responses-without-valid-response.json' }
            When(:response) { subject.call(document) }
            Then { response.should eq [] }
            And { logger.should have_received(:warn).at_least(1).times }
          end
        end
      end
    end
  end
end
