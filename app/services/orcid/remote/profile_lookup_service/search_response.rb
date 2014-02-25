require_dependency 'forwardable'
require_dependency 'active_support/hash_with_indifferent_access'

module Orcid::Remote
  class ProfileLookupService
    class SearchResponse
      extend Forwardable
      def_delegators :@records, :[], :has_key?, :fetch, :to
      def initialize(attributes = {})
        @attributes = HashWithIndifferentAccess.new(attributes)
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
