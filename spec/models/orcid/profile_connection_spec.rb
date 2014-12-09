require 'fast_helper'
require 'orcid/profile_connection'

# :nodoc:
module Orcid
  describe ProfileConnection do
    let(:text) { 'test@hello.com' }
    let(:dois) { '123' }
    let(:user) { double('User') }
    let(:profile_query_service) { double('Profile Lookup Service') }
    let(:persister) { double('Persister') }

    subject do
      Orcid::ProfileConnection.new(text: text, user: user).tap do |pc|
        pc.persister = persister
        pc.profile_query_service = profile_query_service
      end
    end

    its(:default_persister) { should respond_to(:call) }
    its(:text) { should eq text }
    its(:to_model) { should eq subject }
    its(:user) { should eq user }
    its(:persisted?) { should eq false }
    its(:orcid_profile_id) { should be_nil }

    context '.available_query_attribute_names' do
      subject { Orcid::ProfileConnection.new.available_query_attribute_names }
      it { should include(:text) }
    end

    context '#query_attributes' do
      subject do
        Orcid::ProfileConnection.new(
          text: text, user: user, digital_object_ids: dois
        )
      end
      its(:query_attributes) do
        should eq(
          'text' => text
        )
      end
    end

    context '#query_requested?' do
      context 'with no attributes' do
        subject { Orcid::ProfileConnection.new }
        its(:query_requested?) { should eq false }
      end
      context 'with attribute set' do
        subject { Orcid::ProfileConnection.new(text: text, user: user) }
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
      context 'with an text' do

        it 'should yield the query response' do
          subject.text = text

          profile_query_service.
            should_receive(:call).
            with(subject.query_attributes).
            and_return(:query_response)

          expect { |b| subject.with_orcid_profile_candidates(&b) }.
            to yield_with_args(:query_response)
        end
      end

      context 'without an text' do
        it 'should not yield' do
          subject.text = nil
          profile_query_service.stub(:call).and_return(:query_response)

          expect { |b| subject.with_orcid_profile_candidates(&b) }.
            to_not yield_control
        end
      end

    end
  end
end
