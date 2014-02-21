require 'spec_helper'

module Orcid
  describe ProfileConnectionsController do
    def self.it_prompts_unauthenticated_users_for_signin(method, action)
      context 'unauthenticated user' do
        it 'should redirect for sign in' do
          send(method, action, use_route: :orcid)
          expect(response).to redirect_to(main_app.new_user_session_path)
        end
      end
    end

    def self.it_redirects_if_user_has_previously_connected_to_orcid_profile(method, action)
      context 'user has existing orcid_profile' do
        it 'should redirect to home_path' do
          sign_in(user)
          orcid_profile = double("Orcid::Profile", orcid_profile_id: '1234-5678-0001-0002')
          Orcid.should_receive(:profile_for).with(user).and_return(orcid_profile)

          send(method, action, use_route: :orcid)

          expect(response).to redirect_to(main_app.root_path)
          expect(flash[:notice]).to eq(
            I18n.t("orcid.requests.messages.previously_connected_profile", orcid_profile_id: orcid_profile.orcid_profile_id)
          )
        end
      end
    end

    let(:user) { mock_model('User') }
    before(:each) do
      Orcid.stub(:profile_for).and_return(nil)
    end

    context 'GET #index' do
      it_prompts_unauthenticated_users_for_signin(:get, :index)
    end

    context 'GET #new' do
      it_prompts_unauthenticated_users_for_signin(:get, :new)
      it_redirects_if_user_has_previously_connected_to_orcid_profile(:get, :new)

      context 'authenticated and authorized user' do
        before { sign_in(user) }

        it 'should render a profile request form' do
          get :new, use_route: :orcid
          expect(response).to be_success
          expect(assigns(:profile_connection)).to be_an_instance_of(Orcid::ProfileConnection)
          expect(response).to render_template('new')
        end
      end
    end

    context 'POST #create' do
      it_prompts_unauthenticated_users_for_signin(:post, :create)
      it_redirects_if_user_has_previously_connected_to_orcid_profile(:post, :create)

      context 'authenticated and authorized user' do
        let(:orcid_profile_id) {'0000-0001-8025-637X'}
        before { sign_in(user) }

        it 'should render a profile request form' do
          Orcid::ProfileConnection.any_instance.should_receive(:save)

          post :create, profile_connection: { orcid_profile_id: orcid_profile_id }, use_route: :orcid
          expect(assigns(:profile_connection)).to be_an_instance_of(Orcid::ProfileConnection)
          expect(response).to redirect_to(orcid.profile_connections_path)
        end
      end
    end
  end
end
