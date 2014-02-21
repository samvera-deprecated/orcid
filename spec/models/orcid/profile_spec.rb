require 'spec_helper'

module Orcid
  describe Profile do
    let(:orcid_profile_id) { '0001-0002-0003-0004' }
    let(:remote_service) { double('Service') }
    let(:mapper) { double("Mapper") }
    let(:non_orcid_work) { double("A non-ORCID Work") }
    let(:orcid_work) { double("Orcid::Work") }
    let(:xml_renderer) { double("Renderer") }
    let(:xml_parser) { double("Parser") }
    let(:xml) { double("XML Payload")}

    subject {
      described_class.new(
        orcid_profile_id,
        mapper: mapper,
        remote_service: remote_service,
        xml_renderer: xml_renderer,
        xml_parser: xml_parser
      )
    }

    def should_map(source, target)
      mapper.should_receive(:map).with(source, target: 'orcid/work').and_return(target)
    end

    context '#remote_works' do
      let(:parsed_object) { double("Parsed Object")}
      let(:response_body) { double("XML Response") }
      it 'should parse the response body' do
        xml_parser.should_receive(:call).with(response_body).and_return(parsed_object)
        remote_service.should_receive(:call).with(orcid_profile_id, request_method: :get).and_return(response_body)

        expect(subject.remote_works).to eq(parsed_object)
      end
    end


    context '#append_new_work' do
      it 'should transform the input work to xml and deliver to the remote_service' do
        xml_renderer.should_receive(:call).with([orcid_work]).and_return(xml)
        remote_service.should_receive(:call).with(orcid_profile_id, body: xml, request_method: :post)

        should_map(non_orcid_work, orcid_work)

        subject.append_new_work(non_orcid_work)
      end
    end

    context '#replace_works_with' do
      it 'should transform the input work to xml and deliver to the remote_service' do
        xml_renderer.should_receive(:call).with([orcid_work]).and_return(xml)
        remote_service.should_receive(:call).with(orcid_profile_id, body: xml, request_method: :put)

        should_map(non_orcid_work, orcid_work)

        subject.replace_works_with(non_orcid_work)
      end
    end
  end
end
