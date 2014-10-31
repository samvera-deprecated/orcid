module Orcid
  # Responsible for negotiating a user request Profile Creation.
  #
  # @TODO - Leverage the Orcid::ProfileStatus object instead of the really
  # chatty method names. The method names are fine, but the knowledge of
  # Orcid::ProfileStatus is encapsulated in that class.
  class ProfileConnectionsController < Orcid::ApplicationController
    respond_to :html
    before_filter :authenticate_user!

    def index
      redirecting_because_user_does_not_have_a_connected_orcid_profile ||
        redirecting_because_user_must_verify_their_connected_profile ||
        redirecting_because_user_has_verified_their_connected_profile
    end

    def new
      return false if redirecting_because_user_has_connected_orcid_profile
      assign_attributes(new_profile_connection)
      respond_with(orcid, new_profile_connection)
    end

    def create
      return false if redirecting_because_user_has_connected_orcid_profile
      assign_attributes(new_profile_connection)
      create_profile_connection(new_profile_connection)
      respond_with(orcid, new_profile_connection)
    end

    protected

    attr_reader :profile_connection
    helper_method :profile_connection

    def assign_attributes(profile_connection)
      profile_connection.attributes = profile_connection_params
      profile_connection.user = current_user
    end

    def profile_connection_params
      params[:profile_connection] || {}
    end

    def create_profile_connection(profile_connection)
      profile_connection.save
    end

    def new_profile_connection
      @profile_connection ||= begin
        Orcid::ProfileConnection.new(params[:profile_connection])
      end
    end

    def redirecting_because_user_does_not_have_a_connected_orcid_profile
      return false if orcid_profile
      flash[:notice] = I18n.t(
        'orcid.connections.messages.profile_connection_not_found'
      )
      redirect_to orcid.new_profile_connection_path
    end

    def redirecting_because_user_must_verify_their_connected_profile
      return false unless orcid_profile
      return false if orcid_profile.verified_authentication?

      redirect_to user_omniauth_authorize_url('orcid')
    end

    def redirecting_because_user_has_verified_their_connected_profile
      orcid_profile = Orcid.profile_for(current_user)
      notice = I18n.t(
        'orcid.connections.messages.verified_profile_connection_exists',
        orcid_profile_id: orcid_profile.orcid_profile_id
      )
      location = path_for(:orcid_settings_path) { main_app.root_path }
      redirect_to(location, flash: { notice: notice })
    end
  end
end
