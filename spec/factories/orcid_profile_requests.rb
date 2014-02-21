# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :orcid_profile_request, :class => 'Orcid::ProfileRequest' do
    association :user, strategy: :build_stubbed
    given_names 'All of the Names'
    family_name 'Under-the-sun'
    primary_email 'all-of-the-names@underthesun.com'
    primary_email_confirmation 'all-of-the-names@underthesun.com'
  end
end
