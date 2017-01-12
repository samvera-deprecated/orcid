require 'spec_helper'
 
module Orcid
  describe CreateProfileController do

    let(:user) { mock_model('User') }

    context '#create' do
      before { sign_in(user) }

      it 'should contstruct an http post request' do
        stub_request(:post, "https://api.sandbox.orcid.org/oauth/token").
        to_return(:status => 200, :body => "", :headers => {})

        post :create, use_route: :orcid
        expect(response).to redirect_to(user_omniauth_authorize_path(:orcid))
      end
    end
  end
end
