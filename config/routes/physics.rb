namespace :physics do
  get "velocity-calculator", to: "calculators#velocity", as: :velocity
  get "force-calculator", to: "calculators#force", as: :force
  get "kinetic-energy-calculator", to: "calculators#kinetic_energy", as: :kinetic_energy
  get "ohms-law-calculator", to: "calculators#ohms_law", as: :ohms_law
  get "projectile-motion-calculator", to: "calculators#projectile_motion", as: :projectile_motion
  get "element-mass-calculator", to: "calculators#element_mass", as: :element_mass
  get "element-volume-calculator", to: "calculators#element_volume", as: :element_volume
  get "unit-converter", to: "calculators#unit_converter", as: :unit_converter
  get "electricity-cost-calculator", to: "calculators#electricity_cost", as: :electricity_cost
  get "wire-gauge-calculator", to: "calculators#wire_gauge", as: :wire_gauge
  get "decibel-calculator", to: "calculators#decibel", as: :decibel
  get "wavelength-frequency-calculator", to: "calculators#wavelength_frequency", as: :wavelength_frequency
  get "planet-weight-calculator", to: "calculators#planet_weight", as: :planet_weight
  get "resistor-color-code-calculator", to: "calculators#resistor_color_code", as: :resistor_color_code
  get "gear-ratio-calculator", to: "calculators#gear_ratio", as: :gear_ratio
  get "pressure-converter", to: "calculators#pressure_converter", as: :pressure_converter
  get "heat-transfer-calculator", to: "calculators#heat_transfer", as: :heat_transfer
  get "spring-constant-calculator", to: "calculators#spring_constant", as: :spring_constant
end
