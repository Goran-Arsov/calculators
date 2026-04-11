namespace :gardening do
  get "mulch-calculator", to: "calculators#mulch", as: :mulch
  get "topsoil-calculator", to: "calculators#topsoil", as: :topsoil
  get "raised-bed-soil-calculator", to: "calculators#raised_bed_soil", as: :raised_bed_soil
  get "compost-calculator", to: "calculators#compost", as: :compost
  get "fertilizer-calculator", to: "calculators#fertilizer", as: :fertilizer
  get "grass-seed-calculator", to: "calculators#grass_seed", as: :grass_seed
  get "lawn-watering-calculator", to: "calculators#lawn_watering", as: :lawn_watering
  get "plant-spacing-calculator", to: "calculators#plant_spacing", as: :plant_spacing
  get "growing-degree-days-calculator", to: "calculators#growing_degree_days", as: :growing_degree_days
  get "tree-age-calculator", to: "calculators#tree_age", as: :tree_age
  get "greenhouse-heater-calculator", to: "calculators#greenhouse_heater", as: :greenhouse_heater
  get "compost-ratio-calculator", to: "calculators#compost_ratio", as: :compost_ratio
end
