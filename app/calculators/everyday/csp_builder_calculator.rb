# frozen_string_literal: true

module Everyday
  class CspBuilderCalculator
    attr_reader :errors

    VALID_DIRECTIVES = %w[
      default-src script-src style-src img-src font-src connect-src
      frame-src media-src object-src base-uri form-action frame-ancestors
      report-uri
    ].freeze

    VALID_SOURCES = %w[
      'self' 'none' 'unsafe-inline' 'unsafe-eval' 'strict-dynamic'
      'wasm-unsafe-eval' * data: blob: https: http: mediastream:
    ].freeze

    def initialize(directives: {})
      @directives = normalize_directives(directives)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      header_string = build_header
      directive_count = @directives.count { |_, sources| sources.any? }

      {
        valid: true,
        header: header_string,
        directive_count: directive_count,
        directives: @directives
      }
    end

    private

    def normalize_directives(directives)
      normalized = {}
      directives.each do |key, sources|
        directive_name = key.to_s.tr("_", "-")
        next unless VALID_DIRECTIVES.include?(directive_name)

        source_list = case sources
        when Array
          sources.map(&:to_s).map(&:strip).reject(&:empty?)
        when String
          sources.split(/\s+/).map(&:strip).reject(&:empty?)
        else
          []
        end
        normalized[directive_name] = source_list if source_list.any?
      end
      normalized
    end

    def build_header
      @directives.map do |directive, sources|
        "#{directive} #{sources.join(' ')}"
      end.join("; ")
    end

    def validate!
      @errors << "At least one directive must be specified" if @directives.empty? || @directives.values.all?(&:empty?)
    end
  end
end
