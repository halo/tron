# frozen_string_literal: true

require 'tron/version'

require 'tron/resultable' # Legady
require 'tron/success' # Legacy
require 'tron/failure' # Legacy

module Tron
  def self.success(code, attributes = {}) # rubocop:disable Metrics/MethodLength
    code.respond_to?(:to_sym) ||
      raise(ArgumentError, 'Tron.success must be called with a Symbol as first argument')

    attributes.respond_to?(:keys)||
      raise(ArgumentError, 'The attributes Hash for Tron.success must respond to #keys')

    attributes.respond_to?(:values) ||
      raise(ArgumentError, 'The attributes Hash for Tron.success must respond to #values')

    Struct.new(:success, *attributes.keys) do
      undef_method '[]='.to_sym
      members.each { |member| undef_method "#{member}=".to_sym }

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
        (proc || block).call
      end

      def on_failure(_ = nil)
        self
      end
    end.new code.to_sym, *attributes.values.map(&:freeze)
  end

  def self.failure(code, attributes = {}) # rubocop:disable Metrics/MethodLength
    code.respond_to?(:to_sym) ||
      raise(ArgumentError, 'Tron.failure must be called with a Symbol as first argument')

    attributes.respond_to?(:keys)||
      raise(ArgumentError, 'The attributes Hash for Tron.failure must respond to #keys')

    attributes.respond_to?(:values) ||
      raise(ArgumentError, 'The attributes Hash for Tron.failure must respond to #values')

    Struct.new(:failure, *attributes.keys) do
      undef_method '[]='.to_sym
      members.each { |member| undef_method "#{member}=".to_sym }

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
        (proc || block).call
      end
    end.new code.to_sym, *attributes.values.map(&:freeze)
  end
end
