require 'spec_helper'

module Orcid
  describe Work do
    before :all do
      @test_work = Orcid::Work.new
      @test_work.title = "Title"
      @test_work.work_type = "journal-article"
      @test_work.put_code = "1234"
    end
    subject{@test_work}

    its(:title) { should eq ['Title'] }
    its(:work_type) { should eq ['journal-article'] }
    its(:put_code) { should eq '1234' }
    its(:valid?) { should eq true }

    context '#id' do
      context 'with put_code' do
        before :all do
          @test_work = Orcid::Work.new
          @test_work.put_code = "1234"
        end
        subject{@test_work}
        its(:id) { should eq subject.put_code}
      end
      context 'with title and work type' do
        before :all do
          @test_work = Orcid::Work.new
          @test_work.title = "Title"
          @test_work.work_type = "journal-article"
        end
        subject{@test_work}
        its(:id) { should eq [subject.title(0), subject.work_type(0)]}
      end

      context 'without title, work type, and put_code' do
        before :all do
          @test_work = Orcid::Work.new
        end
        subject{@test_work}
        its(:id) { should eq nil }
      end
    end

    context '#to_xml' do
      it 'should return an XML document' do
        rendered = subject.to_xml
        expect(rendered).to have_tag('orcid-work') do
          with_tag('work-title title', text: subject.title)
          with_tag('work-type', text: subject.work_type)
        end
      end
    end
  end


end
