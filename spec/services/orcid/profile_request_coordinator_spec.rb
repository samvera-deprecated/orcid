require 'spec_helper'
require 'orcid/profile_request_coordinator'

module Orcid
  describe ProfileRequestCoordinator do
    before(:each) do
      profile_state_finder.stub(:call).and_yield(callback_responder)
    end
    Given(:logger) { double('Logger', notice: true) }
    Given(:user) { 'user' }
    Given(:profile_request) { double('ProfileRequest', user: user, successful_profile_creation: true, error_on_profile_creation: true) }
    Given(:remote_service) { double('Remote Service') }
    Given(:callback_responder) do
      double('Responder', unknown: true, authenticated_connection: true, profile_request_pending: true, pending_connection: true)
    end
    Given(:profile_state_finder) { double('ProfileStateFinder', call: true) }
    Given(:coordinator) do
      described_class.new(
        profile_request,
        remote_service: remote_service,
        profile_state_finder: profile_state_finder,
        logger: logger
      )
    end

    context '.call' do
      When(:response) do
        described_class.call(
          profile_request,
          remote_service: remote_service,
          profile_state_finder: profile_state_finder,
          logger: logger
        )
      end
      Then { expect(response).to eq(true) }
    end

    context 'on profile_request_pending state' do
      Given(:remote_service_handler) { double('Handler', success: true, failure: true, orcid_validation_error: true) }
      Given(:attributes) { { given_names: 'Given', family_name: 'Family', primary_email: 'email@email.email' } }
      Given(:profile_request) do
        double('ProfileRequest', user: user, attributes: attributes, successful_profile_creation: true, error_on_profile_creation: true)
      end
      before do
        callback_responder.stub(:profile_request_pending).and_yield(profile_request)
        remote_service.should_receive(:call).and_yield(remote_service_handler)
      end

      context 'successful profile request' do
        before do
          remote_service_handler.should_receive(:success).and_yield(orcid_profile_id)
        end
        Given(:orcid_profile_id) { '0000-0001-0002-0003' }
        When { coordinator.call }
        Then { expect(profile_request).to have_received(:successful_profile_creation).with(orcid_profile_id) }
      end
      context 'encountering a orcid validation error' do
        before do
          remote_service_handler.should_receive(:orcid_validation_error).and_yield(error_message)
        end
        Given(:error_message) { 'Error Message' }
        When { coordinator.call }
        Then { expect(profile_request).to have_received(:error_on_profile_creation).with(error_message) }
      end
    end

    context 'requires a user for the profile_request' do
      Given(:profile_request) { double('ProfileRequest') }
      When(:instantiation) { described_class.new(profile_request) }
      Then { expect(instantiation).to have_failed(MissingUserForProfileRequest) }
    end

    context 'requires a error_on_profile_creation for the profile_request' do
      Given(:profile_request) { double('ProfileRequest', user: 'user') }
      When(:instantiation) { described_class.new(profile_request) }
      Then { expect(instantiation).to have_failed(ProfileRequestMethodExpectedError) }
    end

    context 'requires a error_on_profile_creation for the profile_request' do
      Given(:profile_request) { double('ProfileRequest', user: 'user', error_on_profile_creation: true) }
      When(:instantiation) { described_class.new(profile_request) }
      Then { expect(instantiation).to have_failed(ProfileRequestMethodExpectedError) }
    end

    context 'on unknown state' do
      before do
        callback_responder.stub(:unknown).and_yield
      end
      When(:response) { coordinator.call }
      Then { expect(response).to have_failed(ProfileRequestStateError) }
    end

    context 'on pending_connection state' do
      before do
        callback_responder.stub(:pending_connection).and_yield(profile)
      end
      Given(:profile) { double('Profile') }
      When { coordinator.call }
      Then { expect(logger).to have_received(:notice) }
    end

    context 'on handle_authenticated_connection_for state' do
      before do
        callback_responder.stub(:authenticated_connection).and_yield(profile)
      end
      Given(:profile) { double('Profile') }
      When { coordinator.call }
      Then { expect(logger).to have_received(:notice) }
    end
  end
end
