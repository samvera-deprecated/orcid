module Orcid
  class ProfileRequestsController < Orcid::ApplicationController
    respond_to :html
    before_filter :authenticate_user!

    attr_reader :profile_request
    helper_method :profile_request

    def show
      return false if redirecting_because_user_already_has_a_connected_orcid_profile
      return false if redirecting_because_no_profile_request_was_found
      respond_with(existing_profile_request)
    end

    def new
      return false if redirecting_because_user_already_has_a_connected_orcid_profile
      return false if redirecting_because_user_has_existing_profile_request
      assign_attributes(new_profile_request)
      respond_with(new_profile_request)
    end

    def create
      return false if redirecting_because_user_already_has_a_connected_orcid_profile
      return false if redirecting_because_user_has_existing_profile_request
      assign_attributes(new_profile_request)
      create_profile_request(new_profile_request)
      respond_with(new_profile_request)
    end

    protected

    def redirecting_because_no_profile_request_was_found
      return false if existing_profile_request
      flash[:notice] = I18n.t("orcid.requests.messages.existing_request_not_found")
      redirect_to new_profile_request_path
      true
    end

    def redirecting_because_user_has_existing_profile_request
      return false if ! existing_profile_request
      flash[:notice] = I18n.t("orcid.requests.messages.existing_request")
      redirect_to profile_request_path
      true
    end

    def existing_profile_request
      @profile_request ||= Orcid::ProfileRequest.find_by_user(current_user)
    end

    def new_profile_request
      @profile_request ||= Orcid::ProfileRequest.new(user: current_user)
    end

    def assign_attributes(profile_request)
      profile_request.attributes = profile_request_params
    end

    def create_profile_request(profile_request)
      profile_request.save && Orcid.enqueue(profile_request)
    end

    def profile_request_params
      return {} unless params.has_key?(:profile_request)
      params[:profile_request].permit(:given_names, :family_name, :primary_email, :primary_email_confirmation)
    end
  end
end
