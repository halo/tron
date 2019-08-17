require 'tron/version'

require 'tron/resultable' # Legady
require 'tron/success' # Legacy
require 'tron/failure' # Legacy

module Tron
  def self.success(code, attributes = {}) # rubocop:disable Metrics/MethodLength
    Struct.new(:success, *attributes.keys) do
      undef_method '[]='.to_sym
      members.each { |member| undef_method "#{member}=".to_sym }

      def success?
        true
      end

      def failure?
        false
      end

      def on_success(proc = nil, &block)
        (proc || block).call
      end

      def on_failure(_ = nil)
        self
      end
    end.new code.freeze, *attributes.values.map(&:freeze)
  end

  def self.failure(code, attributes = {}) # rubocop:disable Metrics/MethodLength
    Struct.new(:failure, *attributes.keys) do
      undef_method '[]='.to_sym
      members.each { |member| undef_method "#{member}=".to_sym }

      def success?
        false
      end

      def failure?
        true
      end

      def on_success(_ = nil)
        self
      end

      def on_failure(proc = nil, &block)
        (proc || block).call
      end
    end.new code.freeze, *attributes.values.map(&:freeze)
  end
end
