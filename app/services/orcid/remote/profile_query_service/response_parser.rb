require_dependency 'orcid/remote/profile_query_service'
module Orcid
  module Remote
    class ProfileQueryService
      # Responsible for parsing a response document
      class ResponseParser

        # A convenience method to expose entry into the ResponseParser function
        def self.call(document, collaborators = {})
          new(collaborators).call(document)
        end

        attr_reader :response_builder, :logger
        private :response_builder, :logger
        def initialize(collaborators = {})
          @response_builder = collaborators.fetch(:response_builder) { default_response_builder }
          @logger = collaborators.fetch(:logger) { default_logger }
        end

        def call(document)
          json = JSON.parse(document)
          json.fetch('orcid-search-results').fetch('orcid-search-result')
          .each_with_object([]) do |result, returning_value|
            profile = result.fetch('orcid-profile')
            begin
              identifier = extract_identifier(profile)
              label = extract_label(identifier, profile)
              biography = extract_biography(profile)
              returning_value << response_builder.new('id' => identifier, 'label' => label, 'biography' => biography)
            rescue KeyError => e
              logger.warn("Unexpected ORCID JSON Response, part of the response has been ignored.\tException Encountered:#{e.class}\t#{e}")
            end
            returning_value
          end
        end

        private
        def extract_identifier(profile)
          profile.fetch('orcid-identifier').fetch('path')
        end

        def extract_label(identifier, profile)
          orcid_bio = profile.fetch('orcid-bio')
          given_names = orcid_bio.fetch('personal-details').fetch('given-names').fetch('value')
          # family name is not a required field on orcid record
          family_name = orcid_bio.try(:[], 'personal-details').try(:[], 'family-name').try(:[], 'value')
          emails = []
          contact_details = orcid_bio['contact-details']
          if contact_details
            emails = (contact_details['email'] || []).map {|email| email.fetch('value') }
          end
          label = "#{given_names} #{family_name}"
          label << ' (' << emails.join(', ') << ')' if emails.any?
          label << " [ORCID: #{identifier}]"
          label << " <a class=\"orcid-profile-id\" target=\"_blank\" href=\"#{ Orcid.url_for_orcid_id(identifier)}\"> Look Up Orcid Profile</a>"
          label.html_safe
        end

        def extract_biography(profile)
          orcid_bio = profile.fetch('orcid-bio')
          if orcid_bio['biography']
            orcid_bio['biography'].fetch('value')
          else
            ''
          end
        end

        def default_logger
          Rails.logger
        end

        def default_response_builder
          SearchResponse
        end
      end
    end
  end
end
