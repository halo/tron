module Train
  class Result
    attr_reader :metadata

    def initialize(code = nil, metadata = nil)
      @code     = code
      @metadata = metadata
    end

    def success?
      is_a? ::Train::Success
    end

    def failure?
      is_a? ::Train::Failure
    end

    def code
      return if @code.to_s == ''
      @code.to_s.to_sym
    end

    # Convenience Wrapper
    def object
      metadata[:object] || metadata['object']
    rescue
      nil
    end

    def meta
      if defined? ::Hashie::Mash
        metamash
      else
        metadata
      end
    end

    private

    def metamash
      if metadata.respond_to? :each_pair
        ::Hashie::Mash.new metadata
      elsif metadata
        metadata
      else
        ::Hashie::Mash.new
      end
    end

  end
end
