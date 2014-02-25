require 'spec_helper'

module Orcid
  if ! ENV['ORCID_EXISTING_PUB_EMAIL']
    Rails.logger.error("Please set ENV['ORCID_EXISTING_PUB_EMAIL'] to run these specs.")
  else
    describe 'profile connection feature', requires_net_connect: true do
      around(:each) do |example|
        WebMock.allow_net_connect!
        example.run
        WebMock.disable_net_connect!
      end

      Given(:user) { FactoryGirl.create(:user) }
      Given(:email) { ENV['ORCID_EXISTING_PUB_EMAIL'] }
      Given(:profile_connect) { ProfileConnection.new(user: user, email: email) }

      When(:profile_candidates) { profile_connect.orcid_profile_candidates }

      Then { expect(profile_candidates.count).to eq(1) }
      Then {
        expect(profile_candidates.first.orcid_profile_id).to eq(ENV['ORCID_EXISTING_PUB_PROFILE_ID'])
      }
    end
  end
end
