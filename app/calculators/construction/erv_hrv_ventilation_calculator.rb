# frozen_string_literal: true

module Construction
  class ErvHrvVentilationCalculator
    attr_reader :errors

    # ASHRAE 62.2-2022 whole-house ventilation rate for dwellings:
    #   Q_tot (CFM) = 0.03 × A_floor + 7.5 × (N_br + 1)
    # where A_floor is conditioned floor area (sq ft) and N_br is the number
    # of bedrooms. This is the required total outdoor airflow; mechanical
    # ventilation makes up whatever infiltration does not provide.
    #
    # Infiltration credit: if your house has measured ACH50 (blower door
    # test), you can subtract an infiltration credit from the required
    # mechanical ventilation. The 62.2 credit is based on stories and
    # climate but a common shortcut is Q_inf = ACH50 × volume / (60 × NF)
    # where NF is an LBL normalization factor (typically 17 for mixed climate).
    def initialize(floor_area_sqft:, bedrooms:, ach50: nil, volume_cuft: nil, nf: 17)
      @floor_area = floor_area_sqft.to_f
      @bedrooms = bedrooms.to_i
      @ach50 = ach50.nil? ? nil : ach50.to_f
      @volume = volume_cuft.nil? ? nil : volume_cuft.to_f
      @nf = nf.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      q_total = (0.03 * @floor_area) + (7.5 * (@bedrooms + 1))

      q_infiltration = 0.0
      if @ach50 && @volume && @ach50.positive? && @volume.positive?
        # Natural ACH ≈ ACH50 / NF; CFM = natural_ach × volume / 60.
        natural_ach = @ach50 / @nf
        q_infiltration = natural_ach * @volume / 60.0
      end

      q_mechanical = [ q_total - q_infiltration, 0 ].max

      {
        valid: true,
        total_required_cfm: q_total.round(1),
        infiltration_cfm: q_infiltration.round(1),
        mechanical_cfm: q_mechanical.round(1),
        bedrooms: @bedrooms,
        floor_area_sqft: @floor_area.round(0)
      }
    end

    private

    def validate!
      @errors << "Floor area must be greater than zero" unless @floor_area.positive?
      @errors << "Bedrooms cannot be negative" if @bedrooms.negative?
      @errors << "ACH50 cannot be negative" if @ach50 && @ach50.negative?
      @errors << "Volume must be positive if ACH50 is given" if @ach50 && @ach50.positive? && !(@volume && @volume.positive?)
      @errors << "Normalization factor must be positive" unless @nf.positive?
    end
  end
end
