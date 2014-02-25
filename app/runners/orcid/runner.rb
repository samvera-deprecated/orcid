require_dependency './lib/orcid/named_callbacks'
module Orcid
  class Runner
    def initialize
      @callbacks = NamedCallbacks.new
      yield(@callbacks) if block_given?
    end

    def callback(name, *args)
      @callbacks.call(name, *args)
      args
    end

  end
end
