require 'fast_helper'
require 'lib/orcid/configuration/provider'

module Orcid
  describe Configuration::Provider do

    let(:storage) {
      {
        'ORCID_APP_AUTHENTICATION_SCOPE' => '_APP_AUTHENTICATION_SCOPE',
        'ORCID_SITE_URL' => '_SITE_URL',
        'ORCID_TOKEN_URL' => '_TOKEN_URL',
        'ORCID_REMOTE_SIGNIN_URL' => '_REMOTE_SIGNIN_URL',
        'ORCID_AUTHORIZE_URL' => '_AUTHORIZE_URL',
        'ORCID_APP_ID' => '_APP_ID',
        'ORCID_APP_SECRET' => '_APP_SECRET',
      }
    }

    subject { described_class.new(storage) }

    its(:authentication_scope) { should eq storage.fetch('ORCID_APP_AUTHENTICATION_SCOPE') }
    its(:site_url) { should eq storage.fetch('ORCID_SITE_URL') }
    its(:token_url) { should eq storage.fetch('ORCID_TOKEN_URL') }
    its(:signin_via_json_url) { should eq storage.fetch('ORCID_REMOTE_SIGNIN_URL') }
    its(:authorize_url) { should eq storage.fetch('ORCID_AUTHORIZE_URL') }
    its(:id) { should eq storage.fetch('ORCID_APP_ID') }
    its(:secret) { should eq storage.fetch('ORCID_APP_SECRET') }

  end
end
