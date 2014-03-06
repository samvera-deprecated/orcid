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

    # include Virtus.model
    # include ActiveModel::Validations
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

    def initialize(attributes={})
      attributes.each do |key, value|
        send("#{key}=", value)
      end
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
      t.biography(:path=>"biography")
      t.researcher_urls(:path=>"researcher_urls"){
        t.researcher_url(:path=>"researcher_url"){
          t.url_name(:path=>"url_name")
          t.url(:path=>"url")
        }
      }
 
      t.contact_details(:path=>"contact_details"){
        t.email(:path=>"email"){
          t.current(:path=>{:attribute=>"current"})
          t.primary(:path=>{:attribute=>"primary"})
        }
        t.address(:path=>"address"){
          t.country(:path=>"country")
        }
      }
      t.keywords(:path=>"keywords"){
        t.keyword(:path=>"keyword")
      }
  
      t.external_identifiers(:path=>"work_external_identifiers"){
        t.external_identifier(:path=>"work_external_identifier"){
          t.external_id_common_name(:path=> "external_id_common_name")
          t.external_id_reference(:path=> "external_id_reference")
          t.external_id_url(:path=> "external_id_url")
        }
      }
      
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
      elsif given_names[0].empty?
        [given_names]
      else
        nil
      end
    end
  end
end
