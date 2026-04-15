# frozen_string_literal: true

module Construction
  class SolarInverterSizingCalculator
    attr_reader :errors

    # Solar inverter sizing rule of thumb:
    #   inverter_ac_kw = panel_dc_kw / dc_ac_ratio
    # where dc_ac_ratio is typically 1.15-1.30 (PV is oversized relative to
    # inverter because real panels rarely reach STC output and clipping is
    # minimal). Ratios up to 1.50 are allowed by AHJ in high-DNI sites
    # with east/west facing arrays.
    #
    # NEC 690.8 requires 125% overcurrent protection on the inverter output
    # circuit: breaker_amps >= 1.25 × inverter_max_ac_amps.
    def initialize(panel_watts:, panel_count:, dc_ac_ratio: 1.20, ac_voltage: 240)
      @panel_watts = panel_watts.to_f
      @panel_count = panel_count.to_i
      @ratio = dc_ac_ratio.to_f
      @ac_voltage = ac_voltage.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      array_dc_watts = @panel_watts * @panel_count
      inverter_ac_watts = array_dc_watts / @ratio
      inverter_kw = inverter_ac_watts / 1000.0
      array_kw = array_dc_watts / 1000.0
      inverter_max_amps = inverter_ac_watts / @ac_voltage
      breaker_amps_required = inverter_max_amps * 1.25 # NEC 690.8
      # Round up to standard breaker sizes
      standard_breakers = [ 15, 20, 25, 30, 40, 50, 60, 70, 80, 100, 125, 150, 175, 200 ]
      recommended_breaker = standard_breakers.find { |b| b >= breaker_amps_required } || 200

      {
        valid: true,
        array_dc_watts: array_dc_watts.round(0),
        array_dc_kw: array_kw.round(3),
        dc_ac_ratio: @ratio.round(2),
        inverter_ac_watts: inverter_ac_watts.round(0),
        inverter_ac_kw: inverter_kw.round(2),
        inverter_max_amps: inverter_max_amps.round(1),
        breaker_amps_required: breaker_amps_required.round(1),
        recommended_breaker: recommended_breaker
      }
    end

    private

    def validate!
      @errors << "Panel wattage must be greater than zero" unless @panel_watts.positive?
      @errors << "Panel count must be at least 1" unless @panel_count >= 1
      @errors << "DC/AC ratio must be between 1.0 and 1.5" unless (1.0..1.5).cover?(@ratio)
      @errors << "AC voltage must be greater than zero" unless @ac_voltage.positive?
    end
  end
end
