require 'spec_helper'

module Orcid
  describe Work do
    let(:attributes) { {title: 'Title', work_type: 'journal-article', put_code: '1234' }}
    subject {
      described_class.new(attributes)
    }

    its(:title) { should eq ['Title'] }
    its(:work_type) { should eq ['journal-article'] }
    its(:put_code) { should eq '1234' }
    its(:valid?) { should eq true }

    context '#id' do
      context 'with put_code' do
        subject { described_class.new(put_code: '123') }
        its(:id) { should eq subject.put_code}
      end
      context 'with title and work type' do
        subject { described_class.new(title: 'Title', work_type: 'journal-article') }
        its(:id) { should eq ['Title', 'journal-article']}
      end

      context 'without title, work type, and put_code' do
        subject { described_class.new }
        its(:id) { should eq nil }
      end
    end

    context '#to_xml' do
      it 'should return a scrubbed XML document' do
        rendered = subject.outgoing_xml
        expect(rendered).to have_tag('orcid-work') do
          with_tag('work-title title', text: 'Title')
          with_tag('work-type', text: 'journal-article')
        end
      end
    end
  end


end
