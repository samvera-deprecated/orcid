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
          with: { href: orcid.new_profile_connection_path(profile_connection: { text: default_search_text }) },
          text: t('orcid/profile_connection.look_up_your_existing_orcid', scope: 'helpers.label')
        )
        with_tag(
          'a',
          with: { class: 'orcid-on-demand' },
        )
        with_tag('form', with: { method: 'post', action: orcid.profile_connections_path }) do
          with_tag('label', text: t('orcid/profile_connection.orcid_profile_id', scope: 'helpers.label'))
          with_tag('input', with: { type: 'text', name: 'profile_connection[orcid_profile_id]' })
        end
      end
    )
  end
end
