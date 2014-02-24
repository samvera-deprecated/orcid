module Orcid
  # Inspired by Jim Weirich's NamedCallbacks
  # https://github.com/jimweirich/wyriki/blob/master/spec/runners/named_callbacks_spec.rb#L1-L28
  class NamedCallbacks < BasicObject
    def initialize
      @callbacks = {}
    end

    def method_missing(callback_name, *args, &block)
      @callbacks[callback_name] = block
    end

    def call(callback_name, *args)
      name = callback_name.to_sym
      cb = @callbacks[name]
      cb ? cb.call(*args) : true
    end
  end
end
