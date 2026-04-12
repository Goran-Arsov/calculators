# frozen_string_literal: true

module Photography
  class PrintSizeDpiCalculator
    attr_reader :errors

    # Common DPI standards
    DPI_WEB = 72
    DPI_STANDARD_PRINT = 300
    DPI_HIGH_QUALITY = 600

    def initialize(mode: "pixels_to_print", pixel_width: nil, pixel_height: nil,
                   dpi: nil, print_width: nil, print_height: nil, unit: "inches")
      @mode = mode.to_s
      @pixel_width = pixel_width&.to_f
      @pixel_height = pixel_height&.to_f
      @dpi = dpi&.to_f
      @print_width = print_width&.to_f
      @print_height = print_height&.to_f
      @unit = unit.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @mode
      when "pixels_to_print"
        calculate_print_size
      when "print_to_pixels"
        calculate_pixel_requirements
      when "find_dpi"
        calculate_dpi
      else
        { valid: false, errors: [ "Unknown mode: #{@mode}" ] }
      end
    end

    private

    def calculate_print_size
      width_inches = @pixel_width / @dpi
      height_inches = @pixel_height / @dpi

      {
        valid: true,
        print_width_inches: width_inches.round(2),
        print_height_inches: height_inches.round(2),
        print_width_cm: (width_inches * 2.54).round(2),
        print_height_cm: (height_inches * 2.54).round(2),
        total_megapixels: ((@pixel_width * @pixel_height) / 1_000_000.0).round(1),
        quality: print_quality_label(@dpi)
      }
    end

    def calculate_pixel_requirements
      print_w = @unit == "cm" ? @print_width / 2.54 : @print_width
      print_h = @unit == "cm" ? @print_height / 2.54 : @print_height

      pixels_w = (print_w * @dpi).ceil
      pixels_h = (print_h * @dpi).ceil

      {
        valid: true,
        required_pixel_width: pixels_w,
        required_pixel_height: pixels_h,
        total_megapixels: ((pixels_w * pixels_h) / 1_000_000.0).round(1),
        quality: print_quality_label(@dpi)
      }
    end

    def calculate_dpi
      print_w = @unit == "cm" ? @print_width / 2.54 : @print_width
      print_h = @unit == "cm" ? @print_height / 2.54 : @print_height

      dpi_w = @pixel_width / print_w
      dpi_h = @pixel_height / print_h
      effective_dpi = [ dpi_w, dpi_h ].min

      {
        valid: true,
        dpi_width: dpi_w.round(0).to_i,
        dpi_height: dpi_h.round(0).to_i,
        effective_dpi: effective_dpi.round(0).to_i,
        quality: print_quality_label(effective_dpi)
      }
    end

    def print_quality_label(dpi)
      if dpi >= 300
        "Excellent"
      elsif dpi >= 200
        "Good"
      elsif dpi >= 150
        "Acceptable"
      else
        "Low — may appear pixelated"
      end
    end

    def validate!
      case @mode
      when "pixels_to_print"
        @errors << "Pixel width must be positive" unless @pixel_width&.positive?
        @errors << "Pixel height must be positive" unless @pixel_height&.positive?
        @errors << "DPI must be positive" unless @dpi&.positive?
      when "print_to_pixels"
        @errors << "Print width must be positive" unless @print_width&.positive?
        @errors << "Print height must be positive" unless @print_height&.positive?
        @errors << "DPI must be positive" unless @dpi&.positive?
      when "find_dpi"
        @errors << "Pixel width must be positive" unless @pixel_width&.positive?
        @errors << "Pixel height must be positive" unless @pixel_height&.positive?
        @errors << "Print width must be positive" unless @print_width&.positive?
        @errors << "Print height must be positive" unless @print_height&.positive?
      end
    end
  end
end
