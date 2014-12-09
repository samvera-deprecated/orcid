require 'virtus'
require 'active_model'
module Orcid
  # Responsible for connecting an authenticated user to the ORCID profile that
  # the user searched for and selected.
  class ProfileConnection
    include Virtus.model
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    # See: http://support.orcid.org/knowledgebase/articles/132354-tutorial-searching-with-the-api
    class_attribute :available_query_attribute_names
    self.available_query_attribute_names = [:text]

    available_query_attribute_names.each do |attribute_name|
      attribute attribute_name
    end

    attribute :orcid_profile_id
    attribute :user

    validates :user, presence: true
    validates :orcid_profile_id, presence: true

    def save
      valid? ? persister.call(user, orcid_profile_id) : false
    end

    def persisted?
      false
    end

    attr_writer :persister
    def persister
      @persister ||= default_persister
    end
    private :persister

    def default_persister
      require 'orcid'
      Orcid.method(:connect_user_and_orcid_profile)
    end

    attr_writer :profile_query_service
    def profile_query_service
      @profile_query_service ||= default_profile_query_service
    end
    private :profile_query_service

    def default_profile_query_service
      Remote::ProfileQueryService.new do |on|
        on.found { |results| self.orcid_profile_candidates = results }
        on.not_found { self.orcid_profile_candidates = [] }
      end
    end
    private :default_profile_query_service

    def with_orcid_profile_candidates
      yield(orcid_profile_candidates) if query_requested?
    end

    attr_writer :orcid_profile_candidates
    private :orcid_profile_candidates=
    def orcid_profile_candidates
      @orcid_profile_candidates || lookup_profile_candidates
    end

    def lookup_profile_candidates
      profile_query_service.call(query_attributes) if query_requested?
    end
    private :lookup_profile_candidates

    def query_requested?
      available_query_attribute_names.any? do |attribute_name|
        attributes[attribute_name].present?
      end
    end
    private :query_requested?

    def query_attributes
      available_query_attribute_names.each_with_object({}) do |name, mem|
        orcid_formatted_name = convert_attribute_name_to_orcid_format(name)
        mem[orcid_formatted_name] = attributes.fetch(name)
        mem
      end
    end

    def convert_attribute_name_to_orcid_format(name)
      name.to_s.gsub(/_+/, '-')
    end
    private :convert_attribute_name_to_orcid_format
  end
end
