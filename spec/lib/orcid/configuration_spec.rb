require 'spec_helper'

module Orcid
  describe Configuration do

    subject { described_class.new }

    its(:provider_name) { should eq 'orcid'}
    its(:provider) { should be_an_instance_of Configuration::Provider }
    its(:authentication_model) { should eq Devise::MultiAuth::Authentication }

    its(:mapper) { should respond_to :map }
    its(:mapper) { should respond_to :configure }

  end
end
