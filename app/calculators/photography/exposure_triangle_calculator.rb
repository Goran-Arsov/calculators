# frozen_string_literal: true

module Photography
  class ExposureTriangleCalculator
    attr_reader :errors

    # Standard full-stop shutter speeds (seconds)
    SHUTTER_STOPS = [
      1 / 8000.0, 1 / 4000.0, 1 / 2000.0, 1 / 1000.0, 1 / 500.0,
      1 / 250.0, 1 / 125.0, 1 / 60.0, 1 / 30.0, 1 / 15.0,
      1 / 8.0, 1 / 4.0, 1 / 2.0, 1.0, 2.0, 4.0, 8.0, 15.0, 30.0
    ].freeze

    # Standard full-stop apertures
    APERTURE_STOPS = [
      1.0, 1.4, 2.0, 2.8, 4.0, 5.6, 8.0, 11.0, 16.0, 22.0, 32.0, 45.0, 64.0
    ].freeze

    # Standard ISO values
    ISO_STOPS = [
      25, 50, 100, 200, 400, 800, 1600, 3200, 6400, 12_800, 25_600, 51_200, 102_400
    ].freeze

    def initialize(current_iso:, current_aperture:, current_shutter:,
                   new_iso: nil, new_aperture: nil, new_shutter: nil)
      @current_iso = current_iso.to_f
      @current_aperture = current_aperture.to_f
      @current_shutter = current_shutter.to_f
      @new_iso = new_iso&.to_f
      @new_aperture = new_aperture&.to_f
      @new_shutter = new_shutter&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # For equivalent exposure: N^2 / (t * ISO) = constant
      # EV at ISO 100: EV = log2(N^2 / t)
      current_ev = Math.log2(@current_aperture**2 / @current_shutter)
      exposure_constant = @current_aperture**2 / (@current_shutter * @current_iso)

      result = if @new_iso && @new_aperture
                 solve_for_shutter(exposure_constant, @new_iso, @new_aperture)
               elsif @new_iso && @new_shutter
                 solve_for_aperture(exposure_constant, @new_iso, @new_shutter)
               elsif @new_aperture && @new_shutter
                 solve_for_iso(exposure_constant, @new_aperture, @new_shutter)
               else
                 { valid: false, errors: ["Provide exactly two of the three new values (ISO, aperture, shutter)"] }
               end

      result.merge!(current_ev: current_ev.round(2)) if result[:valid]
      result
    end

    private

    def solve_for_shutter(k, iso, aperture)
      # k = N^2 / (t * ISO) => t = N^2 / (k * ISO)
      shutter = aperture**2 / (k * iso)

      {
        valid: true,
        new_iso: iso.round(0).to_i,
        new_aperture: aperture.round(1),
        new_shutter: shutter,
        new_shutter_display: format_shutter(shutter),
        stops_shifted: stops_difference(@current_shutter, shutter, :shutter)
      }
    end

    def solve_for_aperture(k, iso, shutter)
      # k = N^2 / (t * ISO) => N^2 = k * t * ISO
      aperture_sq = k * shutter * iso
      aperture = Math.sqrt(aperture_sq)

      {
        valid: true,
        new_iso: iso.round(0).to_i,
        new_aperture: aperture.round(1),
        new_shutter: shutter,
        new_shutter_display: format_shutter(shutter),
        stops_shifted: stops_difference(@current_aperture, aperture, :aperture)
      }
    end

    def solve_for_iso(k, aperture, shutter)
      # k = N^2 / (t * ISO) => ISO = N^2 / (k * t)
      iso = aperture**2 / (k * shutter)

      {
        valid: true,
        new_iso: iso.round(0).to_i,
        new_aperture: aperture.round(1),
        new_shutter: shutter,
        new_shutter_display: format_shutter(shutter),
        stops_shifted: stops_difference(@current_iso, iso, :iso)
      }
    end

    def format_shutter(seconds)
      if seconds >= 1
        "#{seconds.round(1)}s"
      else
        denominator = (1.0 / seconds).round(0).to_i
        "1/#{denominator}s"
      end
    end

    def stops_difference(old_val, new_val, type)
      case type
      when :shutter
        Math.log2(old_val / new_val).round(1)
      when :aperture
        (2 * Math.log2(new_val / old_val)).round(1)
      when :iso
        Math.log2(new_val / old_val).round(1)
      end
    end

    def validate!
      @errors << "Current ISO must be positive" unless @current_iso > 0
      @errors << "Current aperture must be positive" unless @current_aperture > 0
      @errors << "Current shutter speed must be positive" unless @current_shutter > 0

      new_count = [@new_iso, @new_aperture, @new_shutter].count(&:itself)
      @errors << "Provide exactly two of the three new values" unless new_count == 2
    end
  end
end
