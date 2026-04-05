module Physics
  class HeatTransferCalculator
    attr_reader :errors

    # Thermal conductivity values in W/(m*K)
    MATERIALS = {
      "copper"          => { name: "Copper",              k: 401.0 },
      "aluminum"        => { name: "Aluminum",            k: 237.0 },
      "steel"           => { name: "Steel (carbon)",      k: 50.2 },
      "stainless_steel" => { name: "Stainless Steel",     k: 16.2 },
      "iron"            => { name: "Iron",                k: 80.2 },
      "brass"           => { name: "Brass",               k: 109.0 },
      "gold"            => { name: "Gold",                k: 317.0 },
      "silver"          => { name: "Silver",              k: 429.0 },
      "glass"           => { name: "Glass",               k: 1.05 },
      "concrete"        => { name: "Concrete",            k: 1.7 },
      "brick"           => { name: "Brick",               k: 0.72 },
      "wood_oak"        => { name: "Wood (Oak)",          k: 0.17 },
      "wood_pine"       => { name: "Wood (Pine)",         k: 0.12 },
      "fiberglass"      => { name: "Fiberglass",          k: 0.04 },
      "styrofoam"       => { name: "Styrofoam",           k: 0.033 },
      "air"             => { name: "Air (at 25\u00B0C)",  k: 0.026 },
      "water"           => { name: "Water (at 25\u00B0C)", k: 0.607 },
      "custom"          => { name: "Custom",              k: nil }
    }.freeze

    VALID_MATERIALS = MATERIALS.keys.freeze

    WATTS_TO_BTU_HR = 3.41214

    def initialize(material:, area:, thickness:, temp_difference:, custom_k: nil)
      @material = material.to_s.downcase.strip
      @area = area.to_f
      @thickness = thickness.to_f
      @temp_difference = temp_difference.to_f
      @custom_k = custom_k.present? ? custom_k.to_f : nil
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      k = if @material == "custom"
            @custom_k
          else
            MATERIALS[@material][:k]
          end

      # Fourier's Law of heat conduction: Q = k * A * dT / d
      # Q = heat transfer rate (W)
      # k = thermal conductivity (W/(m*K))
      # A = area (m^2)
      # dT = temperature difference (K or C)
      # d = thickness (m)
      heat_transfer_rate = k * @area * @temp_difference / @thickness

      # Thermal resistance R = d / (k * A) in K/W
      thermal_resistance = @thickness / (k * @area)

      # Heat flux q = Q / A in W/m^2
      heat_flux = heat_transfer_rate / @area

      {
        valid: true,
        material: @material,
        material_name: @material == "custom" ? "Custom" : MATERIALS[@material][:name],
        thermal_conductivity: k.round(4),
        area_m2: @area.round(4),
        thickness_m: @thickness.round(4),
        temp_difference_k: @temp_difference.round(2),
        heat_transfer_rate_w: heat_transfer_rate.round(4),
        heat_transfer_rate_btu_hr: (heat_transfer_rate * WATTS_TO_BTU_HR).round(4),
        thermal_resistance_kw: thermal_resistance.round(6),
        heat_flux_w_m2: heat_flux.round(4)
      }
    end

    private

    def validate!
      unless VALID_MATERIALS.include?(@material)
        @errors << "Unknown material: #{@material}"
      end

      if @material == "custom" && (@custom_k.nil? || @custom_k <= 0)
        @errors << "Custom thermal conductivity must be a positive number"
      end

      if @area <= 0
        @errors << "Area must be a positive number"
      end

      if @thickness <= 0
        @errors << "Thickness must be a positive number"
      end

      if @temp_difference == 0
        @errors << "Temperature difference must be non-zero"
      end
    end
  end
end
