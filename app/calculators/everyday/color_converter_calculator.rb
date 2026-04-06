# frozen_string_literal: true

module Everyday
  class ColorConverterCalculator
    attr_reader :errors

    NAMED_COLORS = {
      "000000" => "Black", "ffffff" => "White", "ff0000" => "Red",
      "00ff00" => "Lime", "0000ff" => "Blue", "ffff00" => "Yellow",
      "00ffff" => "Cyan", "ff00ff" => "Magenta", "c0c0c0" => "Silver",
      "808080" => "Gray", "800000" => "Maroon", "808000" => "Olive",
      "008000" => "Green", "800080" => "Purple", "008080" => "Teal",
      "000080" => "Navy", "ffa500" => "Orange", "ffc0cb" => "Pink",
      "a52a2a" => "Brown", "f5f5dc" => "Beige", "ff7f50" => "Coral",
      "ffd700" => "Gold", "4b0082" => "Indigo", "fffff0" => "Ivory",
      "e6e6fa" => "Lavender", "fa8072" => "Salmon", "d2b48c" => "Tan",
      "ee82ee" => "Violet", "f5f5f5" => "WhiteSmoke", "ff6347" => "Tomato",
      "40e0d0" => "Turquoise", "da70d6" => "Orchid", "dda0dd" => "Plum",
      "b0e0e6" => "PowderBlue", "f0e68c" => "Khaki", "e0ffff" => "LightCyan"
    }.freeze

    def initialize(color:, format: :auto)
      @color = color.to_s.strip
      @format = format.to_sym
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      r, g, b = parse_to_rgb
      return { valid: false, errors: @errors } if @errors.any?

      h, s, l = rgb_to_hsl(r, g, b)
      hex = rgb_to_hex(r, g, b)
      luminance = relative_luminance(r, g, b)
      contrast_white = contrast_ratio(luminance, 1.0)
      contrast_black = contrast_ratio(luminance, 0.0)

      {
        valid: true,
        hex: "##{hex}",
        rgb: { r: r, g: g, b: b },
        rgb_string: "rgb(#{r}, #{g}, #{b})",
        hsl: { h: h, s: s, l: l },
        hsl_string: "hsl(#{h}, #{s}%, #{l}%)",
        color_name: NAMED_COLORS[hex.downcase] || "Custom",
        luminance: luminance.round(4),
        contrast_white: contrast_white.round(2),
        contrast_black: contrast_black.round(2),
        wcag_white: wcag_rating(contrast_white),
        wcag_black: wcag_rating(contrast_black),
        best_text_color: contrast_white >= contrast_black ? "#FFFFFF" : "#000000"
      }
    end

    private

    def validate!
      @errors << "Color value cannot be empty" if @color.empty?
    end

    def parse_to_rgb
      detected = detect_format
      case detected
      when :hex
        parse_hex
      when :rgb
        parse_rgb
      when :hsl
        parse_hsl
      else
        @errors << "Unrecognized color format. Use HEX (#RGB or #RRGGBB), RGB (r, g, b), or HSL (h, s%, l%)"
        [0, 0, 0]
      end
    end

    def detect_format
      return @format unless @format == :auto

      if @color.match?(/\A#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})\z/)
        :hex
      elsif @color.match?(/\Argb/i) || @color.match?(/\A\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}\z/)
        :rgb
      elsif @color.match?(/\Ahsl/i) || @color.match?(/\A\d{1,3}\s*,\s*\d{1,3}%?\s*,\s*\d{1,3}%?\z/)
        :hsl
      else
        :unknown
      end
    end

    def parse_hex
      hex = @color.delete("#")
      hex = hex.chars.map { |c| c * 2 }.join if hex.length == 3

      unless hex.match?(/\A[0-9a-fA-F]{6}\z/)
        @errors << "Invalid HEX color format"
        return [0, 0, 0]
      end

      [hex[0..1].to_i(16), hex[2..3].to_i(16), hex[4..5].to_i(16)]
    end

    def parse_rgb
      values = @color.scan(/\d+/).map(&:to_i)
      unless values.length == 3 && values.all? { |v| v >= 0 && v <= 255 }
        @errors << "RGB values must be three integers between 0 and 255"
        return [0, 0, 0]
      end

      values
    end

    def parse_hsl
      values = @color.scan(/[\d.]+/).map(&:to_f)
      unless values.length == 3
        @errors << "HSL values must include hue (0-360), saturation (0-100), and lightness (0-100)"
        return [0, 0, 0]
      end

      h = values[0]
      s = values[1]
      l = values[2]

      unless h >= 0 && h <= 360 && s >= 0 && s <= 100 && l >= 0 && l <= 100
        @errors << "HSL values out of range: hue 0-360, saturation 0-100, lightness 0-100"
        return [0, 0, 0]
      end

      hsl_to_rgb(h, s, l)
    end

    def rgb_to_hex(r, g, b)
      format("%02x%02x%02x", r, g, b)
    end

    def rgb_to_hsl(r, g, b)
      r_norm = r / 255.0
      g_norm = g / 255.0
      b_norm = b / 255.0

      max = [r_norm, g_norm, b_norm].max
      min = [r_norm, g_norm, b_norm].min
      delta = max - min

      l = (max + min) / 2.0

      if delta == 0
        h = 0.0
        s = 0.0
      else
        s = if l < 0.5
          delta / (max + min)
        else
          delta / (2.0 - max - min)
        end

        h = case max
        when r_norm
          ((g_norm - b_norm) / delta) % 6
        when g_norm
          ((b_norm - r_norm) / delta) + 2
        when b_norm
          ((r_norm - g_norm) / delta) + 4
        end

        h *= 60
        h += 360 if h < 0
      end

      [h.round, (s * 100).round, (l * 100).round]
    end

    def hsl_to_rgb(h, s, l)
      s_norm = s / 100.0
      l_norm = l / 100.0

      c = (1 - (2 * l_norm - 1).abs) * s_norm
      x = c * (1 - ((h / 60.0) % 2 - 1).abs)
      m = l_norm - c / 2.0

      r1, g1, b1 = case h
      when 0...60   then [c, x, 0]
      when 60...120 then [x, c, 0]
      when 120...180 then [0, c, x]
      when 180...240 then [0, x, c]
      when 240...300 then [x, 0, c]
      else [c, 0, x]
      end

      [((r1 + m) * 255).round, ((g1 + m) * 255).round, ((b1 + m) * 255).round]
    end

    def relative_luminance(r, g, b)
      rs = linearize(r / 255.0)
      gs = linearize(g / 255.0)
      bs = linearize(b / 255.0)

      0.2126 * rs + 0.7152 * gs + 0.0722 * bs
    end

    def linearize(value)
      if value <= 0.03928
        value / 12.92
      else
        ((value + 0.055) / 1.055)**2.4
      end
    end

    def contrast_ratio(lum1, lum2)
      lighter = [lum1, lum2].max
      darker = [lum1, lum2].min
      (lighter + 0.05) / (darker + 0.05)
    end

    def wcag_rating(ratio)
      {
        ratio: ratio.round(2),
        aa_normal: ratio >= 4.5,
        aa_large: ratio >= 3.0,
        aaa_normal: ratio >= 7.0,
        aaa_large: ratio >= 4.5
      }
    end
  end
end
