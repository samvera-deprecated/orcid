module Orcid
  # Responsible for:
  # * acknowledging that an ORCID Profile was requested
  # * submitting a request for an ORCID Profile
  # * handling the response for the ORCID Profile creation
  class ProfileRequest < ActiveRecord::Base

    def self.find_by_user(user)
      where(user: user).first
    end

    self.table_name = :orcid_profile_requests

    validates :user_id, presence: true, uniqueness: true
    validates :given_names, presence: true
    validates :family_name, presence: true
    validates :primary_email, presence: true, email: true, confirmation: true

    belongs_to :user

    def run(options = {})
      # Why dependency injection? Because this is going to be a plugin, and things
      # can't possibly be simple.
      before_run_validator = options.fetch(:before_run_validator) { method(:validate_before_run) }
      return false unless before_run_validator.call(self)

      payload_xml_builder = options.fetch(:payload_xml_builder) { method(:xml_payload) }
      profile_creation_service = options.fetch(:profile_creation_service) { Orcid::ProfileCreationService }
      profile_creation_responder = options.fetch(:profile_creation_responder) { method(:handle_profile_creation_response) }

      orcid_profile_id = profile_creation_service.call(payload_xml_builder.call(attributes))
      profile_creation_responder.call(orcid_profile_id)
    end

    def validate_before_run(context = self)

      if context.orcid_profile_id?
        context.errors.add(:base, "#{context.class} ID=#{context.to_param} already has an assigned :orcid_profile_id #{context.orcid_profile_id.inspect}")
        return false
      end

      if user_orcid_profile = Orcid.profile_for(context.user)
        context.errors.add(:base, "#{context.class} ID=#{context.to_param}'s associated user #{context.user.to_param} already has an assigned :orcid_profile_id #{user_orcid_profile.to_param}")
        return false
      end

      true
    end

    # NOTE: This one lies -> http://support.orcid.org/knowledgebase/articles/177522-create-an-id-technical-developer
    # NOTE: This one was true at 2014-02-06:14:55 -> http://support.orcid.org/knowledgebase/articles/162412-tutorial-create-a-new-record-using-curl
    def xml_payload(input = attributes)
      attrs = input.with_indifferent_access
      returning_value = <<-XML_TEMPLATE
      <?xml version="1.0" encoding="UTF-8"?>
      <orcid-message
      xmlns:xsi="http://www.orcid.org/ns/orcid https://raw.github.com/ORCID/ORCID-Source/master/orcid-model/src/main/resources/orcid-message-1.1.xsd"
      xmlns="http://www.orcid.org/ns/orcid">
      <message-version>1.1</message-version>
      <orcid-profile>
      <orcid-bio>
      <personal-details>
      <given-names>#{attrs.fetch('given_names')}</given-names>
      <family-name>#{attrs.fetch('family_name')}</family-name>
      </personal-details>
      <contact-details>
      <email primary="true">#{attrs.fetch('primary_email')}</email>
      </contact-details>
      </orcid-bio>
      </orcid-profile>
      </orcid-message>
      XML_TEMPLATE
      returning_value.strip
    end

    def handle_profile_creation_response(orcid_profile_id)
      self.class.transaction do
        update_column(:orcid_profile_id, orcid_profile_id)
        Orcid.connect_user_and_orcid_profile(user, orcid_profile_id)
      end
    end

  end
end
