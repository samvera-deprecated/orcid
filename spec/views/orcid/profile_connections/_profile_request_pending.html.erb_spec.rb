require 'spec_helper'

describe 'orcid/profile_connections/_profile_request_pending.html.erb' do
  Given(:profile_request) { double('ProfileRequest', created_at: created_at) }
  Given(:created_at) { Date.today }

  When(:rendered) do
    render(
      partial: 'orcid/profile_connections/profile_request_pending',
      object: profile_request
    )
  end

  Then do
    expect(rendered).to have_tag('.profile-request-pending') do
      with_tag(
        'time',
        with: { datetime: created_at.in_time_zone.to_s },
        text: view.time_ago_in_words(created_at)
      )
    end
  end

end
