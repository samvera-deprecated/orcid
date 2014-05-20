module Orcid
  class Work
    # Responsible for transforming a Work into an Orcid Work XML document
    class XmlRenderer
      def self.call(works, options = {})
        new(works, options).call
      end

      attr_reader :works, :template
      def initialize(works, options = {})
        self.works = works
        @template = options.fetch(:template) { default_template }
      end

      def call
        ERB.new(template).result(binding)
      end

      protected

      def works=(thing)
        @works = Array.wrap(thing)
      end

      def default_template
        template_name = 'app/templates/orcid/work.template.v1.1.xml.erb'
        Orcid::Engine.root.join(template_name).read
      end
    end
  end
