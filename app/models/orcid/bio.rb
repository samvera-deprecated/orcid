module Orcid
  # A well-defined data structure that coordinates with its :template in order
  # to generate XML that can be POSTed/PUT as an Orcid Work.

  require "om"

  class Work

    include OM::XML::Document
    include XmlScrubber

    # VALID_WORK_TYPES = [
      # "artistic-performance","book-chapter","book-review","book","conference-abstract","conference-paper","conference-poster","data-set","dictionary-entry","disclosure","dissertation","edited-book","encyclopedia-entry","invention","journal-article","journal-issue","lecture-speech","license","magazine-article","manual","newsletter-article","newspaper-article","online-resource","other","patent","registered-copyright","report","research-technique","research-tool","spin-off-company","standards-and-policy","supervised-student-publication","technical-standard","test","translation","trademark","website","working-paper",
    # ].freeze

    include Virtus.model
    include ActiveModel::Validations
    extend ActiveModel::Naming

    #attribute :title, String
    #validates :title, presence: true

    #attribute :work_type, String
    #validates :work_type, presence: true, inclusion: { in: VALID_WORK_TYPES }

    attribute :put_code, String

    # Get the xml to send to ORCID's API's. This replaces underscores with hyphens for element names.
    def outgoing_xml
      scrub(to_xml, "_", "-")
    end
    
    # Scrub the xml from ORCID's API's. This replaces hyphens with underscores for element names.
    def scrub_incoming_xml
      scrub(to_xml, "-", "_")
    end

    def valid?
      if (given_names[0].empty?)
        return false
      end
      super
    end

    set_terminology do |t|
      t.root(path: "orcid_bio")
      t.personal_details(:path=>"personal_details"){
        t.given_names(:path=>"given_names")
        t.family_name(:path=>"family_name")
        t.credit_name(:path=>"credit_name")
        t.other_names(:path=>"other_names"){
          t.other_name(:path=>"other_name")
        }
      }
      t.title(:path=> "title")
      t.subtitle(:path=> "subtitle")
      t.translated_title(:path=> "translated_title") {
        t.language_code(:path=>{:attribute=>"language_code"})
      }
      t.journal_title(:path=> "journal_title")
      t.short_description(:path=> "short_description")
      t.citation(:path=> "citation")
      t.citation_type(:path=> "work_citation_type")
      t.work_type(:path=> "work_type")
      t.publication_date_year(:path=> "year")
      t.publication_date_month(:path=> "month")
      t.external_identifiers(:path=>"work_external_identifiers"){
        t.external_identifier(:path=>"work_external_identifier"){
          t.external_identifier_type(:path=> "work_external_identifier_type")
          t.external_identifier_id(:path=> "work_external_identifier_id")
        }
      }
      t.url(:path=> "url")
      t.contributor_credit_name(:path=> "credit_name")
      t.contributor_sequence(:path=> "contributor_sequence")
      t.contributor_role(:path=> "contributor_role")
      t.language_code(:path=> "language_code")
      t.country(:path=> "country")
    end

    def self.xml_template
      Nokogiri::XML.parse("<orcid-bio/>")
    end

    def ==(comparison_object)
      super || comparison_object.instance_of?(self.class) &&
        id.present? &&
        comparison_object.id == id
    end

    def id
      if put_code.present?
        put_code
      elsif title[0].empty? && work_type[0].empty?
        [title, work_type]
      else
        nil
      end
    end
  end
end
