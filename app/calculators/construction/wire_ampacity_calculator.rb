# frozen_string_literal: true

module Construction
  class WireAmpacityCalculator
    attr_reader :errors

    # NEC Table 310.16 ampacities — insulated conductors rated up to 2000 V
    # with not more than three current-carrying conductors in raceway/cable
    # at 30 °C (86 °F) ambient. Values in amps.
    #
    # Columns: temperature rating of the conductor insulation.
    #   60 °C  — TW, UF
    #   75 °C  — RHW, THW, THWN, XHHW, USE
    #   90 °C  — THHN, THHW, THWN-2, XHHW-2, RHW-2, USE-2
    #
    # Copper rows:
    AMPACITY_CU = {
      "14"  => { 60 => 15,  75 => 20,  90 => 25 },
      "12"  => { 60 => 20,  75 => 25,  90 => 30 },
      "10"  => { 60 => 30,  75 => 35,  90 => 40 },
      "8"   => { 60 => 40,  75 => 50,  90 => 55 },
      "6"   => { 60 => 55,  75 => 65,  90 => 75 },
      "4"   => { 60 => 70,  75 => 85,  90 => 95 },
      "3"   => { 60 => 85,  75 => 100, 90 => 115 },
      "2"   => { 60 => 95,  75 => 115, 90 => 130 },
      "1"   => { 60 => 110, 75 => 130, 90 => 145 },
      "1/0" => { 60 => 125, 75 => 150, 90 => 170 },
      "2/0" => { 60 => 145, 75 => 175, 90 => 195 },
      "3/0" => { 60 => 165, 75 => 200, 90 => 225 },
      "4/0" => { 60 => 195, 75 => 230, 90 => 260 },
      "250" => { 60 => 215, 75 => 255, 90 => 290 },
      "350" => { 60 => 260, 75 => 310, 90 => 350 },
      "500" => { 60 => 320, 75 => 380, 90 => 430 }
    }.freeze

    AMPACITY_AL = {
      "12"  => { 60 => 15,  75 => 20,  90 => 25 },
      "10"  => { 60 => 25,  75 => 30,  90 => 35 },
      "8"   => { 60 => 35,  75 => 40,  90 => 45 },
      "6"   => { 60 => 40,  75 => 50,  90 => 55 },
      "4"   => { 60 => 55,  75 => 65,  90 => 75 },
      "3"   => { 60 => 65,  75 => 75,  90 => 85 },
      "2"   => { 60 => 75,  75 => 90,  90 => 100 },
      "1"   => { 60 => 85,  75 => 100, 90 => 115 },
      "1/0" => { 60 => 100, 75 => 120, 90 => 135 },
      "2/0" => { 60 => 115, 75 => 135, 90 => 150 },
      "3/0" => { 60 => 130, 75 => 155, 90 => 175 },
      "4/0" => { 60 => 150, 75 => 180, 90 => 205 },
      "250" => { 60 => 170, 75 => 205, 90 => 230 },
      "350" => { 60 => 210, 75 => 250, 90 => 280 },
      "500" => { 60 => 260, 75 => 310, 90 => 350 }
    }.freeze

    # NEC 310.15(C)(1) adjustment for more than 3 current-carrying conductors.
    BUNDLE_DERATE = {
      4 => 0.80, 5 => 0.80, 6 => 0.80,
      7 => 0.70, 8 => 0.70, 9 => 0.70,
      10 => 0.50, 20 => 0.45, 30 => 0.40, 40 => 0.35
    }.freeze

    # NEC Table 310.15(B)(1) temperature correction factors.
    # Key is the upper bound of ambient temperature range in °C,
    # value is a hash by insulation temp rating.
    AMBIENT_CORRECTION = [
      [ 10,  { 60 => 1.29, 75 => 1.20, 90 => 1.15 } ],
      [ 15,  { 60 => 1.22, 75 => 1.15, 90 => 1.12 } ],
      [ 20,  { 60 => 1.15, 75 => 1.11, 90 => 1.08 } ],
      [ 25,  { 60 => 1.08, 75 => 1.05, 90 => 1.04 } ],
      [ 30,  { 60 => 1.00, 75 => 1.00, 90 => 1.00 } ],
      [ 35,  { 60 => 0.91, 75 => 0.94, 90 => 0.96 } ],
      [ 40,  { 60 => 0.82, 75 => 0.88, 90 => 0.91 } ],
      [ 45,  { 60 => 0.71, 75 => 0.82, 90 => 0.87 } ],
      [ 50,  { 60 => 0.58, 75 => 0.75, 90 => 0.82 } ],
      [ 55,  { 60 => 0.41, 75 => 0.67, 90 => 0.76 } ],
      [ 60,  { 60 => 0.00, 75 => 0.58, 90 => 0.71 } ]
    ].freeze

    def initialize(awg:, material:, temp_rating:, ambient_c: 30, conductor_count: 3)
      @awg = awg.to_s
      @material = material.to_s.downcase
      @temp_rating = temp_rating.to_i
      @ambient_c = ambient_c.to_f
      @count = conductor_count.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      table = @material == "cu" ? AMPACITY_CU : AMPACITY_AL
      base_ampacity = table[@awg][@temp_rating]

      ambient_factor = ambient_factor_for(@ambient_c, @temp_rating)
      bundle_factor = bundle_factor_for(@count)

      adjusted = base_ampacity * ambient_factor * bundle_factor

      {
        valid: true,
        awg: @awg,
        material: @material,
        temp_rating: @temp_rating,
        base_ampacity: base_ampacity,
        ambient_factor: ambient_factor.round(3),
        bundle_factor: bundle_factor.round(3),
        adjusted_ampacity: adjusted.round(1)
      }
    end

    private

    def validate!
      unless %w[cu al].include?(@material)
        @errors << "Material must be cu or al"
      end
      table = @material == "al" ? AMPACITY_AL : AMPACITY_CU
      unless table.key?(@awg)
        @errors << "AWG not in Table 310.16"
      end
      unless [ 60, 75, 90 ].include?(@temp_rating)
        @errors << "Temperature rating must be 60, 75, or 90 °C"
      end
      @errors << "Ambient must be -10 to 80 °C" unless (-10.0..80.0).cover?(@ambient_c)
      @errors << "Conductor count must be at least 1" if @count < 1
    end

    def ambient_factor_for(temp_c, rating)
      AMBIENT_CORRECTION.each do |upper, factors|
        return factors[rating] if temp_c <= upper
      end
      0.5
    end

    def bundle_factor_for(count)
      return 1.0 if count <= 3
      sorted = BUNDLE_DERATE.keys.sort
      best = sorted.reverse.find { |k| count >= k }
      BUNDLE_DERATE[best] || 0.35
    end
  end
end
