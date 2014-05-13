require 'spec_helper'

describe 'orcid/profile_connections/_authenticated_connection.html.erb' do
  Given(:profile) { double('Profile', orcid_profile_id: orcid_profile_id) }
  Given(:orcid_profile_id) { '123-456' }

  When(:rendered) do
    render(
      partial: 'orcid/profile_connections/authenticated_connection',
      object: profile
    )
  end

  Then do
    expect(rendered).to have_tag('.authenticated-connection') do
      with_tag('a.orcid-profile-id', text: orcid_profile_id)
    end
  end

end
