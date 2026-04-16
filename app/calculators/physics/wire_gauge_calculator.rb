# frozen_string_literal: true

module Physics
  class WireGaugeCalculator
    attr_reader :errors

    # AWG wire data: gauge => { diameter_mm, area_mm2, resistance_ohm_per_km, ampacity_a }
    # Resistance is for copper at 20°C. Ampacity for chassis wiring (single conductor in free air).
    AWG_DATA = {
      "0000" => { diameter_mm: 11.684, area_mm2: 107.22, resistance_ohm_per_km: 0.1608, ampacity_a: 302 },
      "000"  => { diameter_mm: 10.405, area_mm2: 85.029, resistance_ohm_per_km: 0.2028, ampacity_a: 239 },
      "00"   => { diameter_mm: 9.266,  area_mm2: 67.431, resistance_ohm_per_km: 0.2557, ampacity_a: 190 },
      "0"    => { diameter_mm: 8.251,  area_mm2: 53.475, resistance_ohm_per_km: 0.3224, ampacity_a: 150 },
      "1"    => { diameter_mm: 7.348,  area_mm2: 42.408, resistance_ohm_per_km: 0.4066, ampacity_a: 119 },
      "2"    => { diameter_mm: 6.544,  area_mm2: 33.631, resistance_ohm_per_km: 0.5127, ampacity_a: 94 },
      "3"    => { diameter_mm: 5.827,  area_mm2: 26.670, resistance_ohm_per_km: 0.6465, ampacity_a: 75 },
      "4"    => { diameter_mm: 5.189,  area_mm2: 21.151, resistance_ohm_per_km: 0.8152, ampacity_a: 60 },
      "5"    => { diameter_mm: 4.621,  area_mm2: 16.773, resistance_ohm_per_km: 1.028,  ampacity_a: 47 },
      "6"    => { diameter_mm: 4.115,  area_mm2: 13.302, resistance_ohm_per_km: 1.296,  ampacity_a: 37 },
      "7"    => { diameter_mm: 3.665,  area_mm2: 10.549, resistance_ohm_per_km: 1.634,  ampacity_a: 30 },
      "8"    => { diameter_mm: 3.264,  area_mm2: 8.366,  resistance_ohm_per_km: 2.061,  ampacity_a: 24 },
      "9"    => { diameter_mm: 2.906,  area_mm2: 6.632,  resistance_ohm_per_km: 2.599,  ampacity_a: 19 },
      "10"   => { diameter_mm: 2.588,  area_mm2: 5.261,  resistance_ohm_per_km: 3.277,  ampacity_a: 15 },
      "11"   => { diameter_mm: 2.305,  area_mm2: 4.172,  resistance_ohm_per_km: 4.132,  ampacity_a: 12 },
      "12"   => { diameter_mm: 2.053,  area_mm2: 3.309,  resistance_ohm_per_km: 5.211,  ampacity_a: 9.3 },
      "13"   => { diameter_mm: 1.828,  area_mm2: 2.624,  resistance_ohm_per_km: 6.571,  ampacity_a: 7.4 },
      "14"   => { diameter_mm: 1.628,  area_mm2: 2.081,  resistance_ohm_per_km: 8.286,  ampacity_a: 5.9 },
      "15"   => { diameter_mm: 1.450,  area_mm2: 1.650,  resistance_ohm_per_km: 10.45,  ampacity_a: 4.7 },
      "16"   => { diameter_mm: 1.291,  area_mm2: 1.309,  resistance_ohm_per_km: 13.17,  ampacity_a: 3.7 },
      "17"   => { diameter_mm: 1.150,  area_mm2: 1.038,  resistance_ohm_per_km: 16.61,  ampacity_a: 2.9 },
      "18"   => { diameter_mm: 1.024,  area_mm2: 0.823,  resistance_ohm_per_km: 20.95,  ampacity_a: 2.3 },
      "19"   => { diameter_mm: 0.912,  area_mm2: 0.653,  resistance_ohm_per_km: 26.42,  ampacity_a: 1.8 },
      "20"   => { diameter_mm: 0.812,  area_mm2: 0.518,  resistance_ohm_per_km: 33.31,  ampacity_a: 1.5 },
      "22"   => { diameter_mm: 0.644,  area_mm2: 0.326,  resistance_ohm_per_km: 52.96,  ampacity_a: 0.92 },
      "24"   => { diameter_mm: 0.511,  area_mm2: 0.205,  resistance_ohm_per_km: 84.22,  ampacity_a: 0.577 },
      "26"   => { diameter_mm: 0.405,  area_mm2: 0.129,  resistance_ohm_per_km: 133.9,  ampacity_a: 0.361 },
      "28"   => { diameter_mm: 0.321,  area_mm2: 0.0810, resistance_ohm_per_km: 212.9,  ampacity_a: 0.226 },
      "30"   => { diameter_mm: 0.255,  area_mm2: 0.0510, resistance_ohm_per_km: 338.6,  ampacity_a: 0.142 },
      "32"   => { diameter_mm: 0.202,  area_mm2: 0.0320, resistance_ohm_per_km: 538.3,  ampacity_a: 0.091 },
      "34"   => { diameter_mm: 0.160,  area_mm2: 0.0201, resistance_ohm_per_km: 856.0,  ampacity_a: 0.057 },
      "36"   => { diameter_mm: 0.127,  area_mm2: 0.0127, resistance_ohm_per_km: 1361.0, ampacity_a: 0.036 },
      "38"   => { diameter_mm: 0.101,  area_mm2: 0.00797, resistance_ohm_per_km: 2164.0, ampacity_a: 0.022 },
      "40"   => { diameter_mm: 0.0799, area_mm2: 0.00501, resistance_ohm_per_km: 3441.0, ampacity_a: 0.014 }
    }.freeze

    GAUGE_ORDER = %w[0000 000 00 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 22 24 26 28 30 32 34 36 38 40].freeze

    def initialize(gauge:)
      @gauge = gauge.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      data = AWG_DATA[@gauge]
      {
        valid: true,
        gauge: @gauge,
        diameter_mm: data[:diameter_mm],
        diameter_in: (data[:diameter_mm] / 25.4).round(4),
        area_mm2: data[:area_mm2],
        resistance_ohm_per_km: data[:resistance_ohm_per_km],
        resistance_ohm_per_1000ft: (data[:resistance_ohm_per_km] * 0.3048).round(4),
        ampacity_a: data[:ampacity_a]
      }
    end

    private

    def validate!
      @errors << "Unknown AWG gauge: #{@gauge}" unless AWG_DATA.key?(@gauge)
    end
  end
end
