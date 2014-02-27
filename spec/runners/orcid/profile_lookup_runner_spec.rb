require 'fast_helper'
require 'orcid/profile_lookup_runner'

module Orcid
  describe ProfileLookupRunner do
    Given(:context) { double(invoked: true) }
    Given(:query_result) { false }
    Given(:query_parameter_builder) { double("Query Builder", call: built_parameters) }
    Given(:built_parameters) { double("Parameters") }
    Given(:query_service) { double("Query Service", call: query_result) }
    Given(:config) { {query_service: query_service, query_parameter_builder: query_parameter_builder } }
    Given(:runner) {
      described_class.new(config) { |on|
        on.found {|results| context.invoked("FOUND", results) }
        on.not_found { context.invoked("NOT FOUND") }
      }
    }
    Given(:parameters) { { email: 'hello@world.com' } }

    context '.found' do
      Given(:query_result) { [1,2] }

      When(:returned_value) { runner.call(parameters) }

      Then { expect(returned_value).to eq(query_result) }
      And {
        query_parameter_builder.should have_received(:call).with(parameters)
      }
      And {
        query_service.should(
          have_received(:call).
          with(built_parameters)
        )
      }
      And { context.should have_received(:invoked).with("FOUND", query_result)}
    end

    context '.not_found' do
      Given(:query_result) { [] }

      When(:returned_value) { runner.call(parameters) }

      Then { expect(returned_value).to eq(query_result) }
      And {
        query_parameter_builder.should have_received(:call).with(parameters)
      }
      And {
        query_service.should(
          have_received(:call).
          with(built_parameters)
        )
      }
      And { context.should have_received(:invoked).with("NOT FOUND")}
    end

  end
end
