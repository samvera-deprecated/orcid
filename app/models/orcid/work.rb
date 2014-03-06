module Orcid
  # A well-defined data structure that coordinates with its :template in order
  # to generate XML that can be POSTed/PUT as an Orcid Work.

  require "om"

  class Work

    include OM::XML::Document
    include XmlScrubber

    VALID_WORK_TYPES = [
      "artistic-performance","book-chapter","book-review","book","conference-abstract","conference-paper","conference-poster","data-set","dictionary-entry","disclosure","dissertation","edited-book","encyclopedia-entry","invention","journal-article","journal-issue","lecture-speech","license","magazine-article","manual","newsletter-article","newspaper-article","online-resource","other","patent","registered-copyright","report","research-technique","research-tool","spin-off-company","standards-and-policy","supervised-student-publication","technical-standard","test","translation","trademark","website","working-paper",
    ].freeze

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
      if (title[0].empty?)
        return false
      end
      if (work_type[0].empty?)
        return false
      end
      if (!VALID_WORK_TYPES.include? work_type[0])
        return false
      end
      super
    end

    set_terminology do |t|
      t.root(path: "orcid_work")
      t.work_title(:path=>"work_title"){
        t.title(:path=> "title")
        t.subtitle(:path=> "subtitle")
        t.translated_title(:path=> "translated_title") {
          t.language_code(:path=>{:attribute=>"language_code"})
        }
      }
      t.journal_title(:path=> "journal_title")
      t.short_description(:path=> "short_description")
      t.work_citation(:path=> "work_citation"){
        t.citation_type(:path=> "work_citation_type")
        t.citation(:path=> "citation")
      }
      t.work_type(:path=> "work_type")
      t.publication_date(:path=> "publication_date"){
        t.publication_date_year(:path=> "year")
        t.publication_date_month(:path=> "month")
      }
      t.external_identifiers(:path=>"work_external_identifiers"){
        t.external_identifier(:path=>"work_external_identifier"){
          t.external_identifier_type(:path=> "work_external_identifier_type")
          t.external_identifier_id(:path=> "work_external_identifier_id")
        }
      }
      t.url(:path=> "url")
      t.work_contributors(:path=>"work_contributors"){
        t.contributor(:path=>"contributor"){
          t.contributor_orcid(:path=> "contributor_orcid")
          t.contributor_credit_name(:path=> "credit_name")
          t.contributor_email(:path=> "contributor_email")
          t.contributor_attributes(:path=>"contributor_attributes"){
            t.contributor_sequence(:path=> "contributor_sequence")
            t.contributor_role(:path=> "contributor_role")
          }
        }
      }
      
      t.language_code(:path=> "language_code")
      t.country(:path=> "country")
    end

    def self.xml_template
      Nokogiri::XML.parse("<orcid_work/>")
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
