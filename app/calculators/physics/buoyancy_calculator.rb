module Physics
  class BuoyancyCalculator
    attr_reader :errors

    DEFAULT_GRAVITY = 9.80665

    # Common fluid densities in kg/m^3
    FLUIDS = {
      "water" => { name: "Fresh Water (20\u00B0C)", density: 998.0 },
      "seawater" => { name: "Seawater", density: 1025.0 },
      "mercury" => { name: "Mercury", density: 13534.0 },
      "oil" => { name: "Oil (typical)", density: 900.0 },
      "glycerin" => { name: "Glycerin", density: 1261.0 },
      "ethanol" => { name: "Ethanol", density: 789.0 },
      "gasoline" => { name: "Gasoline", density: 680.0 },
      "air" => { name: "Air (sea level, 20\u00B0C)", density: 1.204 },
      "custom" => { name: "Custom", density: nil }
    }.freeze

    VALID_FLUIDS = FLUIDS.keys.freeze

    def initialize(object_mass:, object_volume:, fluid: "water", custom_fluid_density: nil, gravity: nil)
      @object_mass = object_mass.present? ? object_mass.to_f : nil
      @object_volume = object_volume.present? ? object_volume.to_f : nil
      @fluid = fluid.to_s.downcase.strip
      @custom_fluid_density = custom_fluid_density.present? ? custom_fluid_density.to_f : nil
      @gravity = gravity.present? ? gravity.to_f : DEFAULT_GRAVITY
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      fluid_density = if @fluid == "custom"
                        @custom_fluid_density
                      else
                        FLUIDS[@fluid][:density]
                      end

      # Buoyant force: Fb = rho_fluid * V_object * g
      buoyant_force = fluid_density * @object_volume * @gravity

      # Weight of object: W = m * g
      weight = @object_mass * @gravity

      # Net force (positive = upward/floats, negative = sinks)
      net_force = buoyant_force - weight

      # Object density
      object_density = @object_mass / @object_volume

      # Fraction submerged (if floating): rho_object / rho_fluid
      fraction_submerged = object_density / fluid_density

      # Determine float/sink status
      status = if buoyant_force > weight
                 "Floats"
               elsif buoyant_force < weight
                 "Sinks"
               else
                 "Neutrally buoyant"
               end

      # Apparent weight when submerged
      apparent_weight = weight - buoyant_force
      apparent_weight = 0.0 if apparent_weight < 0 && status == "Floats"

      {
        valid: true,
        object_mass_kg: @object_mass.round(4),
        object_volume_m3: @object_volume.round(6),
        object_density_kg_m3: object_density.round(4),
        fluid: @fluid,
        fluid_name: @fluid == "custom" ? "Custom" : FLUIDS[@fluid][:name],
        fluid_density_kg_m3: fluid_density.round(4),
        gravity_m_s2: @gravity.round(4),
        buoyant_force_n: buoyant_force.round(4),
        weight_n: weight.round(4),
        net_force_n: net_force.round(4),
        apparent_weight_n: apparent_weight.round(4),
        status: status,
        fraction_submerged: [ fraction_submerged, 1.0 ].min.round(4),
        percent_submerged: ([ fraction_submerged, 1.0 ].min * 100).round(2)
      }
    end

    private

    def validate!
      unless VALID_FLUIDS.include?(@fluid)
        @errors << "Unknown fluid: #{@fluid}"
      end

      if @fluid == "custom" && (@custom_fluid_density.nil? || @custom_fluid_density <= 0)
        @errors << "Custom fluid density must be a positive number"
      end

      if @object_mass.nil?
        @errors << "Object mass is required"
      elsif @object_mass <= 0
        @errors << "Object mass must be a positive number"
      end

      if @object_volume.nil?
        @errors << "Object volume is required"
      elsif @object_volume <= 0
        @errors << "Object volume must be a positive number"
      end

      if @gravity <= 0
        @errors << "Gravity must be a positive number"
      end
    end
  end
end
