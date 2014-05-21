require 'fast_helper'
require 'orcid/profile_connection'

# :nodoc:
module Orcid
  describe ProfileConnection do
    let(:email) { 'test@hello.com' }
    let(:dois) { '123' }
    let(:user) { double('User') }
    let(:profile_query_service) { double('Profile Lookup Service') }
    let(:persister) { double('Persister') }

    subject do
      Orcid::ProfileConnection.new(email: email, user: user).tap do |pc|
        pc.persister = persister
        pc.profile_query_service = profile_query_service
      end
    end

    its(:email) { should eq email }
    its(:to_model) { should eq subject }
    its(:user) { should eq user }
    its(:persisted?) { should eq false }
    its(:orcid_profile_id) { should be_nil }

    context '.available_query_attribute_names' do
      subject { Orcid::ProfileConnection.new.available_query_attribute_names }
      it { should include(:email) }
      it { should include(:text) }
      it { should include(:digital_object_ids) }
    end

    context '#query_attributes' do
      subject do
        Orcid::ProfileConnection.new(
          email: email, user: user, digital_object_ids: dois
        )
      end
      its(:query_attributes) do
        should eq(
          'email' => email, 'text' => nil, 'digital-object-ids' => dois
        )
      end
    end

    context '#query_requested?' do
      context 'with no attributes' do
        subject { Orcid::ProfileConnection.new }
        its(:query_requested?) { should eq false }
      end
      context 'with attribute set' do
        subject { Orcid::ProfileConnection.new(email: email, user: user) }
        its(:query_requested?) { should eq true }
      end
    end

    context '#save' do
      let(:orcid_profile_id) { '1234-5678' }

      it 'should call the persister when valid' do
        subject.orcid_profile_id = orcid_profile_id
        persister.should_receive(:call).
          with(user, orcid_profile_id).
          and_return(:persisted)

        expect(subject.save).to eq(:persisted)
      end

      it 'should NOT call the persister and add errors when not valid' do
        subject.user = nil
        subject.orcid_profile_id = nil

        expect { subject.save }.to change { subject.errors.count }.by(2)
      end
    end

    context '#with_orcid_profile_candidates' do
      context 'with an email' do

        it 'should yield the query response' do
          subject.email = email

          profile_query_service.
            should_receive(:call).
            with(subject.query_attributes).
            and_return(:query_response)

          expect { |b| subject.with_orcid_profile_candidates(&b) }.
            to yield_with_args(:query_response)
        end
      end

      context 'without an email' do
        it 'should not yield' do
          subject.email = nil
          profile_query_service.stub(:call).and_return(:query_response)

          expect { |b| subject.with_orcid_profile_candidates(&b) }.
            to_not yield_control
        end
      end

    end
  end
end
