module Train
  class Failure
    include Resultable

    def on_success(_ = nil)
      self
    end
    alias_method :>>, :on_success

    def on_failure(proc = nil, &block)
      (proc || block).call
    end
    alias_method :>>, :on_failure

  end
end
