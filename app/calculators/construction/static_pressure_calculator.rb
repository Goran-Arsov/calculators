# frozen_string_literal: true

module Construction
  class StaticPressureCalculator
    attr_reader :errors

    # Total external static pressure (TESP) on a residential HVAC blower is
    # the sum of friction losses through:
    #   - Supply duct trunk + longest branch run
    #   - Return duct run
    #   - Filter (typical pressure drop varies by MERV rating)
    #   - Cooling coil (wet coil drop)
    #   - Registers/grilles (usually lumped in)
    #
    # This calculator uses the Darcy-Weisbach friction approximation for
    # galvanized round duct at standard air, plus typical filter/coil drops.
    # Duct friction per 100 ft for standard air (iwc/100 ft):
    #   hf/100 = 0.109136 × (Q^1.9) / (D^5.02)
    # where Q in CFM and D in inches round duct (or equivalent round for rect).
    #
    # Filter drop by MERV rating (typical new-filter clean-element values):
    MERV_PRESSURE_DROP = {
      8  => 0.08,
      11 => 0.14,
      13 => 0.22,
      16 => 0.35
    }.freeze

    # Typical residential evaporator coil wet-coil drop at rated airflow.
    DEFAULT_COIL_DROP = 0.25

    def initialize(cfm:, duct_length_ft:, duct_diameter_in:, fittings: 0, merv: 8, coil_drop: DEFAULT_COIL_DROP)
      @cfm = cfm.to_f
      @length_ft = duct_length_ft.to_f
      @d = duct_diameter_in.to_f
      @fittings = fittings.to_i
      @merv = merv.to_i
      @coil_drop = coil_drop.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Friction per 100 ft
      hf_per_100 = 0.109136 * (@cfm**1.9) / (@d**5.02)
      duct_drop = hf_per_100 * @length_ft / 100.0
      # Each fitting ≈ 10 ft equivalent length at residential scale.
      fitting_equiv_ft = @fittings * 10.0
      fitting_drop = hf_per_100 * fitting_equiv_ft / 100.0

      filter_drop = MERV_PRESSURE_DROP[@merv] || 0.1
      total = duct_drop + fitting_drop + filter_drop + @coil_drop
      over_0_5 = total > 0.5
      over_0_8 = total > 0.8

      {
        valid: true,
        friction_per_100ft_iwc: hf_per_100.round(4),
        duct_drop_iwc: duct_drop.round(3),
        fitting_drop_iwc: fitting_drop.round(3),
        filter_drop_iwc: filter_drop.round(3),
        coil_drop_iwc: @coil_drop.round(3),
        total_static_iwc: total.round(3),
        total_static_pa: (total * 249.089).round(0), # 1 iwc ≈ 249.089 Pa
        over_0_5: over_0_5,
        over_0_8: over_0_8
      }
    end

    private

    def validate!
      @errors << "CFM must be greater than zero" unless @cfm.positive?
      @errors << "Duct length must be greater than zero" unless @length_ft.positive?
      @errors << "Duct diameter must be greater than zero" unless @d.positive?
      @errors << "Fittings cannot be negative" if @fittings.negative?
      @errors << "Coil drop cannot be negative" if @coil_drop.negative?
      @errors << "MERV must be one of #{MERV_PRESSURE_DROP.keys.join(', ')}" unless MERV_PRESSURE_DROP.key?(@merv)
    end
  end
end
