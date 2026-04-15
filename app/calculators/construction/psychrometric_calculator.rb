# frozen_string_literal: true

module Construction
  class PsychrometricCalculator
    attr_reader :errors

    # Psychrometric properties from dry-bulb temperature + relative humidity.
    # Formulas:
    #   Magnus (saturation vapor pressure):
    #     Pws (hPa) = 6.112 × exp(17.62 × T / (243.12 + T))  [T in °C]
    #   Actual vapor pressure:
    #     Pw = Pws × RH/100
    #   Humidity ratio (kg/kg dry air):
    #     W = 0.622 × Pw / (P - Pw)   [P = 1013.25 hPa standard]
    #   Dew point (inverse Magnus):
    #     Td = 243.12 × ln(Pw/6.112) / (17.62 - ln(Pw/6.112))
    #   Wet bulb (Stull approximation):
    #     Tw ≈ T × atan(0.151977 × √(RH + 8.313659)) + atan(T + RH)
    #           − atan(RH − 1.676331) + 0.00391838 × RH^1.5 × atan(0.023101 × RH)
    #           − 4.686035
    #   Enthalpy (kJ/kg dry air):
    #     h = 1.006 × T + W × (2501 + 1.86 × T)
    STANDARD_PRESSURE_HPA = 1013.25

    def initialize(dry_bulb_f:, relative_humidity:)
      @dry_bulb_f = dry_bulb_f.to_f
      @rh = relative_humidity.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      t_c = f_to_c(@dry_bulb_f)
      pws = 6.112 * Math.exp(17.62 * t_c / (243.12 + t_c))
      pw = pws * @rh / 100.0
      w = 0.622 * pw / (STANDARD_PRESSURE_HPA - pw) # kg/kg dry air
      humidity_ratio_gr_per_lb = w * 7000.0 # 1 kg/kg = 7000 grains/lb
      enthalpy_kjkg = 1.006 * t_c + w * (2501.0 + 1.86 * t_c)
      enthalpy_btulb = enthalpy_kjkg * 0.4299 # kJ/kg → BTU/lb dry air

      dew_point_c =
        if pw <= 0
          t_c
        else
          ln_ratio = Math.log(pw / 6.112)
          243.12 * ln_ratio / (17.62 - ln_ratio)
        end

      wet_bulb_c = stull_wet_bulb(t_c, @rh)

      {
        valid: true,
        dry_bulb_f: @dry_bulb_f.round(1),
        dry_bulb_c: t_c.round(2),
        rh_pct: @rh.round(1),
        dew_point_f: c_to_f(dew_point_c).round(1),
        dew_point_c: dew_point_c.round(2),
        wet_bulb_f: c_to_f(wet_bulb_c).round(1),
        wet_bulb_c: wet_bulb_c.round(2),
        humidity_ratio_kg_kg: w.round(5),
        humidity_ratio_gr_lb: humidity_ratio_gr_per_lb.round(1),
        vapor_pressure_hpa: pw.round(2),
        saturation_pressure_hpa: pws.round(2),
        enthalpy_btu_lb: enthalpy_btulb.round(2),
        enthalpy_kj_kg: enthalpy_kjkg.round(2)
      }
    end

    private

    def validate!
      @errors << "Dry bulb temperature must be above -40 °F" if @dry_bulb_f < -40
      @errors << "Dry bulb temperature must be below 140 °F" if @dry_bulb_f > 140
      @errors << "Relative humidity must be between 0 and 100" unless (0.0..100.0).cover?(@rh)
    end

    def f_to_c(f)
      (f - 32.0) * 5.0 / 9.0
    end

    def c_to_f(c)
      c * 9.0 / 5.0 + 32.0
    end

    # Stull (2011) wet-bulb approximation. Accurate within ±1 °C for common
    # conditions; not a substitute for iterative psychrometric software.
    def stull_wet_bulb(t_c, rh)
      t_c * Math.atan(0.151977 * Math.sqrt(rh + 8.313659)) +
        Math.atan(t_c + rh) -
        Math.atan(rh - 1.676331) +
        0.00391838 * (rh**1.5) * Math.atan(0.023101 * rh) -
        4.686035
    end
  end
end
