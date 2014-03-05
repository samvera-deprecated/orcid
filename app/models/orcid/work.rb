module Orcid
  # A well-defined data structure that coordinates with its :template in order
  # to generate XML that can be POSTed/PUT as an Orcid Work.

  require "om"

  class Work

    include OM::XML::Document

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
      t.root(path: "orcid-work")
      t.title(:path=> "title")
      t.subtitle(:path=> "subtitle")
      t.translated_title(:path=> "translated-title") {
        t.language_code(:path=>{:attribute=>"language-code"})
      }
      t.journal_title(:path=> "journal-title")
      t.short_description(:path=> "short-description")
      t.citation(:path=> "citation")
      t.citation_type(:path=> "work-citation-type")
      t.work_type(:path=> "work-type")
      t.publication_date_year(:path=> "year")
      t.publication_date_month(:path=> "month")
      t.external_identifier_type(:path=> "work-external-identifier-type")
      t.external_identifier_id(:path=> "work-external-identifier-id")
      t.url(:path=> "url")
      t.contributor_credit_name(:path=> "credit-name")
      t.contributor_sequence(:path=> "contributor-sequence")
      t.contributor_role(:path=> "contributor-role")
      t.language_code(:path=> "language-code")
      t.country(:path=> "country")
    end

    def self.xml_template
      Nokogiri::XML.parse("
            <orcid-work>
              <work-title>
                <title/>
                <subtitle/>
                <translated-title language-code=\"x\">
                </translated-title>
              </work-title>
              <journal-title/>
              <short-description/>
              <work-citation>
                <work-citation-type/>
                <citation/>
              </work-citation>
              <work-type/>
              <publication-date>
                <year/>
                <month/>
              </publication-date>
              <work-external-identifiers>
                <work-external-identifier>
                  <work-external-identifier-type/>
                  <work-external-identifier-id/>
                </work-external-identifier>
              </work-external-identifiers>
              <url/>
              <work-contributors>
                <contributor>
                  <credit-name/>
                  <contributor-attributes>
                    <contributor-sequence/>
                    <contributor-role/>
                  </contributor-attributes>
                </contributor>
              </work-contributors>
              <language-code/>
              <country/>
            </orcid-work>")
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
