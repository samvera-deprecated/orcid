module Orcid
  class ApplicationController < ActionController::Base
    private
    def redirecting_because_user_already_has_a_connected_orcid_profile
      if orcid_profile = Orcid.profile_for(current_user)
        flash[:notice] = I18n.t("orcid.requests.messages.previously_connected_profile", orcid_profile_id: orcid_profile.orcid_profile_id)
        redirect_to main_app.root_path
        return true
      else
        return false
      end
    end
  end
end
