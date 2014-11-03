require 'spec_helper'

describe 'orcid/profile_connections/_profile_request_in_error.html.erb' do
  Given(:profile_request) { Orcid::ProfileRequest.new(error_message: 'Ouch!', created_at: created_at) }
  Given(:created_at) { Date.today }

  When(:rendered) do
    render(
      partial: 'orcid/profile_connections/profile_request_in_error',
      object: profile_request
    )
  end

  Then do
    expect(rendered).to have_tag('.profile-request-error') do
      with_tag('.error-message', text: 'Ouch!')
      with_tag('.cancel-profile-request', with: { :href => orcid.profile_request_path, 'data-method' => 'delete' })
    end
  end

end
