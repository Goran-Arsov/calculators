# frozen_string_literal: true

module Construction
  class HeatLossCalculator
    attr_reader :errors

    # Simplified whole-house heat loss:
    #   Q (BTU/hr) = Σ (U × A × ΔT) for each envelope component
    # U-value = 1 / R-value for each assembly.
    # ΔT = indoor design temp − outdoor design temp.
    #
    # This is a "Manual J lite" — not a substitute for a full room-by-room
    # ACCA Manual J calculation, but it gives a useful whole-house total
    # for sizing heaters, heat pumps, and radiators.
    BTU_PER_WATT = 3.412142
    INFILTRATION_ACH_DEFAULT = 0.5 # air changes per hour, average house

    def initialize(wall_area_sqft:, wall_r:,
                   roof_area_sqft:, roof_r:,
                   window_area_sqft:, window_u:,
                   floor_area_sqft:, floor_r:,
                   volume_cuft:, indoor_f:, outdoor_f:,
                   infiltration_ach: INFILTRATION_ACH_DEFAULT)
      @wall_area = wall_area_sqft.to_f
      @wall_r = wall_r.to_f
      @roof_area = roof_area_sqft.to_f
      @roof_r = roof_r.to_f
      @window_area = window_area_sqft.to_f
      @window_u = window_u.to_f
      @floor_area = floor_area_sqft.to_f
      @floor_r = floor_r.to_f
      @volume = volume_cuft.to_f
      @indoor_f = indoor_f.to_f
      @outdoor_f = outdoor_f.to_f
      @infiltration_ach = infiltration_ach.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      dt = @indoor_f - @outdoor_f

      # Subtract window area from net wall area so we don't double count.
      net_wall_area = [ @wall_area - @window_area, 0 ].max

      wall_u = 1.0 / @wall_r
      roof_u = 1.0 / @roof_r
      floor_u = 1.0 / @floor_r

      wall_loss = wall_u * net_wall_area * dt
      roof_loss = roof_u * @roof_area * dt
      window_loss = @window_u * @window_area * dt
      floor_loss = floor_u * @floor_area * dt
      # Infiltration: Q = 0.018 × ACH × volume × ΔT (rule-of-thumb for air)
      infiltration_loss = 0.018 * @infiltration_ach * @volume * dt

      total_btu_hr = wall_loss + roof_loss + window_loss + floor_loss + infiltration_loss
      total_watts = total_btu_hr / BTU_PER_WATT

      {
        valid: true,
        dt_f: dt.round(1),
        wall_loss_btu_hr: wall_loss.round(0),
        roof_loss_btu_hr: roof_loss.round(0),
        window_loss_btu_hr: window_loss.round(0),
        floor_loss_btu_hr: floor_loss.round(0),
        infiltration_loss_btu_hr: infiltration_loss.round(0),
        total_btu_hr: total_btu_hr.round(0),
        total_watts: total_watts.round(0),
        total_kw: (total_watts / 1000).round(2)
      }
    end

    private

    def validate!
      @errors << "Wall area must be greater than zero" unless @wall_area.positive?
      @errors << "Wall R-value must be greater than zero" unless @wall_r.positive?
      @errors << "Roof area must be greater than zero" unless @roof_area.positive?
      @errors << "Roof R-value must be greater than zero" unless @roof_r.positive?
      @errors << "Window area must be zero or greater" if @window_area.negative?
      @errors << "Window U-value must be greater than zero" unless @window_u.positive?
      @errors << "Floor area must be greater than zero" unless @floor_area.positive?
      @errors << "Floor R-value must be greater than zero" unless @floor_r.positive?
      @errors << "Volume must be greater than zero" unless @volume.positive?
      @errors << "Indoor temperature must be greater than outdoor" unless @indoor_f > @outdoor_f
      @errors << "Infiltration ACH cannot be negative" if @infiltration_ach.negative?
    end
  end
end
