require 'spec_helper'

module Orcid
  describe Work::XmlRenderer do
    let(:work) { Work.new(title: 'Hello', work_type: 'journal-article') }
    subject { described_class.new(work) }

    context '#call' do
      it 'should return an XML document' do
        rendered = subject.call
        expect(rendered).to have_tag('orcid-profile orcid-activities orcid-works orcid-work') do
          with_tag('work-title title', text: work.title)
          with_tag('work-type', text: work.work_type)
        end
      end
    end
  end
end
