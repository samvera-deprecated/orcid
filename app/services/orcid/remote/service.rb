require 'orcid/named_callbacks'
module Orcid::Remote
  class Service
    def initialize
      @callbacks = Orcid::NamedCallbacks.new
      yield(@callbacks) if block_given?
    end

    def call
      raise NotImplementedError.new("Define #{self.class}#call")
    end

    def callback(name, *args)
      @callbacks.call(name, *args)
      args
    end

  end
end
