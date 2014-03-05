module Orcid
  # A well-defined data structure that coordinates with its :template in order
  # to generate XML that can be POSTed/PUT as an Orcid Work.

  require "om"

  class Work

    include OM::XML::Document

    VALID_WORK_TYPES = [
      "artistic-performance","book-chapter","book-review","book","conference-abstract","conference-paper","conference-poster","data-set","dictionary-entry","disclosure","dissertation","edited-book","encyclopedia-entry","invention","journal-article","journal-issue","lecture-speech","license","magazine-article","manual","newsletter-article","newspaper-article","online-resource","other","patent","registered-copyright","report","research-technique","research-tool","spin-off-company","standards-and-policy","supervised-student-publication","technical-standard","test","translation","trademark","website","working-paper",
    ].freeze

    include ActiveModel::Validations
    extend ActiveModel::Naming

    #attribute :title, String
    #validates :title, presence: true

    #attribute :work_type, String
    #validates :work_type, presence: true, inclusion: { in: VALID_WORK_TYPES }

    #attribute :put_code, String

    set_terminology do |t|
      t.root(path: "orcid-work")
      t.title(:path=>'work-title')
    end

    def self.xml_template
      Nokogiri::XML.parse("<orcid-work><work-title></work-title></orcid-work>")
    end

    def ==(comparison_object)
      super || comparison_object.instance_of?(self.class) &&
        id.present? &&
        comparison_object.id == id
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
