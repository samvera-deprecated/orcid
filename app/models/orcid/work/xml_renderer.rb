module Orcid
  class Work
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
        @works = Array.wrap(thing)
      end

    end
  end
end
