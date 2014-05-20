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
              identifier = profile.fetch('orcid-identifier').fetch('path')
              orcid_bio = profile.fetch('orcid-bio')
              given_names = orcid_bio.fetch('personal-details').fetch('given-names').fetch('value')
              family_name = orcid_bio.fetch('personal-details').fetch('family-name').fetch('value')
              emails = []
              contact_details = orcid_bio['contact-details']
              if contact_details
                emails = (contact_details['email'] || []).map {|email| email.fetch('value') }
              end
              label = "#{given_names} #{family_name}"
              label << ' (' << emails.join(', ') << ')' if emails.any?
              label << " [ORCID: #{identifier}]"
              biography = ''
              biography = orcid_bio['biography']['value'] if orcid_bio['biography']
              returning_value << response_builder.new('id' => identifier, 'label' => label, 'biography' => biography)
            rescue KeyError => e
              logger.warn("Unexpected ORCID JSON Response, part of the response has been ignored.\tException Encountered:#{e.class}\t#{e}")
            end
            returning_value
          end
        end

        private
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
