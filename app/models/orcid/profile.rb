module Orcid
  # Provides a container around an Orcid Profile and its relation to the Orcid
  # Works.
  class Profile
    attr_reader :orcid_profile_id, :mapper, :remote_service, :xml_renderer, :xml_parser
    private :mapper, :remote_service, :xml_renderer, :xml_parser
    def initialize(orcid_profile_id, collaborators = {})
      @orcid_profile_id = orcid_profile_id
      @mapper = collaborators.fetch(:mapper) { default_mapper }
      @remote_service = collaborators.fetch(:remote_service) { default_remote_service }
      @xml_renderer = collaborators.fetch(:xml_renderer) { default_xml_renderer }
      @xml_parser = collaborators.fetch(:xml_parser) { default_xml_parser }
    end

    # Answers the question: Has the user been authenticated via the ORCID
    # system.
    #
    # @TODO - Extract this to the Orcid::ProfileStatus object. As the method
    # is referenced via a controller, this can easily be moved.
    def verified_authentication?
      Orcid.authenticated_orcid?(orcid_profile_id)
    end

    def remote_works(options = {})
      @remote_works = nil if options.fetch(:force, false)
      @remote_works ||= begin
        response = remote_service.call(orcid_profile_id, request_method: :get)
        xml_parser.call(response)
      end
    end

    def append_new_work(*works)
      request_work_changes_via(:post, *works)
    end

    def replace_works_with(*works)
      request_work_changes_via(:put, *works)
    end

    protected

    def request_work_changes_via(request_method, *works)
      orcid_works = normalize_work(*works)
      xml = xml_renderer.call(orcid_works)
      remote_service.call(orcid_profile_id, request_method: request_method, body: xml)
    end

    def default_mapper
      Orcid.mapper
    end

    def default_remote_service
      Orcid::Remote::WorkService
    end

    def default_xml_renderer
      Orcid::Work::XmlRenderer
    end

    def default_xml_parser
      Orcid::Work::XmlParser
    end

    # Note: We can handle
    def normalize_work(*works)
      Array.wrap(works).map do |work|
        mapper.map(work, target: 'orcid/work')
      end
    end
  end
end
