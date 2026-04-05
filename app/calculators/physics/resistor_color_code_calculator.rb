module Physics
  class ResistorColorCodeCalculator
    attr_reader :errors

    # Standard resistor color code values
    COLOR_VALUES = {
      "black"  => 0,
      "brown"  => 1,
      "red"    => 2,
      "orange" => 3,
      "yellow" => 4,
      "green"  => 5,
      "blue"   => 6,
      "violet" => 7,
      "gray"   => 8,
      "white"  => 9
    }.freeze

    MULTIPLIER_VALUES = {
      "black"  => 1,
      "brown"  => 10,
      "red"    => 100,
      "orange" => 1_000,
      "yellow" => 10_000,
      "green"  => 100_000,
      "blue"   => 1_000_000,
      "violet" => 10_000_000,
      "gray"   => 100_000_000,
      "white"  => 1_000_000_000,
      "gold"   => 0.1,
      "silver" => 0.01
    }.freeze

    TOLERANCE_VALUES = {
      "brown"  => 1.0,
      "red"    => 2.0,
      "green"  => 0.5,
      "blue"   => 0.25,
      "violet" => 0.1,
      "gray"   => 0.05,
      "gold"   => 5.0,
      "silver" => 10.0,
      "none"   => 20.0
    }.freeze

    VALID_DIGIT_COLORS = COLOR_VALUES.keys.freeze
    VALID_MULTIPLIER_COLORS = MULTIPLIER_VALUES.keys.freeze
    VALID_TOLERANCE_COLORS = TOLERANCE_VALUES.keys.freeze

    def initialize(bands:, band1:, band2:, band3: nil, multiplier:, tolerance:)
      @bands = bands.to_i
      @band1 = band1.to_s.downcase.strip
      @band2 = band2.to_s.downcase.strip
      @band3 = band3.to_s.downcase.strip if band3.present?
      @multiplier = multiplier.to_s.downcase.strip
      @tolerance = tolerance.to_s.downcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      digit_value = if @bands == 5 && @band3
                      COLOR_VALUES[@band1] * 100 + COLOR_VALUES[@band2] * 10 + COLOR_VALUES[@band3]
      else
                      COLOR_VALUES[@band1] * 10 + COLOR_VALUES[@band2]
      end

      mult = MULTIPLIER_VALUES[@multiplier]
      resistance = digit_value * mult
      tol = TOLERANCE_VALUES[@tolerance]

      min_resistance = resistance * (1 - tol / 100.0)
      max_resistance = resistance * (1 + tol / 100.0)

      {
        valid: true,
        bands: @bands,
        resistance_ohms: resistance,
        resistance_display: format_resistance(resistance),
        tolerance_percent: tol,
        min_resistance_ohms: min_resistance.round(6),
        max_resistance_ohms: max_resistance.round(6),
        min_resistance_display: format_resistance(min_resistance),
        max_resistance_display: format_resistance(max_resistance)
      }
    end

    private

    def validate!
      unless [ 4, 5 ].include?(@bands)
        @errors << "Number of bands must be 4 or 5"
        return
      end

      unless VALID_DIGIT_COLORS.include?(@band1)
        @errors << "Band 1 color is invalid"
      end

      unless VALID_DIGIT_COLORS.include?(@band2)
        @errors << "Band 2 color is invalid"
      end

      if @bands == 5
        unless @band3 && VALID_DIGIT_COLORS.include?(@band3)
          @errors << "Band 3 color is required for 5-band resistors and must be valid"
        end
      end

      unless VALID_MULTIPLIER_COLORS.include?(@multiplier)
        @errors << "Multiplier color is invalid"
      end

      unless VALID_TOLERANCE_COLORS.include?(@tolerance)
        @errors << "Tolerance color is invalid"
      end
    end

    def format_resistance(value)
      if value >= 1_000_000_000
        "#{(value / 1_000_000_000.0).round(2)} G\u2126"
      elsif value >= 1_000_000
        "#{(value / 1_000_000.0).round(2)} M\u2126"
      elsif value >= 1_000
        "#{(value / 1_000.0).round(2)} k\u2126"
      elsif value >= 1
        "#{value.round(2)} \u2126"
      else
        "#{(value * 1000).round(2)} m\u2126"
      end
    end
  end
end
