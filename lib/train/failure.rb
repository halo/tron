module Train
  class Failure < ::Train::Result

    def on_success(proc = nil)
      self
    end
    alias :>> :on_success

    def on_failure(proc = nil, &block)
      (proc || block).call
    end
    alias :>> :on_failure

  end
end
