require 'spec_helper'

module Orcid
  describe Configuration do

    subject { described_class.new }

    its(:provider_name) { should eq 'orcid'}
    its(:authentication_model) { should eq Devise::MultiAuth::Authentication }

  end
end
