# frozen_string_literal: true

module Construction
  class CoolingLoadCalculator
    attr_reader :errors

    # Whole-house cooling load = conduction + solar + people + internal + infiltration.
    # Formulas follow Manual J at a simplified whole-house scale.
    #   Conduction:  Q = U × A × ΔT
    #   Solar gain:  Q = A × SHGC × peak solar (200 BTU/h·ft² for south, summer)
    #   People:      Q = 300 BTU/hr each (sensible + latent)
    #   Lighting:    Q = 3.4 × watts
    #   Infiltration: Q = 1.08 × CFM × ΔT  (sensible air conversion factor)
    PEAK_SOLAR_BY_ORIENTATION = {
      "s" => 150.0,
      "e" => 200.0,
      "w" => 200.0,
      "n" => 40.0
    }.freeze

    PEOPLE_SENSIBLE_BTU = 300.0
    WATTS_TO_BTU_HR = 3.412

    def initialize(wall_area_sqft:, wall_r:,
                   roof_area_sqft:, roof_r:,
                   window_area_sqft:, window_u:, window_shgc:, window_orientation:,
                   floor_area_sqft:,
                   people:, lighting_watts:,
                   indoor_f:, outdoor_f:,
                   infiltration_cfm: 0.0)
      @wall_area = wall_area_sqft.to_f
      @wall_r = wall_r.to_f
      @roof_area = roof_area_sqft.to_f
      @roof_r = roof_r.to_f
      @window_area = window_area_sqft.to_f
      @window_u = window_u.to_f
      @window_shgc = window_shgc.to_f
      @window_orientation = window_orientation.to_s.downcase
      @floor_area = floor_area_sqft.to_f
      @people = people.to_i
      @lighting_watts = lighting_watts.to_f
      @indoor_f = indoor_f.to_f
      @outdoor_f = outdoor_f.to_f
      @infiltration_cfm = infiltration_cfm.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      dt = @outdoor_f - @indoor_f
      net_wall = [ @wall_area - @window_area, 0 ].max

      conduction_walls = (1.0 / @wall_r) * net_wall * dt
      conduction_roof = (1.0 / @roof_r) * @roof_area * dt
      conduction_windows = @window_u * @window_area * dt
      solar_windows = @window_area * @window_shgc * PEAK_SOLAR_BY_ORIENTATION[@window_orientation]
      people_gain = @people * PEOPLE_SENSIBLE_BTU
      lighting_gain = @lighting_watts * WATTS_TO_BTU_HR
      infiltration_gain = 1.08 * @infiltration_cfm * dt

      total_btu_hr = conduction_walls + conduction_roof + conduction_windows +
                     solar_windows + people_gain + lighting_gain + infiltration_gain
      tons = total_btu_hr / 12_000.0

      {
        valid: true,
        dt_f: dt.round(1),
        conduction_walls_btu_hr: conduction_walls.round(0),
        conduction_roof_btu_hr: conduction_roof.round(0),
        conduction_windows_btu_hr: conduction_windows.round(0),
        solar_windows_btu_hr: solar_windows.round(0),
        people_btu_hr: people_gain.round(0),
        lighting_btu_hr: lighting_gain.round(0),
        infiltration_btu_hr: infiltration_gain.round(0),
        total_btu_hr: total_btu_hr.round(0),
        total_watts: (total_btu_hr / WATTS_TO_BTU_HR).round(0),
        tons: tons.round(2)
      }
    end

    private

    def validate!
      @errors << "Wall area must be greater than zero" unless @wall_area.positive?
      @errors << "Wall R-value must be greater than zero" unless @wall_r.positive?
      @errors << "Roof area must be greater than zero" unless @roof_area.positive?
      @errors << "Roof R-value must be greater than zero" unless @roof_r.positive?
      @errors << "Window area cannot be negative" if @window_area.negative?
      @errors << "Window U-value must be greater than zero" unless @window_u.positive?
      @errors << "Window SHGC must be between 0 and 1" unless (0.0..1.0).cover?(@window_shgc)
      unless PEAK_SOLAR_BY_ORIENTATION.key?(@window_orientation)
        @errors << "Window orientation must be n, s, e, or w"
      end
      @errors << "People cannot be negative" if @people.negative?
      @errors << "Lighting watts cannot be negative" if @lighting_watts.negative?
      @errors << "Outdoor temperature must be greater than indoor" unless @outdoor_f > @indoor_f
      @errors << "Infiltration CFM cannot be negative" if @infiltration_cfm.negative?
    end
  end
end
