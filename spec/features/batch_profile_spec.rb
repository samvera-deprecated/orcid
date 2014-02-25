require 'spec_helper'

describe 'batch profile behavior' do
  around(:each) do |example|
    WebMock.allow_net_connect!
    example.run
    WebMock.disable_net_connect!
  end

  Given(:runner) {
    lambda { |person|
      Orcid::ProfileLookupRunner.new {|on|
        on.found {|results| person.found(results) }
        on.not_found { person.not_found }
      }.call(email: person.email)
    }
  }
  Given(:person) {
    double('Person', email: email, found: true, not_found: true)
  }
  context 'with existing email' do
    Given(:email) { 'jeremy.n.friesen@gmail.com' }
    When { runner.call(person) }
    Then { person.should have_received(:found) }
  end
  context 'without an existing email' do
    Given(:email) { 'nobody@nowhere.zorg' }
    When { runner.call(person) }
    Then { person.should have_received(:not_found) }
  end
end
