# frozen_string_literal: true

module Construction
  class VoltageDropCalculator
    attr_reader :errors

    # NEC Chapter 9 Table 8 — uncoated stranded conductor DC resistance
    # at 75 °C, in ohms per 1000 ft. Subset of common residential sizes.
    # Copper + aluminum are both listed.
    RESISTANCE_OHMS_PER_1000FT = {
      "14"  => { "cu" => 3.140, "al" => 5.060 },
      "12"  => { "cu" => 1.980, "al" => 3.180 },
      "10"  => { "cu" => 1.240, "al" => 2.000 },
      "8"   => { "cu" => 0.778, "al" => 1.260 },
      "6"   => { "cu" => 0.491, "al" => 0.808 },
      "4"   => { "cu" => 0.308, "al" => 0.508 },
      "3"   => { "cu" => 0.245, "al" => 0.403 },
      "2"   => { "cu" => 0.194, "al" => 0.319 },
      "1"   => { "cu" => 0.154, "al" => 0.253 },
      "1/0" => { "cu" => 0.122, "al" => 0.201 },
      "2/0" => { "cu" => 0.0967, "al" => 0.159 },
      "3/0" => { "cu" => 0.0766, "al" => 0.126 },
      "4/0" => { "cu" => 0.0608, "al" => 0.100 },
      "250" => { "cu" => 0.0515, "al" => 0.0847 },
      "350" => { "cu" => 0.0367, "al" => 0.0605 },
      "500" => { "cu" => 0.0258, "al" => 0.0424 }
    }.freeze

    NEC_BRANCH_MAX_PCT = 3.0
    NEC_TOTAL_MAX_PCT = 5.0

    def initialize(awg:, length_ft:, amps:, voltage:, phase: "single", material: "cu")
      @awg = awg.to_s
      @length_ft = length_ft.to_f
      @amps = amps.to_f
      @voltage = voltage.to_f
      @phase = phase.to_s.downcase
      @material = material.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      r_per_1000ft = RESISTANCE_OHMS_PER_1000FT[@awg][@material]
      # Vd = K × L × I × R / 1000, where K = 2 for single-phase (round trip),
      # 1.732 for three-phase line-to-line.
      k = @phase == "three" ? Math.sqrt(3) : 2.0
      vd_volts = (k * @length_ft * @amps * r_per_1000ft) / 1000.0
      vd_pct = (vd_volts / @voltage) * 100.0
      end_volts = @voltage - vd_volts
      within_branch = vd_pct <= NEC_BRANCH_MAX_PCT
      within_total = vd_pct <= NEC_TOTAL_MAX_PCT

      {
        valid: true,
        awg: @awg,
        resistance_per_1000ft: r_per_1000ft,
        vd_volts: vd_volts.round(3),
        vd_pct: vd_pct.round(2),
        end_volts: end_volts.round(2),
        within_branch_3pct: within_branch,
        within_total_5pct: within_total
      }
    end

    private

    def validate!
      @errors << "AWG must be one of #{RESISTANCE_OHMS_PER_1000FT.keys.join(', ')}" unless RESISTANCE_OHMS_PER_1000FT.key?(@awg)
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Amps must be greater than zero" unless @amps.positive?
      @errors << "Voltage must be greater than zero" unless @voltage.positive?
      @errors << "Phase must be single or three" unless %w[single three].include?(@phase)
      @errors << "Material must be cu or al" unless %w[cu al].include?(@material)
    end
  end
end
