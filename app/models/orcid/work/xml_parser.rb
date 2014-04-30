module Orcid
  class Work
    # Responsible for taking an Orcid Work and extracting the value/text from
    # the document and reifying an Orcid::Work object.
    class XmlParser
      def self.call(xml)
        new(xml).call
      end

      attr_reader :xml
      def initialize(xml)
        @xml = xml
      end

      def call
        document.css('orcid-works orcid-work').map do |node|
          transform(node)
        end
      end

      private

      def document
        @document ||= Nokogiri::XML.parse(xml)
      end

      def transform(node)
        Work.new.tap do |work|
          work.put_code = node.attributes.fetch('put-code').value
          work.title = node.css('work-title title').text
          work.work_type = node.css('work-type').text
          work.journal_title = node.css('journal-title').text
          work.short_description = node.css('short-description').text
          work.citation_type = node.css('work-citation work-citation-type').text
          work.citation = node.css('work-citation citation').text
          work.publication_year = node.css('publication-date year').text
          work.publication_month = node.css('publication-date month').text
          work.url = node.css('url').text
          work.language_code = node.css('language_code').text
          work.country = node.css('country').text
        end
      end
    end
  end
end
