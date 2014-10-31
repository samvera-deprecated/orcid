require 'spec_helper'

describe Orcid::ApplicationController, type: :controller do
  context '#path_for' do
    it 'yields when the provided symbol is not a method' do
      path_for = controller.path_for(:__obviously_missing_method__, '123') { |arg| "/abc/#{arg}" }
      expect(path_for).to eq('/abc/123')
    end

    it 'calls the named method' do
      path_for = controller.path_for(:to_s) { "/abc/#{arg}" }
      expect(path_for).to eq(controller.to_s)
    end
  end
end
