module Tron
  module Resultable
    attr_reader :metadata

    def self.included(receiver)
      receiver.extend ::Tron::Resultable::ClassMethods
    end

    module ClassMethods
      # Convenience wrapper
      def call(code, metadata = nil)
        new code: code, metadata: metadata
      end
    end

    def initialize(code: nil, metadata: nil)
      @code     = code
      @metadata = metadata
      warn 'DEPRECATED: As of Tron 1.0.0 calls to `Tron::Success` and `Tron::Failure.call` are deprecated. ' \
           'They will be removed in Tron 2.0.0. Please migrate using `Tron.success` and `Tron.failure`. ' \
           'See github.com/halo/tron'
    end

    def success?
      is_a? ::Tron::Success
    end

    def failure?
      is_a? ::Tron::Failure
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
