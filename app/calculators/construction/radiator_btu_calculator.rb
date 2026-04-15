# frozen_string_literal: true

module Construction
  class RadiatorBtuCalculator
    attr_reader :errors

    # Radiator output scales with the temperature difference (mean water
    # temp − room temp) raised to a power n. Typical values:
    #   Panel radiators (European EN 442):     n = 1.30
    #   Cast iron radiators:                   n = 1.45
    #   Fin-tube baseboard (copper):           n = 1.30
    #
    # BTU_actual = BTU_rated × (dT_actual / dT_rated) ** n
    #
    # Standard rating conditions vary by region:
    #   US fin-tube baseboard: 180 °F avg water, 65 °F room → dT=115 °F
    #   US cast iron (IBR):    170 °F avg water, 70 °F room → dT=100 °F
    #   EN 442 panel:          75 °C supply / 65 °C return / 20 °C room
    #                          → mean water 70 °C, dT = 50 °C = 90 °F
    RADIATOR_TYPES = {
      "panel"     => { exponent: 1.30, rated_dt_f: 90.0,  label: "Panel radiator (EN 442, dT 50K)" },
      "cast_iron" => { exponent: 1.45, rated_dt_f: 100.0, label: "Cast iron radiator (IBR)" },
      "fin_tube"  => { exponent: 1.30, rated_dt_f: 115.0, label: "Copper fin-tube baseboard" }
    }.freeze

    def initialize(rated_btu_hr:, radiator_type:, supply_water_f:, return_water_f:, room_temp_f:)
      @rated_btu = rated_btu_hr.to_f
      @type = radiator_type.to_s.downcase
      @supply_f = supply_water_f.to_f
      @return_f = return_water_f.to_f
      @room_f = room_temp_f.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      type_info = RADIATOR_TYPES[@type]
      n = type_info[:exponent]
      rated_dt = type_info[:rated_dt_f]

      mean_water_f = (@supply_f + @return_f) / 2.0
      actual_dt_f = mean_water_f - @room_f
      capacity_ratio = (actual_dt_f / rated_dt)**n
      actual_btu = @rated_btu * capacity_ratio

      {
        valid: true,
        type_label: type_info[:label],
        exponent: n,
        rated_dt_f: rated_dt,
        rated_btu_hr: @rated_btu.round(0),
        mean_water_f: mean_water_f.round(1),
        actual_dt_f: actual_dt_f.round(1),
        capacity_ratio: capacity_ratio.round(3),
        actual_btu_hr: actual_btu.round(0),
        actual_watts: (actual_btu / 3.412).round(0)
      }
    end

    private

    def validate!
      @errors << "Rated BTU/hr must be greater than zero" unless @rated_btu.positive?
      @errors << "Radiator type must be panel, cast_iron, or fin_tube" unless RADIATOR_TYPES.key?(@type)
      @errors << "Supply water temperature must be above room temperature" unless @supply_f > @room_f
      @errors << "Return water must be between room temp and supply" unless @return_f.between?(@room_f, @supply_f)
    end
  end
end
