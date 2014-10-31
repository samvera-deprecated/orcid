module Orcid
  # The foundation for Orcid controllers. A few helpful accessors.
  class ApplicationController < Orcid.parent_controller.constantize
    # Providing a mechanism for overrding the default path in an implementing
    # application
    def path_for(named_path, *args)
      return send(named_path, *args).to_s if respond_to?(named_path)
      yield(*args)
    end

    private

    def redirecting_because_user_has_connected_orcid_profile
      if orcid_profile
        flash[:notice] = I18n.t(
          'orcid.requests.messages.previously_connected_profile',
          orcid_profile_id: orcid_profile.orcid_profile_id
        )
        redirect_to path_for(:orcid_settings_path) { main_app.root_path }
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
