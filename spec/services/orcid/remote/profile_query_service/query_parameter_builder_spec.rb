require 'fast_helper'
require 'orcid/remote/profile_query_service/query_parameter_builder'

module Orcid::Remote

  describe ProfileLookupService::QueryParameterBuilder do
    When(:response) { described_class.call(input) }
    context 'single word input' do
      Given(:input) {
        { text: "Hello", email: 'jeremy.n.friesen@gmail.com' }
      }
      Then { expect(response).to eq(q: "email:#{input[:email]} AND text:#{input[:text]}") }
    end

    context 'empty string and nil' do
      Given(:input) {
        { text: "" , email: nil}
      }
      Then { expect(response).to eq(q: "") }
    end

    context 'multi-word named input' do
      Given(:input) {
        { other_names: %("Tim O'Connor" -"Oak"), email: 'jeremy.n.friesen@gmail.com' }
      }
      Then { expect(response).to eq(q: "other-names:#{input[:other_names]} AND email:#{input[:email]}") }
    end

    context 'q is provided along with other params' do
      Given(:input) {
        { q: %("Tim O'Connor" -"Oak"), email: 'jeremy.n.friesen@gmail.com' }
      }
      Then { expect(response).to eq(q: "email:#{input[:email]} AND text:#{input[:q]}") }
    end

    context 'q is provided with text params' do
      Given(:input) {
        { q: %("Tim O'Connor" -"Oak"), text: 'jeremy.n.friesen@gmail.com' }
      }
      Then { expect(response).to eq(q: "text:((#{input[:q]}) AND (#{input[:text]}))") }
    end

  end
end
