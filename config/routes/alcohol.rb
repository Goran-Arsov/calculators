namespace :alcohol do
  get "abv-calculator", to: "calculators#abv", as: :abv
  get "ibu-calculator", to: "calculators#ibu", as: :ibu
  get "srm-beer-color-calculator", to: "calculators#srm", as: :srm
  get "strike-water-temperature-calculator", to: "calculators#strike_water", as: :strike_water
  get "hydrometer-temperature-correction-calculator", to: "calculators#hydrometer_correction", as: :hydrometer_correction
  get "brix-to-gravity-refractometer-converter", to: "calculators#brix_to_gravity", as: :brix_to_gravity
  get "yeast-pitch-rate-calculator", to: "calculators#yeast_pitch", as: :yeast_pitch
  get "priming-sugar-calculator", to: "calculators#priming_sugar", as: :priming_sugar
  get "keg-force-carbonation-calculator", to: "calculators#keg_force_carbonation", as: :keg_force_carbonation
  get "distiller-proofing-dilution-calculator", to: "calculators#distiller_proofing", as: :distiller_proofing
  get "cocktail-abv-calculator", to: "calculators#cocktail_abv", as: :cocktail_abv
  get "pour-cost-calculator", to: "calculators#pour_cost", as: :pour_cost
end
