module Physics
  class PressureConverterCalculator
    attr_reader :errors

    # All conversion factors relative to Pascal (Pa)
    UNITS = {
      "pa"    => { name: "Pascal",                  symbol: "Pa",    to_pa: 1.0 },
      "kpa"   => { name: "Kilopascal",              symbol: "kPa",   to_pa: 1_000.0 },
      "mpa"   => { name: "Megapascal",              symbol: "MPa",   to_pa: 1_000_000.0 },
      "bar"   => { name: "Bar",                     symbol: "bar",   to_pa: 100_000.0 },
      "psi"   => { name: "Pounds per square inch",  symbol: "psi",   to_pa: 6_894.757293168 },
      "atm"   => { name: "Atmosphere",              symbol: "atm",   to_pa: 101_325.0 },
      "mmhg"  => { name: "Millimeters of mercury",  symbol: "mmHg",  to_pa: 133.322387415 },
      "torr"  => { name: "Torr",                    symbol: "Torr",  to_pa: 133.322368421 },
      "inhg"  => { name: "Inches of mercury",       symbol: "inHg",  to_pa: 3_386.389 },
      "kgcm2" => { name: "Kilogram-force per cm\u00B2", symbol: "kgf/cm\u00B2", to_pa: 98_066.5 }
    }.freeze

    VALID_UNITS = UNITS.keys.freeze

    def initialize(value:, from_unit:)
      @value = value.to_f
      @from_unit = from_unit.to_s.downcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Convert to Pascal first
      value_in_pa = @value * UNITS[@from_unit][:to_pa]

      conversions = {}
      UNITS.each do |key, unit|
        converted = value_in_pa / unit[:to_pa]
        conversions[key] = {
          value: converted.round(6),
          name: unit[:name],
          symbol: unit[:symbol]
        }
      end

      {
        valid: true,
        input_value: @value,
        from_unit: @from_unit,
        from_unit_name: UNITS[@from_unit][:name],
        from_unit_symbol: UNITS[@from_unit][:symbol],
        value_in_pa: value_in_pa.round(6),
        conversions: conversions
      }
    end

    private

    def validate!
      unless VALID_UNITS.include?(@from_unit)
        @errors << "Unknown pressure unit: #{@from_unit}. Valid units: #{VALID_UNITS.join(', ')}"
      end

      if @value.to_f.nan? || @value.to_f.infinite?
        @errors << "Value must be a valid number"
      end
    end
  end
end
