module Orcid
  # Responsible for connecting an authenticated user to the ORCID profile that
  # the user searched for and selected.
  class ProfileConnection
    include Virtus.model
    include ActiveModel::Validations
    extend ActiveModel::Naming
    attribute :email
    attribute :orcid_profile_id
    attribute :user

    validates :user, presence: true
    validates :orcid_profile_id, presence: true


    def save(config = {})
      persister = config.fetch(:persister) { Orcid.method(:connect_user_and_orcid_profile) }
      valid? ? persister.call(user, orcid_profile_id) : false
    end

    def persisted?; false; end

    attr_writer :profile_lookup_service
    def profile_lookup_service
      @profile_lookup_service ||= default_profile_lookup_service
    end
    private :profile_lookup_service

    def default_profile_lookup_service
      ProfileLookupRunner.new {|on|
        on.found {|results| self.orcid_profile_candidates = results }
        on.not_found { self.orcid_profile_candidates = [] }
      }
    end
    private :default_profile_lookup_service

    def with_orcid_profile_candidates
      yield(orcid_profile_candidates) if email.present?
    end

    attr_writer :orcid_profile_candidates
    private :orcid_profile_candidates=
    def orcid_profile_candidates
      @orcid_profile_candidates || lookup_profile_candidates
    end

    def lookup_profile_candidates
      if email.present?
        profile_lookup_service.call(email: email)
      end
    end
    private :lookup_profile_candidates

  end
end
