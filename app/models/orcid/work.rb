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

    extend ActiveModel::Naming

    attr_accessor :put_code

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
      true
    end

    class XmlRenderer
      def self.call(works, options = {})
        new(works, options).call
      end

      attr_reader :works, :template
      def initialize(works, options = {})
        self.works = works
        @template = options.fetch(:template_path) { Orcid::Engine.root.join('app/templates/orcid/work.template.v1.1.xml.erb').read }
      end

      def call
        ERB.new(template).result(binding)
      end

      protected
      def works=(thing)
        @works = Array(thing)
      end

    end

    class XmlParser
      def self.call(xml)
        new(xml).call
      end

      attr_reader :xml
      def initialize(xml)
        @xml = xml
      end

      def call
        document = Nokogiri::XML.parse(xml)
        document.css('orcid-works orcid-work').collect do |node|
          transform(node)
        end
      end

      private
      def transform(node)
        Orcid::Work.new.tap do |work|
          work.put_code = node.attributes.fetch("put-code").value
          work.title = node.css('work-title title').text
          work.work_type = node.css('work-type').text
        end
      end
    end

    set_terminology do |t|
    
     t.root(path: "orcid_work", :xmlns => "http://www.orcid.org/ns/orcid" )
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

      # This allows nested nodes to be referenced directly, like work.citation_type instead
      # of work.work_citation.citation_type

      t.title(:proxy=>[:work_title, :title])
      t.subtitle(:proxy=>[:work_title, :subtitle])
      t.translated_title(:proxy=>[:work_title, :translated_title])
      t.language_code(:proxy=>[:work_title, :translated_title, :language_code])
      t.citation_type(:proxy=>[:work_citation, :citation_type])
      t.citation(:proxy=>[:work_citation, :citation])
      t.publication_date_year(:proxy=>[:publication_date, :publication_date_year])
      t.publication_date_month(:proxy=>[:publication_date, :publication_date_month])
      t.external_identifier(:proxy=>[:external_identifiers, :external_identifier])
      t.external_identifier_type(:proxy=>[:external_identifiers, :external_identifier, :external_identifier_type])
      t.external_identifier_id(:proxy=>[:external_identifiers, :external_identifier, :external_identifier_id])
      t.contributor(:proxy=>[:work_contributors, :contributor])
      t.contributor_orcid(:proxy=>[:work_contributors, :contributor, :contributor_orcid])
      t.contributor_credit_name(:proxy=>[:work_contributors, :contributor, :contributor_credit_name])
      t.contributor_email(:proxy=>[:work_contributors, :contributor, :contributor_email])
      t.contributor_attributes(:proxy=>[:work_contributors, :contributor, :contributor_attributes])
      t.contributor_sequence(:proxy=>[:work_contributors, :contributor, :contributor_attributes, :contributor_sequence])
      t.contributor_role(:proxy=>[:work_contributors, :contributor, :contributor_attributes, :contributor_role])
  
    end
    
  
    #the entire node tree must be specified here, otherwise errors will occur
    def self.xml_template
      Nokogiri::XML.parse('<orcid_work xmlns="http://www.orcid.org/ns/orcid">
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
