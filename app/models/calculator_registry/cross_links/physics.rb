# frozen_string_literal: true

class CalculatorRegistry
  module CrossLinks
    PHYSICS = {
      "velocity-calculator" => %w[force-calculator speed-converter projectile-motion-calculator],
      "force-calculator" => %w[velocity-calculator kinetic-energy-calculator centripetal-force-calculator],
      "kinetic-energy-calculator" => %w[velocity-calculator force-calculator spring-constant-calculator],
      "projectile-motion-calculator" => %w[velocity-calculator force-calculator pendulum-calculator],
      "centripetal-force-calculator" => %w[force-calculator velocity-calculator spring-constant-calculator],
      "spring-constant-calculator" => %w[kinetic-energy-calculator force-calculator pendulum-calculator],
      "pendulum-calculator" => %w[kinetic-energy-calculator spring-constant-calculator wavelength-frequency-calculator],
      "buoyancy-calculator" => %w[pressure-converter element-volume-calculator pool-volume-calculator],
      "doppler-effect-calculator" => %w[velocity-calculator wavelength-frequency-calculator decibel-calculator],
      "wavelength-frequency-calculator" => %w[doppler-effect-calculator decibel-calculator lens-optics-calculator],
      "decibel-calculator" => %w[hearing-loss-exposure-calculator wavelength-frequency-calculator doppler-effect-calculator],
      "lens-optics-calculator" => %w[depth-of-field-calculator exposure-triangle-calculator aspect-ratio-calculator],
      "ohms-law-calculator" => %w[electrical-power-calculator resistor-color-code-calculator wire-gauge-calculator],
      "electrical-power-calculator" => %w[ohms-law-calculator electricity-cost-calculator resistor-color-code-calculator],
      "resistor-color-code-calculator" => %w[ohms-law-calculator electrical-power-calculator capacitor-calculator],
      "capacitor-calculator" => %w[inductor-calculator transformer-turns-ratio-calculator electrical-power-calculator],
      "inductor-calculator" => %w[capacitor-calculator transformer-turns-ratio-calculator electrical-power-calculator],
      "transformer-turns-ratio-calculator" => %w[ohms-law-calculator electrical-power-calculator voltage-drop-calculator],
      "wire-gauge-calculator" => %w[voltage-drop-calculator electrical-load-calculator wire-ampacity-calculator],
      "electricity-cost-calculator" => %w[electricity-bill-calculator kwh-to-cost-calculator solar-savings-calculator],
      "radioactive-decay-calculator" => %w[caffeine-half-life-calculator exponent-calculator compound-interest-calculator],
      "heat-transfer-calculator" => %w[heat-loss-calculator insulation-calculator radiant-floor-heat-calculator],
      "element-mass-calculator" => %w[element-volume-calculator weight-converter volume-converter],
      "element-volume-calculator" => %w[element-mass-calculator volume-converter buoyancy-calculator],
      "gear-ratio-calculator" => %w[velocity-calculator engine-horsepower-calculator aspect-ratio-calculator],
      "pressure-converter" => %w[unit-converter temperature-converter buoyancy-calculator],
      "planet-weight-calculator" => %w[weight-converter force-calculator kinetic-energy-calculator],
      "unit-converter" => %w[length-converter weight-converter speed-converter]
    }.freeze
  end
end
