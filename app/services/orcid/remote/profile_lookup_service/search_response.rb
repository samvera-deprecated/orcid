module Orcid::Remote
  class ProfileLookupService
    class SearchResponse
      delegate :fetch, :has_key?, :[], to: :@attributes
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
