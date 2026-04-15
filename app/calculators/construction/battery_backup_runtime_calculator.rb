# frozen_string_literal: true

module Construction
  class BatteryBackupRuntimeCalculator
    attr_reader :errors

    # Runtime (hours) = usable_energy_wh / load_watts
    # usable_energy_wh = nominal_kwh × 1000 × depth_of_discharge × inverter_efficiency
    #
    # Typical values:
    #   DoD (depth of discharge) — LiFePO4: 100%, Li-ion: 80-90%, lead-acid: 50%
    #   Inverter efficiency — modern hybrid: 92-96%, older: 85-90%
    DEFAULT_DOD = 95.0       # % (typical for home LFP batteries)
    DEFAULT_INV_EFF = 94.0   # % (modern hybrid inverter)

    def initialize(battery_kwh:, load_watts:, depth_of_discharge: DEFAULT_DOD, inverter_efficiency: DEFAULT_INV_EFF)
      @battery_kwh = battery_kwh.to_f
      @load_w = load_watts.to_f
      @dod = depth_of_discharge.to_f
      @inv_eff = inverter_efficiency.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      usable_wh = @battery_kwh * 1000.0 * (@dod / 100.0) * (@inv_eff / 100.0)
      runtime_hours = usable_wh / @load_w
      runtime_minutes = runtime_hours * 60.0
      hours = runtime_hours.floor
      minutes = (runtime_minutes - hours * 60).round

      {
        valid: true,
        battery_kwh: @battery_kwh.round(2),
        usable_kwh: (usable_wh / 1000.0).round(2),
        load_watts: @load_w.round(0),
        runtime_hours: runtime_hours.round(2),
        runtime_display: format("%d h %d min", hours, minutes),
        dod_pct: @dod.round(1),
        inverter_eff_pct: @inv_eff.round(1)
      }
    end

    private

    def validate!
      @errors << "Battery capacity must be greater than zero" unless @battery_kwh.positive?
      @errors << "Load must be greater than zero" unless @load_w.positive?
      @errors << "Depth of discharge must be between 10 and 100" unless (10.0..100.0).cover?(@dod)
      @errors << "Inverter efficiency must be between 70 and 100" unless (70.0..100.0).cover?(@inv_eff)
    end
  end
end
