# frozen_string_literal: true

module Everyday
  class OgPreviewCalculator
    attr_reader :errors

    REQUIRED_TAGS = %w[og:title og:description og:url og:type].freeze
    RECOMMENDED_TAGS = %w[og:image og:site_name og:locale twitter:card twitter:title twitter:description twitter:image].freeze

    def initialize(tags: {})
      @tags = normalize_tags(tags)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      missing_required = REQUIRED_TAGS.select { |t| @tags[t].to_s.strip.empty? }
      missing_recommended = RECOMMENDED_TAGS.select { |t| @tags[t].to_s.strip.empty? }

      score = calculate_score(missing_required, missing_recommended)

      {
        valid: true,
        tags: @tags,
        missing_required: missing_required,
        missing_recommended: missing_recommended,
        score: score,
        title_length: @tags["og:title"].to_s.length,
        description_length: @tags["og:description"].to_s.length,
        has_image: !@tags["og:image"].to_s.strip.empty?,
        meta_html: generate_meta_html
      }
    end

    private

    def validate!
      @errors << "At least one Open Graph tag must be provided" if @tags.values.all? { |v| v.to_s.strip.empty? }
    end

    def normalize_tags(tags)
      return {} unless tags.is_a?(Hash)
      tags.transform_keys(&:to_s).transform_values(&:to_s)
    end

    def calculate_score(missing_req, missing_rec)
      total = REQUIRED_TAGS.size + RECOMMENDED_TAGS.size
      filled = total - missing_req.size - missing_rec.size
      ((filled.to_f / total) * 100).round(0)
    end

    def generate_meta_html
      lines = []
      @tags.each do |key, value|
        next if value.strip.empty?
        if key.start_with?("twitter:")
          lines << "<meta name=\"#{key}\" content=\"#{escape_html(value)}\" />"
        else
          lines << "<meta property=\"#{key}\" content=\"#{escape_html(value)}\" />"
        end
      end
      lines.join("\n")
    end

    def escape_html(text)
      text.gsub("&", "&amp;").gsub('"', "&quot;").gsub("<", "&lt;").gsub(">", "&gt;")
    end
  end
end
