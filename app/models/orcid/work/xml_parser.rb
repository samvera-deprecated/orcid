module Orcid
  class Work
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
        Work.new.tap do |work|
          work.put_code = node.attributes.fetch("put-code").value
          work.title = node.css('work-title title').text
          work.work_type = node.css('work-type').text
        end
      end
    end
  end
end
