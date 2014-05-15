require 'spec_helper'

describe 'Routes for Orcid::ProfileRequest' do
  routes { Orcid::Engine.routes }
  let(:persisted_profile) { Orcid::ProfileRequest.new(id: 2) }
  it 'generates a conventional URL' do
    expect(profile_request_path).
      to(eq('/orcid/profile_request'))
  end

  it 'treats the input profile_request as the :format parameter' do
    expect(profile_request_path(persisted_profile)).
      to(eq("/orcid/profile_request.#{persisted_profile.to_param}"))
  end
end
