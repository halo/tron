# frozen_string_literal: true

require 'tron/version'

module Tron
  def self.success(code, attributes = {}) # rubocop:disable Metrics/MethodLength
    code.respond_to?(:to_sym) ||
      raise(ArgumentError, 'Tron.success must be called with a Symbol as first argument')

    attributes.respond_to?(:keys) ||
      raise(ArgumentError, 'The second argument (metadata) for Tron.success must respond to #keys')

    attributes.respond_to?(:values) ||
      raise(ArgumentError,
            'The second argument (metadata) for Tron.success must respond to #values')

    Data.define(:success, *attributes.keys) do
      def success?
        true
      end

      def failure?
        false
      end

      def failure
        nil
      end

      def on_success(proc = nil, &block)
        (proc || block).call self
      end

      def on_failure(_ = nil)
        self
      end
    end.new code.to_sym, *attributes.values
  end

  def self.failure(code, attributes = {}) # rubocop:disable Metrics/MethodLength
    code.respond_to?(:to_sym) ||
      raise(ArgumentError, 'Tron.failure must be called with a Symbol as first argument')

    attributes.respond_to?(:keys) ||
      raise(ArgumentError, 'The second argument (metadata) for Tron.failure must respond to #keys')

    attributes.respond_to?(:values) ||
      raise(ArgumentError,
            'The second argument (metadata) for Tron.failure must respond to #values')

    Data.define(:failure, *attributes.keys) do
      def success?
        false
      end

      def failure?
        true
      end

      def success
        nil
      end

      def on_success(_ = nil)
        self
      end

      def on_failure(proc = nil, &block)
        (proc || block).call self
      end
    end.new code.to_sym, *attributes.values
  end
end
