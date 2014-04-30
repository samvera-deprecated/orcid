require_dependency 'orcid/remote/profile_query_service'
module Orcid
  module Remote
    class ProfileQueryService
      # A search response against Orcid. This should implement the Questioning
      # Authority query response object interface.
      class SearchResponse
        delegate :[], :has_key?, :key?, :fetch, to: :@records
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

        def biography
          @attributes.fetch(:biography)
        end
      end
    end
  end
end
