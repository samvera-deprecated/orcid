require 'spec_helper'

module Orcid
  describe Work do
    let(:attributes) {
      {
        title: 'Hello',
        work_type: 'journal-article',
        put_code: '1234',
        external_identifiers: [ {type: 'doi', identifier: 'abc-123' }]
      }
    }
    subject { described_class.new(attributes) }

    its(:title) { should eq attributes[:title] }
    its(:subtitle) { should eq nil }
    its(:work_type) { should eq attributes[:work_type] }
    its(:put_code) { should eq attributes[:put_code] }
    its(:external_identifiers) { should be_an_instance_of(Array) }
    its(:valid?) { should eq true }

    context '#==' do
      context 'differing objects' do
        it 'should not be ==' do
          expect(subject == 'other').to eq(false)
        end
      end
      context 'same classes but different objects' do
        it 'should not be ==' do
          other = described_class.new
          expect(subject == other).to eq(false)
        end
      end
      context 'same classes with same put code' do
        it 'should be ==' do
          other = described_class.new(put_code: 123)
          subject.put_code = 123
          expect(subject == other).to eq(true)
        end
      end
    end

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
          with_tag('work-external-identifiers work-external-identifier', count: 1) do
            with_tag('work-external-identifier-type', text: 'doi')
            with_tag('work-external-identifier-id', text: 'abc-123')
          end
        end
      end
    end
  end

end
