module Orcid
  # A well-defined data structure that coordinates with its :template in order
  # to generate XML that can be POSTed/PUT as an Orcid Work.
  class Work
    VALID_WORK_TYPES =
    %w(artistic-performance book-chapter book-review book
       conference-abstract conference-paper conference-poster
       data-set dictionary-entry disclosure dissertation
       edited-book encyclopedia-entry invention journal-article
       journal-issue lecture-speech license magazine-article
       manual newsletter-article newspaper-article online-resource
       other patent registered-copyright report research-technique
       research-tool spin-off-company standards-and-policy
       supervised-student-publication technical-standard test
       translation trademark website working-paper
       ).freeze

    # An Orcid Work's external identifier is not represented in a single
    # attribute.
    class ExternalIdentifier
      include Virtus.value_object
      values do
        attribute :type,  String
        attribute :identifier, String
      end
    end

    include Virtus.model
    include ActiveModel::Validations
    extend ActiveModel::Naming

    attribute :title, String
    validates :title, presence: true

    attribute :work_type, String
    validates :work_type, presence: true, inclusion: { in: VALID_WORK_TYPES }

    attribute :subtitle, String
    attribute :journal_title, String
    attribute :short_description, String
    attribute :citation_type, String
    attribute :citation, String
    attribute :publication_year, Integer
    attribute :publication_month, Integer
    attribute :url, String
    attribute :language_code, String
    attribute :country, String
    attribute :put_code, String
    attribute :external_identifiers, Array[ExternalIdentifier]

    def work_citation?
      citation_type.present? || citation.present?
    end

    def publication_date?
      publication_year.present? || publication_month.present?
    end

    def to_xml
      XmlRenderer.call(self)
    end

    def ==(other)
      super ||
        other.instance_of?(self.class) &&
        id.present? &&
        other.id == id
    end

    def id
      if put_code.present?
        put_code
      elsif title.present? && work_type.present?
        [title, work_type]
      else
        nil
      end
    end
  end
end
