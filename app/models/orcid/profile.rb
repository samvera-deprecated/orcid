module Orcid
  class Profile

    attr_reader :orcid_profile_id, :mapper, :remote_service, :xml_renderer, :xml_parser
    private :mapper
    def initialize(orcid_profile_id, config = {})
      @orcid_profile_id = orcid_profile_id
      @mapper = config.fetch(:mapper) { ::Mappy }
      @remote_service = config.fetch(:remote_service) { Orcid::RemoteWorkService }
      @xml_renderer = config.fetch(:xml_renderer) { Orcid::Work::XmlRenderer }
      @xml_parser = config.fetch(:xml_parser) { Orcid::Work::XmlParser }
    end

    def remote_works(options = {})
      @remote_works = nil if options.fetch(:force, false)
      @remote_works ||= begin
        response = remote_service.call(orcid_profile_id, request_method: :get)
        xml_parser.call(response)
      end
    end

    def append_new_work(*works)
      orcid_works = normalize_work(*works)
      xml = xml_renderer.call(orcid_works)
      remote_service.call(orcid_profile_id, request_method: :post, body: xml)
    end

    def replace_works_with(*works)
      orcid_works = normalize_work(*works)
      xml = xml_renderer.call(orcid_works)
      remote_service.call(orcid_profile_id, request_method: :put, body: xml)
    end

    protected

    # Note: We can handle
    def normalize_work(*works)
      Array(works).flatten.compact.collect do |work|
        mapper.map(work, target: 'orcid/work')
      end
    end

  end
end
