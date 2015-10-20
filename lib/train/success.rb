module Train
  class Success < ::Train::Result

    def on_success(proc = nil, &block)
      (proc || block).call
    end
    alias_method :>>, :on_success

    def on_failure(_ = nil)
      self
    end
    alias_method :>>, :on_failure

  end
end