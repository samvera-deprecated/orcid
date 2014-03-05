require 'spec_helper'

module Orcid
  describe 'connect to a publicly visible profile', requires_net_connect: true do
    around(:each) do |example|
      WebMock.allow_net_connect!
      example.run
      WebMock.disable_net_connect!
    end

    Given(:user) { FactoryGirl.create(:user) }
    Given(:text) { '"Jeremy Friesen"' }
    Given(:profile_connect) { ProfileConnection.new(user: user, text: text) }

    When(:profile_candidates) { profile_connect.orcid_profile_candidates }

    Then { expect(profile_candidates.count).to be > 1 }
  end
end
