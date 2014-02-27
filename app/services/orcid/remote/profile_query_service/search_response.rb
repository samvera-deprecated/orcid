require_dependency 'orcid/remote/profile_query_service'
module Orcid::Remote
  class ProfileLookupService
    class SearchResponse
      delegate :[], :has_key?, :fetch, to: :@records
      def initialize(attributes = {})
        @attributes = attributes.with_indifferent_access
      end

      def id
        @attributes.fetch(:id)
      end

      def orcid_profile_id
        @attributes.fetch(:id)
      end

      def label
        @attributes.fetch(:label)
      end
    end
  end
end
