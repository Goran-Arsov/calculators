# frozen_string_literal: true

require "base64"

module Everyday
  class Base64ImageEncoderCalculator
    attr_reader :errors

    MIME_SIGNATURES = {
      "iVBOR" => "image/png",
      "/9j/"  => "image/jpeg",
      "R0lGO" => "image/gif",
      "UklGR" => "image/webp",
      "PHN2Z" => "image/svg+xml",
      "PD94b" => "image/svg+xml"
    }.freeze

    def initialize(base64:)
      @base64 = base64.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      clean = strip_data_uri_prefix(@base64)
      format = detect_format(clean)
      estimated_bytes = (clean.length * 3.0 / 4.0).ceil
      mime = format || "application/octet-stream"

      {
        valid: true,
        format: format,
        mime_type: mime,
        estimated_file_size: estimated_bytes,
        estimated_file_size_display: human_file_size(estimated_bytes),
        data_uri_prefix: "data:#{mime};base64,",
        base64_length: clean.length
      }
    end

    private

    def validate!
      @errors << "Base64 string cannot be empty" if @base64.empty?
      return if @base64.empty?

      clean = strip_data_uri_prefix(@base64)
      begin
        Base64.strict_decode64(clean)
      rescue ArgumentError
        @errors << "Invalid Base64 encoding"
      end
    end

    def strip_data_uri_prefix(str)
      if str.match?(%r{\Adata:[^;]+;base64,})
        str.sub(%r{\Adata:[^;]+;base64,}, "")
      else
        str
      end
    end

    def detect_format(base64_str)
      MIME_SIGNATURES.each do |prefix, mime|
        return mime if base64_str.start_with?(prefix)
      end
      nil
    end

    def human_file_size(bytes)
      if bytes < 1024
        "#{bytes} B"
      elsif bytes < 1024 * 1024
        format("%.1f KB", bytes / 1024.0)
      else
        format("%.1f MB", bytes / (1024.0 * 1024.0))
      end
    end
  end
end
