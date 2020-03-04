# frozen_string_literal: true

require 'tron/version'

require 'tron/resultable' # Legacy
require 'tron/success' # Legacy
require 'tron/failure' # Legacy

module Tron
  def self.success(code, attributes = {}) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    code.respond_to?(:to_sym) ||
      raise(ArgumentError, 'Tron.success must be called with a Symbol as first argument')

    attributes.respond_to?(:keys) ||
      raise(ArgumentError, 'The second argument (metadata) for Tron.success must respond to #keys')

    attributes.respond_to?(:values) ||
      raise(ArgumentError, 'The second argument (metadata) for Tron.success must respond to #values')

    Struct.new(:success, *attributes.keys) do
      undef_method :[]=
      members.each { |member| undef_method :"#{member}=" }

      def success?
        true
      end

      def failure?
        false
      end

      def failure
        nil
      end

      def code
        warn 'DEPRECATION WARNING: Calling `#code` on a Tron object is deprecated and will be removed in Tron 2.0.0. ' \
             "Please use `#success` instead. Called from `#{caller.first}`"

        success
      end

      def on_success(proc = nil, &block)
        (proc || block).call self
      end

      def on_failure(_ = nil)
        self
      end
    end.new code.to_sym, *attributes.values.map(&:freeze)
  end

  def self.failure(code, attributes = {}) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    code.respond_to?(:to_sym) ||
      raise(ArgumentError, 'Tron.failure must be called with a Symbol as first argument')

    attributes.respond_to?(:keys) ||
      raise(ArgumentError, 'The second argument (metadata) for Tron.failure must respond to #keys')

    attributes.respond_to?(:values) ||
      raise(ArgumentError, 'The second argument (metadata) for Tron.failure must respond to #values')

    Struct.new(:failure, *attributes.keys) do
      undef_method :[]=
      members.each { |member| undef_method :"#{member}=" }

      def success?
        false
      end

      def failure?
        true
      end

      def success
        nil
      end

      def code
        warn 'DEPRECATION WARNING: Calling `#code` on a Tron object is deprecated and will be removed in Tron 2.0.0. ' \
             "Please use `#failure` instead. Called from `#{caller.first}`"

        failure
      end

      def on_success(_ = nil)
        self
      end

      def on_failure(proc = nil, &block)
        (proc || block).call self
      end
    end.new code.to_sym, *attributes.values.map(&:freeze)
  end
end
