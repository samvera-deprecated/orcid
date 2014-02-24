require 'spec_helper'

module Orcid
  describe ProfileLookup do
    Given(:context) { double(invoked: true) }
    Given(:query_result) { false }
    Given(:query_service) { double("Query Service", call: query_result) }
    Given(:config) { {query_service: query_service } }
    Given(:runner) {
      described_class.new(config) { |on|
        on.found {|results| context.invoked("FOUND", results) }
        on.not_found { context.invoked("NOT FOUND") }
      }
    }
    Given(:parameters) { { email: 'hello@world.com' } }

    context '.found' do
      Given(:query_result) { [1,2] }
      When { runner.call(parameters) }
      Then {
        query_service.should(
          have_received(:call).
          with(q: "email:#{parameters.fetch(:email)}")
        )
      }
      Then { context.should have_received(:invoked).with("FOUND", query_result)}
    end

    context '.not_found' do
      Given(:query_result) { [] }
      When { runner.call(parameters) }
      Then {
        query_service.should(
          have_received(:call).
          with(q: "email:#{parameters.fetch(:email)}")
        )
      }
      Then { context.should have_received(:invoked).with("NOT FOUND")}
    end

  end
end
