module Tron
  class Failure
    include Resultable

    def on_success(_ = nil)
      self
    end

    def on_failure(proc = nil, &block)
      (proc || block).call
    end
  end
end
