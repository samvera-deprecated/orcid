module Orcid
  # Responsible for determining a given user's orcid profile state as it
  # pertains to the parent application.
  #
  # @TODO - There are quite a few locations where the state related behavior
  # has leaked out (i.e. the Orcid::ProfileConnectionsController and Orcid::
  # ProfileRequestsController)
  #
  # ProfileStatus.status
  # **:authenticated_connection** - User has authenticated against the Orcid
  #   remote system
  # **:pending_connection** - User has indicated there is a connection, but has
  #   not authenticated against the Orcid remote system
  # **:profile_request_pending** - User has requested a profile be created on
  #   their behalf
  # **:unknown** - None of the above
  class ProfileStatus
    def self.for(user, collaborators = {}, &block)
      new(user, collaborators, &block).status
    end

    attr_reader :user, :profile_finder, :request_finder, :callback_handler

    def initialize(user, collaborators = {})
      @user = user
      @profile_finder = collaborators.fetch(:profile_finder) { default_profile_finder }
      @request_finder = collaborators.fetch(:request_finder) { default_request_finder }
      @callback_handler = collaborators.fetch(:callback_handler) { default_callback_handler }
      yield(callback_handler) if block_given?
    end

    def status
      return callback(:unknown) if user.nil?
      profile = profile_finder.call(user)
      if profile
        if profile.verified_authentication?
          return callback(:authenticated_connection, profile)
        else
          return callback(:pending_connection, profile)
        end
      else
        request = request_finder.call(user)
        if request
          if request.error_on_profile_creation?
            return callback(:profile_request_in_error, request)
          else
            return callback(:profile_request_pending, request)
          end
        else
          return callback(:unknown)
        end
      end
    end

    private

    def callback(name, *args)
      callback_handler.call(name, *args)
      name
    end

    def default_callback_handler
      require 'orcid/named_callbacks'
      NamedCallbacks.new
    end

    def default_profile_finder
      require 'orcid'
      Orcid.method(:profile_for)
    end

    def default_request_finder
      require 'orcid/profile_request'
      ProfileRequest.method(:find_by_user)
    end
  end
end
