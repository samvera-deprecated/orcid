require 'spec_helper'

describe Orcid do
  let(:user) { FactoryGirl.build_stubbed(:user) }
  let(:orcid_profile_id) { '0001-0002-0003-0004' }

  context '.authentication_model' do
    subject { Orcid.authentication_model }
    it { should respond_to :to_access_token }
    it { should respond_to :create! }
    it { should respond_to :count }
    it { should respond_to :where }
  end

  context '.oauth_client' do
    subject { Orcid.oauth_client }
    its(:client_credentials) { should respond_to :get_token }
  end

  context '.configure' do
    it 'should yield a configuration' do
      expect{|b| Orcid.configure(&b) }.to yield_with_args(Orcid::Configuration)
    end
  end

  context '.profile_for' do
    it 'should return nil if none is found' do
      expect(Orcid.profile_for(user)).to eq(nil)
    end

    it 'should return an Orcid::Profile if the user has an orcid authentication' do
      Orcid.connect_user_and_orcid_profile(user,orcid_profile_id)
      expect(Orcid.profile_for(user).orcid_profile_id).to eq(orcid_profile_id)
    end
  end

  context '.client_credentials_token' do
    let(:tokenizer) { double('Tokenizer') }
    let(:scope) { '/my-scope' }
    let(:token) { double('Token') }

    it 'should request the scoped token from the tokenizer' do
      tokenizer.should_receive(:get_token).with(scope: scope).and_return(token)
      expect(Orcid.client_credentials_token(scope, tokenizer: tokenizer)).to eq(token)
    end
  end

  context '.connect_user_and_orcid_profile' do

    it 'changes the authentication count' do
      expect {
        Orcid.connect_user_and_orcid_profile(user, orcid_profile_id)
      }.to change(Orcid.authentication_model, :count).by(1)
    end
  end

  context '.access_token_for' do
    let(:client) { double("Client")}
    let(:token) { double('Token') }
    let(:tokenizer) { double("Tokenizer") }

    it 'delegates to .authentication' do
      tokenizer.should_receive(:to_access_token).with(provider: 'orcid', uid: orcid_profile_id, client: client).and_return(token)
      expect(Orcid.access_token_for(orcid_profile_id, client: client, tokenizer: tokenizer)).to eq(token)
    end
  end

  context '.enqueue' do
    let(:object) { double }

    it 'should #run the object' do
      object.should_receive(:run)
      Orcid.enqueue(object)
    end
  end

end
