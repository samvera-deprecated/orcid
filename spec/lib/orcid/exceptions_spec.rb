require 'fast_helper'
require 'orcid/exceptions'

module Orcid
  describe BaseError do
    it { should be_a_kind_of RuntimeError }
  end

  describe ProfileRequestStateError do
    subject { described_class }
    its(:superclass) { should be BaseError }
  end

  describe MissingUserForProfileRequest do
    subject { described_class }
    its(:superclass) { should be BaseError }
  end

  describe ConfigurationError do
    subject { described_class }
    its(:superclass) { should be BaseError }
  end

  describe RemoteServiceError do
    subject { described_class }
    its(:superclass) { should be BaseError }
  end

  describe ProfileRequestMethodExpectedError do
    subject { described_class }
    its(:superclass) { should be BaseError }
  end
end