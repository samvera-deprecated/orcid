require 'orcid/exceptions'

module Orcid
  # Responsible for converting an Orcid::ProfileRequest into an Orcid::Profile.
  class ProfileRequestCoordinator

    def self.call(profile_request, collaborators = {})
      new(profile_request, collaborators).call
    end

    def initialize(profile_request, collaborators = {})
      self.profile_request = profile_request
      @remote_service = collaborators.fetch(:remote_service) { default_remote_service }
      @profile_state_finder = collaborators.fetch(:profile_state_finder) { default_profile_state_finder }
      @logger = collaborators.fetch(:logger) { default_logger }
    end

    attr_reader :profile_request, :remote_service, :profile_state_finder, :logger
    private :remote_service, :profile_state_finder, :logger

    def call
      profile_state_finder.call(user) do |on|
        on.unknown { handle_unknown_profile_state }
        on.profile_request_pending { |request| handle_profile_request }
        on.pending_connection { |profile| handle_pending_connection_for(profile) }
        on.authenticated_connection { |profile| handle_authenticated_connection_for(profile) }
      end
      true
    end

    private

    def handle_profile_request
      payload = xml_payload(profile_request)
      remote_service.call(payload) do |on|
        on.success { |orcid_profile_id| profile_request.successful_profile_creation(orcid_profile_id) }
        on.failure { }
        on.orcid_validation_error { |error_message| profile_request.validation_error_on_profile_creation(error_message) }
      end
    end

    protected

    def profile_request=(request)
      if !request.respond_to?(:user) || !request.user.present?
        fail MissingUserForProfileRequest, request
      end
      if !request.respond_to?(:validation_error_on_profile_creation)
        raise ProfileRequestMethodExpectedError.new(request, :validation_error_on_profile_creation)
      end
      if !request.respond_to?(:successful_profile_creation)
        raise ProfileRequestMethodExpectedError.new(request, :successful_profile_creation)
      end
      @profile_request = request
    end

    def user
      profile_request.user
    end

    private

    def default_logger
      Rails.logger
    end

    def default_remote_service
      require 'orcid/remote/profile_creation_service'
      Orcid::Remote::ProfileCreationService
    end

    def default_profile_state_finder
      require 'orcid/profile_status'
      Orcid::ProfileStatus.method(:for)
    end

    def handle_unknown_profile_state
      require 'orcid/exceptions'
      fail Orcid::ProfileRequestStateError, user
    end

    def handle_pending_connection_for(profile)
      message = "Attempted to request ORCID for #{profile_request.class} ID=#{profile_request.to_param}."
      message << " There is a pending connection for #{user.class} ID=#{user.to_param}."
      logger.notice(message)
    end

    def handle_authenticated_connection_for(profile)
      message = "Attempted to request ORCID for #{profile_request.class} ID=#{profile_request.to_param}."
      message << " There is an authenticated connection for  #{user.class} ID=#{user.to_param}."
      logger.notice(message)
    end

    def xml_payload(request)
      attrs = request.attributes.with_indifferent_access
      returning_value = <<-XML_TEMPLATE
      <?xml version="1.0" encoding="UTF-8"?>
      <orcid-message
      xmlns:xsi="http://www.orcid.org/ns/orcid https://raw.github.com/ORCID/ORCID-Source/master/orcid-model/src/main/resources/orcid-message-1.1.xsd"
      xmlns="http://www.orcid.org/ns/orcid">
      <message-version>1.1</message-version>
      <orcid-profile>\n<orcid-bio>\n<personal-details>
      <given-names>#{attrs.fetch('given_names')}</given-names>
      <family-name>#{attrs.fetch('family_name')}</family-name>
      </personal-details>\n<contact-details>
      <email primary="true">#{attrs.fetch('primary_email')}</email>
      </contact-details>\n</orcid-bio>\n</orcid-profile>\n</orcid-message>
      XML_TEMPLATE
      returning_value.strip
    end
  end
end
