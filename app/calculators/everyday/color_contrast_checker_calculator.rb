# frozen_string_literal: true

module Everyday
  class ColorContrastCheckerCalculator
    attr_reader :errors

    # WCAG 2.1 thresholds
    AA_NORMAL_RATIO = 4.5
    AA_LARGE_RATIO = 3.0
    AAA_NORMAL_RATIO = 7.0
    AAA_LARGE_RATIO = 4.5

    def initialize(foreground:, background:)
      @foreground = foreground.to_s.strip
      @background = background.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      fg_rgb = parse_hex(@foreground)
      bg_rgb = parse_hex(@background)

      fg_luminance = relative_luminance(fg_rgb)
      bg_luminance = relative_luminance(bg_rgb)

      ratio = contrast_ratio(fg_luminance, bg_luminance)

      {
        valid: true,
        foreground: normalize_hex(@foreground),
        background: normalize_hex(@background),
        contrast_ratio: ratio,
        contrast_ratio_display: "#{ratio}:1",
        aa_normal: ratio >= AA_NORMAL_RATIO,
        aa_large: ratio >= AA_LARGE_RATIO,
        aaa_normal: ratio >= AAA_NORMAL_RATIO,
        aaa_large: ratio >= AAA_LARGE_RATIO,
        fg_luminance: fg_luminance.round(5),
        bg_luminance: bg_luminance.round(5)
      }
    end

    private

    def validate!
      @errors << "Foreground color is required" if @foreground.empty?
      @errors << "Background color is required" if @background.empty?

      if @foreground.present? && !valid_hex?(@foreground)
        @errors << "Foreground must be a valid hex color (e.g., #FF0000 or #F00)"
      end

      if @background.present? && !valid_hex?(@background)
        @errors << "Background must be a valid hex color (e.g., #FFFFFF or #FFF)"
      end
    end

    def valid_hex?(color)
      clean = color.sub(/\A#/, "")
      clean.match?(/\A[0-9A-Fa-f]{3}\z/) || clean.match?(/\A[0-9A-Fa-f]{6}\z/)
    end

    def normalize_hex(color)
      clean = color.sub(/\A#/, "")
      if clean.length == 3
        clean = clean.chars.map { |c| c * 2 }.join
      end
      "##{clean.upcase}"
    end

    def parse_hex(color)
      clean = color.sub(/\A#/, "")
      if clean.length == 3
        clean = clean.chars.map { |c| c * 2 }.join
      end

      r = clean[0..1].to_i(16)
      g = clean[2..3].to_i(16)
      b = clean[4..5].to_i(16)

      [ r, g, b ]
    end

    # WCAG 2.1 relative luminance formula
    # L = 0.2126 * R + 0.7152 * G + 0.0722 * B
    # where R, G, B are linearized sRGB values
    def relative_luminance(rgb)
      r, g, b = rgb.map { |c| linearize(c / 255.0) }
      0.2126 * r + 0.7152 * g + 0.0722 * b
    end

    def linearize(value)
      if value <= 0.04045
        value / 12.92
      else
        ((value + 0.055) / 1.055)**2.4
      end
    end

    # Contrast ratio = (L1 + 0.05) / (L2 + 0.05)
    # where L1 is the lighter luminance
    def contrast_ratio(l1, l2)
      lighter = [ l1, l2 ].max
      darker = [ l1, l2 ].min
      ((lighter + 0.05) / (darker + 0.05)).round(2)
    end
  end
end
