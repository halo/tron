module Tron
  class Success
    include Resultable

    def on_success(proc = nil, &block)
      (proc || block).call
    end

    def on_failure(_ = nil)
      self
    end
  end
end
