require 'spec_helper'

describe 'orcid/profile_connections/_options_to_connect_orcid_profile.html.erb' do
  let(:default_search_text) { '' }
  it 'renders a form' do
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
          with: { href: orcid.new_profile_request_path },
          text: t('orcid/profile_connection.create_an_orcid', scope: 'helpers.label')
        )
        with_tag('form', with: { method: 'post', action: orcid.profile_connections_path }) do
          with_tag('label', text: t('orcid/profile_connection.orcid_profile_id', scope: 'helpers.label'))
          with_tag('input', with: { type: 'text', name: 'profile_connection[orcid_profile_id]' })
        end
      end
    )
  end
end
