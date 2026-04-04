module Physics
  class UnitConverter
    attr_reader :errors

    CONVERSIONS = {
      # Length
      "m_to_ft"   => { from: "Meters", to: "Feet", factor: 3.28084 },
      "ft_to_m"   => { from: "Feet", to: "Meters", factor: 0.3048 },
      "km_to_mi"  => { from: "Kilometers", to: "Miles", factor: 0.621371 },
      "mi_to_km"  => { from: "Miles", to: "Kilometers", factor: 1.60934 },
      "in_to_cm"  => { from: "Inches", to: "Centimeters", factor: 2.54 },
      "cm_to_in"  => { from: "Centimeters", to: "Inches", factor: 0.393701 },
      "m_to_yd"   => { from: "Meters", to: "Yards", factor: 1.09361 },
      "yd_to_m"   => { from: "Yards", to: "Meters", factor: 0.9144 },
      # Weight
      "kg_to_lb"  => { from: "Kilograms", to: "Pounds", factor: 2.20462 },
      "lb_to_kg"  => { from: "Pounds", to: "Kilograms", factor: 0.453592 },
      "g_to_oz"   => { from: "Grams", to: "Ounces", factor: 0.035274 },
      "oz_to_g"   => { from: "Ounces", to: "Grams", factor: 28.3495 },
      # Speed
      "kmh_to_mph" => { from: "km/h", to: "mph", factor: 0.621371 },
      "mph_to_kmh" => { from: "mph", to: "km/h", factor: 1.60934 },
      "ms_to_kmh"  => { from: "m/s", to: "km/h", factor: 3.6 },
      "kmh_to_ms"  => { from: "km/h", to: "m/s", factor: 0.277778 },
      "knot_to_kmh" => { from: "Knots", to: "km/h", factor: 1.852 },
      "kmh_to_knot" => { from: "km/h", to: "Knots", factor: 0.539957 },
      # Volume
      "l_to_gal"  => { from: "Liters", to: "Gallons (US)", factor: 0.264172 },
      "gal_to_l"  => { from: "Gallons (US)", to: "Liters", factor: 3.78541 },
      "ml_to_floz" => { from: "Milliliters", to: "Fluid Ounces (US)", factor: 0.033814 },
      "floz_to_ml" => { from: "Fluid Ounces (US)", to: "Milliliters", factor: 29.5735 },
      # Area
      "sqm_to_sqft" => { from: "m²", to: "ft²", factor: 10.7639 },
      "sqft_to_sqm" => { from: "ft²", to: "m²", factor: 0.092903 },
      "ha_to_acre"  => { from: "Hectares", to: "Acres", factor: 2.47105 },
      "acre_to_ha"  => { from: "Acres", to: "Hectares", factor: 0.404686 },
      # Temperature (special handling)
      "c_to_f" => { from: "°C", to: "°F", type: :temperature },
      "f_to_c" => { from: "°F", to: "°C", type: :temperature },
      "c_to_k" => { from: "°C", to: "K", type: :temperature },
      "k_to_c" => { from: "K", to: "°C", type: :temperature }
    }.freeze

    def initialize(conversion:, value:)
      @conversion = conversion.to_s
      @value = value.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      conv = CONVERSIONS[@conversion]
      result = convert(@value, @conversion)

      {
        valid: true,
        from_unit: conv[:from],
        to_unit: conv[:to],
        input: @value,
        result: result.round(6)
      }
    end

    private

    def validate!
      unless CONVERSIONS.key?(@conversion)
        @errors << "Unknown conversion: #{@conversion}"
      end
    end

    def convert(val, key)
      conv = CONVERSIONS[key]
      if conv[:type] == :temperature
        case key
        when "c_to_f" then val * 9.0 / 5.0 + 32
        when "f_to_c" then (val - 32) * 5.0 / 9.0
        when "c_to_k" then val + 273.15
        when "k_to_c" then val - 273.15
        end
      else
        val * conv[:factor]
      end
    end
  end
end
