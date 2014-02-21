require 'spec_helper'

module Orcid
  describe ProfileConnection do
    let(:email) { 'test@hello.com'}
    let(:user) { FactoryGirl.build_stubbed(:user) }
    subject { Orcid::ProfileConnection.new(email: email, user: user) }

    its(:email) { should eq email }
    its(:user) { should eq user }
    its(:persisted?) { should eq false }
    its(:orcid_profile_id) { should be_nil }

    context '#save' do
      let(:orcid_profile_id) { '1234-5678' }
      let(:persister) { double("Persister") }

      it 'should call the persister when valid' do
        subject.orcid_profile_id = orcid_profile_id
        persister.should_receive(:call).with(user, orcid_profile_id).and_return(:persisted)
        expect(subject.save(persister: persister)).to eq(:persisted)
      end

      it 'should NOT call the persister and add errors when not valid' do
        subject.user = nil
        subject.orcid_profile_id = nil
        expect {
          subject.save(persister: persister)
        }.to change { subject.errors.count }.by(2)
      end
    end

    context '#with_orcid_profile_candidates' do
      let(:querier) { double("Querier") }
      before(:each) do
        subject.orcid_profile_querier = querier
      end
      context 'with an email' do
        it 'should yield the query response' do
          subject.email = email
          querier.stub(:call).and_return(:query_response)
          expect {|b| subject.with_orcid_profile_candidates(&b) }.to yield_with_args(:query_response)
        end
      end

      context 'without an email' do
        it 'should not yield' do
          subject.email = nil
          querier.stub(:call).and_return(:query_response)
          expect {|b| subject.with_orcid_profile_candidates(&b) }.to_not yield_control
        end
      end

    end
  end
end
