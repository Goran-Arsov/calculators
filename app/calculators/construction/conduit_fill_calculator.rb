# frozen_string_literal: true

module Construction
  class ConduitFillCalculator
    attr_reader :errors

    # NEC Chapter 9 Table 5 — approximate cross-sectional area of THWN-2
    # insulated conductors in square inches. Subset of common sizes.
    WIRE_AREA_SQIN = {
      "14"  => 0.0097,
      "12"  => 0.0133,
      "10"  => 0.0211,
      "8"   => 0.0366,
      "6"   => 0.0507,
      "4"   => 0.0824,
      "3"   => 0.0973,
      "2"   => 0.1158,
      "1"   => 0.1562,
      "1/0" => 0.1855,
      "2/0" => 0.2223,
      "3/0" => 0.2679,
      "4/0" => 0.3237,
      "250" => 0.3970,
      "350" => 0.5242,
      "500" => 0.7073
    }.freeze

    # NEC Chapter 9 Table 4 — total internal area (sq in) of common
    # conduit trade sizes, by type.
    CONDUIT_AREA_SQIN = {
      "emt" => {
        "1/2"   => 0.304, "3/4" => 0.533, "1"   => 0.864, "1-1/4" => 1.496,
        "1-1/2" => 2.036, "2"   => 3.356, "2-1/2" => 5.858, "3" => 8.846, "4" => 14.753
      },
      "imc" => {
        "1/2"   => 0.342, "3/4" => 0.586, "1"   => 0.959, "1-1/4" => 1.647,
        "1-1/2" => 2.225, "2"   => 3.630, "2-1/2" => 5.135, "3" => 7.922, "4" => 12.692
      },
      "rmc" => {
        "1/2"   => 0.314, "3/4" => 0.549, "1"   => 0.887, "1-1/4" => 1.526,
        "1-1/2" => 2.071, "2"   => 3.408, "2-1/2" => 4.866, "3" => 7.499, "4" => 12.554
      },
      "pvc40" => {
        "1/2"   => 0.285, "3/4" => 0.508, "1"   => 0.832, "1-1/4" => 1.453,
        "1-1/2" => 1.986, "2"   => 3.291, "2-1/2" => 4.695, "3" => 7.268, "4" => 12.554
      }
    }.freeze

    # NEC Chapter 9 Table 1 — maximum fill percent by conductor count.
    FILL_PCT = { 1 => 53.0, 2 => 31.0, 3 => 40.0 }.freeze

    def initialize(conduit_type:, conduit_size:, wire_awg:, wire_count:)
      @conduit_type = conduit_type.to_s.downcase
      @conduit_size = conduit_size.to_s
      @wire_awg = wire_awg.to_s
      @wire_count = wire_count.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      conduit_area = CONDUIT_AREA_SQIN[@conduit_type][@conduit_size]
      wire_area = WIRE_AREA_SQIN[@wire_awg]
      fill_pct_allowed = FILL_PCT[@wire_count] || FILL_PCT[3]
      max_fill_area = conduit_area * fill_pct_allowed / 100.0
      used_area = wire_area * @wire_count
      used_pct = (used_area / conduit_area) * 100.0
      max_wires = (max_fill_area / wire_area).floor

      {
        valid: true,
        conduit_area_sqin: conduit_area,
        wire_area_sqin: wire_area,
        used_area_sqin: used_area.round(4),
        used_pct: used_pct.round(2),
        max_fill_pct: fill_pct_allowed,
        max_fill_area_sqin: max_fill_area.round(4),
        max_wires_allowed: max_wires,
        within_code: used_pct <= fill_pct_allowed
      }
    end

    private

    def validate!
      unless CONDUIT_AREA_SQIN.key?(@conduit_type)
        @errors << "Conduit type must be emt, imc, rmc, or pvc40"
        return
      end
      @errors << "Conduit size not in NEC Table 4" unless CONDUIT_AREA_SQIN[@conduit_type].key?(@conduit_size)
      @errors << "Wire AWG not in NEC Table 5" unless WIRE_AREA_SQIN.key?(@wire_awg)
      @errors << "Wire count must be at least 1" if @wire_count < 1
    end
  end
end
