require 'spec_helper'

module Orcid
  describe Work do
    let(:attributes) { {title: 'Hello', work_type: 'journal-article', put_code: '1234' }}
    subject { described_class.new(attributes) }

    its(:title) { should eq attributes[:title] }
    its(:work_type) { should eq attributes[:work_type] }
    its(:put_code) { should eq attributes[:put_code] }
    its(:valid?) { should eq true }

    context '#id' do
      context 'with put_code' do
        subject { described_class.new(put_code: '123') }
        its(:id) { should eq subject.put_code}
      end
      context 'with title and work type' do
        subject { described_class.new(title: 'Title', work_type: 'journal-article') }
        its(:id) { should eq [subject.title, subject.work_type]}
      end

      context 'without title, work type, and put_code' do
        subject { described_class.new }
        its(:id) { should eq nil }
      end
    end

    context '#to_xml' do
      it 'should return an XML document' do
        rendered = subject.to_xml
        expect(rendered).to have_tag('orcid-profile orcid-activities orcid-works orcid-work') do
          with_tag('work-title title', text: subject.title)
          with_tag('work-type', text: subject.work_type)
        end
      end
    end
  end

  describe Work::XmlRenderer do
    let(:work) { Orcid::Work.new(title: 'Hello', work_type: 'journal-article') }
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

  describe Work::XmlParser do
    let(:xml) { fixture_file('orcid_works.xml').read }
    let(:work_1) { Orcid::Work.new(title: 'Another Test Drive', work_type: 'test', put_code: '303475')}
    let(:work_2) { Orcid::Work.new(title: 'Test Driven Orcid Integration', work_type: 'test', put_code: '303474')}
    subject { described_class.new(xml) }

    context '.call' do
      it 'should return an array of Orcid::Work' do
        expect(described_class.call(xml)).to eq([work_1, work_2])
      end
    end

    context '#call' do
      it 'should return an array of Orcid::Work' do
        returned = subject.call
        expect(returned).to eq([work_1, work_2])
      end
    end
  end
end
