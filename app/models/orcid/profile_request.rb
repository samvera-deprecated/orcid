module Orcid
  # Responsible for:
  # * acknowledging that an ORCID Profile was requested
  # * submitting a request for an ORCID Profile
  # * handling the response for the ORCID Profile creation
  class ProfileRequest < ActiveRecord::Base
    ERROR_STATUS = 'error'.freeze
    def self.find_by_user(user)
      where(user: user).first
    end

    self.table_name = :orcid_profile_requests

    alias_attribute :email, :primary_email
    validates :user_id, presence: true, uniqueness: true
    validates :given_names, presence: true
    validates :family_name, presence: true
    validates :primary_email, presence: true, email: true, confirmation: true

    belongs_to :user

    def successful_profile_creation(orcid_profile_id)
      self.class.transaction do
        update_column(:orcid_profile_id, orcid_profile_id)
        Orcid.connect_user_and_orcid_profile(user, orcid_profile_id)
      end
    end

    def error_on_profile_creation(error_message)
      update_column(:response_text, error_message)
      update_column(:response_status, ERROR_STATUS)
    end

    alias_attribute :error_message, :response_text

    def error_on_profile_creation?
      error_message.present? || response_status == ERROR_STATUS
    end

  end
end
