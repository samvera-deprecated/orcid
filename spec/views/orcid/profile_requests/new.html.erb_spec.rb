require 'spec_helper'

describe 'orcid/profile_requests/new.html.erb' do
  let(:profile_request) { FactoryGirl.build(:orcid_profile_request) }
  it 'renders a form' do
    view.stub(:profile_request).and_return(profile_request)
    render
    expect(rendered).to have_tag('form.new_profile_request', with: {method: :post}) do
      with_tag('fieldset') do
        with_tag('input', with: {name: 'profile_request[given_names]'})
        with_tag('input', with: {name: 'profile_request[family_name]'})
        with_tag('input', with: {name: 'profile_request[primary_email]'})
        with_tag('input', with: {name: 'profile_request[primary_email_confirmation]'})
      end
      with_tag('input', with: {type: 'submit'})
    end
  end
end
