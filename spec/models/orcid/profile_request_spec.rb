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

    context '#handle_profile_creation_response' do
      it 'should update local' do
        # Don't want to hit the database
        subject.should_receive(:update_column).with(:orcid_profile_id, orcid_profile_id)
        Orcid.should_receive(:connect_user_and_orcid_profile).with(user, orcid_profile_id)

        subject.handle_profile_creation_response(orcid_profile_id)
      end
    end

    context '#xml_payload' do
      it 'should be a parsable XML document' do
        expect {
          ActiveSupport::XmlMini.parse(subject.xml_payload)
        }.to_not raise_error
      end
    end

    context '#validate_before_run' do
      let(:orcid_profile) { double('Orcid Profile', to_param: orcid_profile_id) }

      context 'when no orcid profile has been assigned' do
        before { Orcid.should_receive(:profile_for).with(user).and_return(nil) }
        it 'should return true' do
          expect(subject.validate_before_run).to eq(true)
        end
      end

      context 'orcid_profile_id is set' do
        before { subject.orcid_profile_id = orcid_profile_id }

        it 'should return false' do
          expect(subject.validate_before_run).to eq(false)
        end

        it 'should set an error' do
          expect {
            subject.validate_before_run
          }.to change { subject.errors.full_messages.count }.by(1)
        end

      end

      context 'user has an orcid_profile' do
        before { Orcid.should_receive(:profile_for).with(user).and_return(orcid_profile) }

        it 'should return false' do
          expect(subject.validate_before_run).to eq(false)
        end

        it 'should set an error' do
          expect {
            subject.validate_before_run
          }.to change { subject.errors.full_messages.count }.by(1)
        end

      end
    end

    context '#run' do
      let(:profile_creation_service) { double('Profile Creation Service') }
      let(:profile_creation_responder) { double('Payload Creation Responder') }
      let(:payload_xml_builder) { double('Payload Xml Builder') }
      let(:before_run_validator) { double('Submission Guardian') }
      let(:xml_payload) { double('Xml Payload') }

      context 'with the submission guardian permitting the request' do
        before(:each) do
          before_run_validator.should_receive(:call).with(subject).
            and_return(true)
          payload_xml_builder.should_receive(:call).with(subject.attributes).
            and_return(xml_payload)
          profile_creation_service.should_receive(:call).with(xml_payload).
            and_return(orcid_profile_id)
          profile_creation_responder.should_receive(:call).with(orcid_profile_id)
        end

        it 'should run a request and handle the response' do
          subject.run(
            payload_xml_builder: payload_xml_builder,
            profile_creation_service: profile_creation_service,
            profile_creation_responder: profile_creation_responder,
            before_run_validator: before_run_validator
          )
        end
      end

      context 'with the submission guardian returning false' do
        before(:each) do
          before_run_validator.should_receive(:call).with(subject).
            and_return(false)
          payload_xml_builder.should_not_receive(:call)
          profile_creation_responder.should_not_receive(:call)
        end

        it 'should raise an exception' do
          subject.run(
            payload_xml_builder: payload_xml_builder,
            profile_creation_service: profile_creation_service,
            profile_creation_responder: profile_creation_responder,
            before_run_validator: before_run_validator
          )
        end
      end
    end
  end
end
