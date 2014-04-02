require 'spec_helper'

module Orcid
  describe Work::XmlParser do
    let(:xml) { fixture_file('orcid_works.xml').read }

    context '.call' do
      subject { described_class.call(xml) }
      its(:size) { should eq 2 }
      its(:first) { should be_an_instance_of Orcid::Work }
      its(:last) { should be_an_instance_of Orcid::Work }

      context 'first element' do
        subject { described_class.call(xml).first }

        its(:title) { should eq "Another Test Drive" }
        its(:put_code) { should eq "303475" }
        its(:work_type) { should eq "test" }
        its(:journal_title) { should_not be_present }
        its(:short_description) { should_not be_present }
        its(:citation_type) { should_not be_present }
        its(:citation) { should_not be_present }
        its(:publication_month) { should_not be_present }
        its(:publication_year) { should_not be_present }
        its(:url) { should_not be_present }
        its(:language_code) { should_not be_present }
        its(:country) { should_not be_present }
      end

      context 'last element' do
        subject { described_class.call(xml).last }

        its(:title) { should eq "Test Driven Orcid Integration" }
        its(:put_code) { should eq "303474" }
        its(:work_type) { should eq "test" }
      end
    end
  end

end
