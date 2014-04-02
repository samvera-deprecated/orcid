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
