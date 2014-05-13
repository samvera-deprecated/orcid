require 'spec_helper'

describe 'public api query', requires_net_connect: true do
  around(:each) do |example|
    WebMock.allow_net_connect!
    example.run
    WebMock.disable_net_connect!
  end

  Given(:runner) {
    Orcid::Remote::ProfileQueryService.new
  }
  context 'with simple query' do
    Given(:parameters) { { email: 'jeremy.n.friesen@gmail.com' } }
    When(:result) { runner.call(parameters) }
    Then { expect(result.size).to eq(1) }
  end

  context 'with bad query' do
    Given(:parameters) { { hobomancer: 'jeremy.n.friesen@gmail.com' } }
    When(:result) { runner.call(parameters) }
    Then { expect(result).to have_failed(OAuth2::Error) }
  end

  context 'with a text query' do
    Given(:parameters) { { text: '"Jeremy Friesen"' } }
    When(:result) { runner.call(parameters) }
    Then { expect(result.size).to be > 0 }
  end

  context 'with bogus text query' do
    Given(:parameters) { { text: 'orcid@sufia.org' } }
    When(:result) { runner.call(parameters) }
    Then { expect(result.size).to eq 0 }
  end

  context 'with a compound text query' do
    Given(:parameters) { { email: "nobody@gmail.com", text: '"Jeremy+Friesen"' } }
    When(:result) { runner.call(parameters) }
    Then { expect(result.size).to eq 0 }
  end
end
