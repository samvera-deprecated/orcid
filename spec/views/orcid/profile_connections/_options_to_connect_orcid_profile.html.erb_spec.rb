require 'spec_helper'

describe 'orcid/profile_connections/_options_to_connect_orcid_profile.html.erb', type: :view do
  let(:default_search_text) { '' }
  let(:user) {FactoryGirl.create(User)}

  it 'renders a form' do
    allow(view).to receive(:current_user).and_return(user)
    render
    expect(rendered).to(
      have_tag('.options-to-connect-orcid-profile') do
        with_tag(
          'a',
          with: { id: "connect-orcid-link"}
        )
      end
    )
  end
end
