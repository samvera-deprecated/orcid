require 'orcid/named_callbacks'
module Orcid
  module Remote
    # An abstract service class, responsible for making remote calls and
    # issuing a callback.
    class Service
      def initialize
        @callbacks = Orcid::NamedCallbacks.new
        yield(@callbacks) if block_given?
      end

      def call
        fail NotImplementedError, ("Define #{self.class}#call")
      end

      def callback(name, *args)
        @callbacks.call(name, *args)
        args
      end
    end
  end
end
