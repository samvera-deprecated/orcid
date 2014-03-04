require 'spec_helper'

module Orcid
  describe Configuration do

    subject { described_class.new }

    its(:parent_controller) { should be_an_instance_of String }
    its(:provider) { should be_an_instance_of Configuration::Provider }
    its(:authentication_model) { should eq Devise::MultiAuth::Authentication }

    its(:mapper) { should respond_to :map }
    its(:mapper) { should respond_to :configure }

    context 'mapping to an Orcid::Work' do
      let(:legend) {
        [
          [:title, :title],
          [lambda{|*| 'spaghetti'}, :work_type]
        ]
      }
      let(:title) { 'Hello World' }
      let(:article) { NonOrcid::Article.new(title: title)}
      before(:each) do
        subject.register_mapping_to_orcid_work('non_orcid/article', legend)
      end

      it 'should configure the mapper' do
        orcid_work = subject.mapper.map(article, target: 'orcid/work')
        expect(orcid_work.work_type).to eq('spaghetti')
        expect(orcid_work.title).to eq(title)
        expect(orcid_work).to be_an_instance_of(Orcid::Work)
      end

    end

  end
end
