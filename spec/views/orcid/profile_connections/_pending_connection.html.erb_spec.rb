require 'spec_helper'

describe 'orcid/profile_connections/_pending_connection.html.erb' do
  Given(:profile) { double('Profile', orcid_profile_id: orcid_profile_id) }
  Given(:orcid_profile_id) { '123-456' }

  When(:rendered) do
    render(
      partial: 'orcid/profile_connections/pending_connection',
      object: profile
    )
  end

  Then do
    expect(rendered).to have_tag('.pending-connection') do
      with_tag('a.orcid-profile-id', text: orcid_profile_id)
      with_tag('a.find-out-more')
      with_tag('a.signin-via-orcid')
    end
  end

end
