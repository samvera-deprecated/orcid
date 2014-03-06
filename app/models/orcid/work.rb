module Orcid
  # A well-defined data structure that coordinates with its :template in order
  # to generate XML that can be POSTed/PUT as an Orcid Work.

  require 'orcid/xml_scrubber'
  require "om"
  
  class Work

    include OM::XML::Document
    include Orcid::XmlScrubber

    VALID_WORK_TYPES = [
      "artistic-performance","book-chapter","book-review","book","conference-abstract","conference-paper","conference-poster","data-set","dictionary-entry","disclosure","dissertation","edited-book","encyclopedia-entry","invention","journal-article","journal-issue","lecture-speech","license","magazine-article","manual","newsletter-article","newspaper-article","online-resource","other","patent","registered-copyright","report","research-technique","research-tool","spin-off-company","standards-and-policy","supervised-student-publication","technical-standard","test","translation","trademark","website","working-paper",
    ].freeze

    #include Virtus.model
    #include ActiveModel::Validations
    extend ActiveModel::Naming

    #attribute :title, String
    #validates :title, presence: true

    #attribute :work_type, String
    #validates :work_type, presence: true, inclusion: { in: VALID_WORK_TYPES }

    #attribute :put_code, String

    def initialize(attributes={})
      attributes.each do |key, value|
        send("#{key}=", value)
      end
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
      t.root(path: "orcid_work", :xmlns => "http://www.orcid.org/ns/orcid" )
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
      Nokogiri::XML.parse('
            <orcid_work xmlns="http://www.orcid.org/ns/orcid">
              <work_title>
                <title/>
                <subtitle/>
                <translated_title language_code="">
                </translated_title>
              </work_title>
              <journal_title/>
              <short_description/>
              <work_citation>
                <work_citation_type/>
                <citation/>
              </work_citation>
              <work_type/>
              <publication_date>
                <year/>
                <month/>
              </publication_date>
              <work_external_identifiers>
                <work_external_identifier>
                  <work_external_identifier_type/>
                  <work_external_identifier_id/>
                </work_external_identifier>
              </work_external_identifiers>
              <url/>
              <work_contributors>
                <contributor>
                  <credit_name/>
                  <contributor_attributes>
                    <contributor_sequence/>
                    <contributor_role/>
                  </contributor_attributes>
                </contributor>
              </work_contributors>
              <language_code/>
              <country/>
            </orcid_work>')
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
        nil
      else
        [title[0], work_type[0]]
      end
    end
  end
end
