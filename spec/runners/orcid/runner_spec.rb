require 'fast_helper'
require 'app/runners/orcid/runner'

module Orcid
  describe Runner do
    Given(:context) { double(invoked: true) }
    Given(:runner) {
      described_class.new { |on|
        on.found {|a,b| context.invoked("FOUND", a,b) }
      }
    }

    describe "calling defined callback" do
      When(:result) { runner.callback(:found, :first, :second) }
      Then { context.should have_received(:invoked).with("FOUND", :first, :second) }
      Then { result == [:first, :second] }
    end

    describe "calling undefined callback" do
      When(:result) { runner.callback(:missing, :first, :second) }
      Then { context.should_not have_received(:invoked) }
      Then { result == [:first, :second] }
    end

  end
end
