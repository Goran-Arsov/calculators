# frozen_string_literal: true

module Everyday
  class DnsLookupCalculator
    attr_reader :errors

    VALID_RECORD_TYPES = %w[A AAAA MX TXT CNAME NS SOA].freeze

    def initialize(domain:)
      @domain = domain.to_s.strip.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      {
        valid: true,
        domain: @domain,
        is_valid_format: true
      }
    end

    private

    def validate!
      if @domain.empty?
        @errors << "Domain name cannot be empty"
        return
      end

      unless @domain.match?(/\A([a-z0-9]([a-z0-9\-]{0,61}[a-z0-9])?\.)+[a-z]{2,}\z/)
        @errors << "Domain must be a valid format (e.g. example.com)"
      end
    end
  end
end
