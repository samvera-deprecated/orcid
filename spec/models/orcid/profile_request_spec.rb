require 'spec_helper'

module Orcid
  describe ProfileRequest do
    let(:orcid_profile_id) { '0000-0001-8025-637X'}
    let(:user) { mock_model('User') }
    let(:attributes) {
      {
        user: user,
        given_names: 'Daffy',
        family_name: 'Duck',
        primary_email: 'daffy@duck.com'
      }
    }
    subject { described_class.new(attributes) }

    context '#find_by_user' do
      let!(:profile_request) { FactoryGirl.create(:orcid_profile_request) }
      it 'returns the profile request' do
        expect(described_class.find_by_user(profile_request.user)).to eq(profile_request)
      end

      it 'to return nil' do
        other_user = FactoryGirl.build_stubbed(:user)
        expect(described_class.find_by_user(other_user)).to be_nil
      end

    end

    context '#successful_profile_creation' do
      it 'should update profile request' do
        # Don't want to hit the database
        subject.should_receive(:update_column).with(:orcid_profile_id, orcid_profile_id)
        Orcid.should_receive(:connect_user_and_orcid_profile).with(user, orcid_profile_id)

        subject.successful_profile_creation(orcid_profile_id)
      end
    end

    context '#error_on_profile_creation' do
      it 'should update profile request' do
        error_message = '123'
        # Don't want to hit the database
        subject.should_receive(:update_column).with(:response_text, error_message)
        subject.should_receive(:update_column).with(:response_status, ProfileRequest::ERROR_STATUS)
        subject.error_on_profile_creation(error_message)
      end
    end

    context '#error_on_profile_creation?' do
      it 'should be true if there is a response text' do
        subject.response_status = ProfileRequest::ERROR_STATUS
        expect(subject.error_on_profile_creation?).to be_truthy
      end
    end
  end
end
