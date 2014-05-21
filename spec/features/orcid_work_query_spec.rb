require 'spec_helper'

describe 'orcid work query', requires_net_connect: true do
  around(:each) do |example|
    WebMock.allow_net_connect!
    example.run
    WebMock.disable_net_connect!
  end
  Given(:token) { Orcid.client_credentials_token('/read-public') }

  # This profile exists on the Sandbox. But for how long? Who knows.
  Given(:orcid_profile_id) { '0000-0002-1117-8571' }
  Given(:remote_work_service) { Orcid::Remote::WorkService.new(orcid_profile_id, method: :get, token: token) }
  Given(:remote_work_document) { remote_work_service.call }
  When(:works) { Orcid::Work::XmlParser.call(remote_work_document) }
  Then { expect(works.size).to_not be 0 }
end
