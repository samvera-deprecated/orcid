require 'spec_helper'
require 'orcid/profile_status'

module Orcid
  describe ProfileStatus do
    Given(:user) { nil }
    Given(:profile_finder) { double('ProfileFinder') }
    Given(:request_finder) { double('RequestFinder') }
    Given(:callback) { StubCallback.new }
    Given(:callback_config) do
      callback.configure(
        :unknown,
        :authenticated_connection,
        :pending_connection,
        :profile_request_pending,
        :profile_request_in_error
      )
    end
    Given(:subject) do
      described_class.new(user, profile_finder: profile_finder, request_finder: request_finder, &callback_config)
    end

    context '.for' do
      Given(:user) { nil }
      When(:response) { described_class.for(user, &callback_config) }
      Then { expect(response).to eq :unknown }
      And { expect(callback.invoked).to eq [:unknown] }
    end

    context '#status' do
      context 'user is nil' do
        Given(:user) { nil }
        When(:status) { subject.status }
        Then { expect(status).to eq :unknown }
      end

      context 'user is not nil' do
        Given(:user) { double('User') }
        Given(:profile_finder) { double('ProfileFinder', call: nil) }
        Given(:request_finder) { double('RequestFinder', call: nil) }
        context 'and has a profile' do
          Given(:profile_finder) { double('ProfileFinder', call: profile) }
          context 'that they have remotely authenticated' do
            Given(:profile) { double('Profile', verified_authentication?: true) }
            When(:status) { subject.status }
            Then { expect(status).to eq :authenticated_connection }
            And { expect(callback.invoked).to eq [:authenticated_connection, profile] }
          end
          context 'that they have not remotely authenticated' do
            Given(:profile) { double('Profile', verified_authentication?: false) }
            When(:status) { subject.status }
            Then { expect(status).to eq :pending_connection }
            And { expect(callback.invoked).to eq [:pending_connection, profile] }
          end
        end

        context 'and does not have a profile' do
          context 'but has submitted a request' do
            Given(:request) { double('ProfileRequest', :error_on_profile_creation? => error_on_creation) }
            Given(:request_finder) { double('RequestFinder', call: request) }

            context "and there weren't problems with the request" do
              Given(:error_on_creation) { false }
              When(:status) { subject.status }
              Then { expect(status).to eq :profile_request_pending }
              And { expect(callback.invoked).to eq [:profile_request_pending, request] }
            end

            context "and there were problems with the request" do
              Given(:error_on_creation) { true }
              When(:status) { subject.status }
              Then { expect(status).to eq :profile_request_in_error }
              And { expect(callback.invoked).to eq [:profile_request_in_error, request] }
            end
          end
          context 'user does not have a request' do
            When(:status) { subject.status }
            Then { expect(status).to eq :unknown }
            And { expect(callback.invoked).to eq [:unknown] }
          end
        end
      end
    end
  end
end
