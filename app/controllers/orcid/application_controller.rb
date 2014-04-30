module Orcid
  # The foundation for Orcid controllers. A few helpful accessors.
  class ApplicationController < Orcid.parent_controller.constantize
    private

    def redirecting_because_user_has_connected_orcid_profile
      if orcid_profile
        flash[:notice] = I18n.t(
          'orcid.requests.messages.previously_connected_profile',
          orcid_profile_id: orcid_profile.orcid_profile_id
        )
        redirect_to main_app.root_path
        return true
      else
        return false
      end
    end

    def orcid_profile
      @orcid_profile ||= Orcid.profile_for(current_user)
    end
  end
end
