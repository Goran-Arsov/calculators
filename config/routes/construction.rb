namespace :construction do
  get "paint-calculator", to: "calculators#paint", as: :paint
  get "flooring-calculator", to: "calculators#flooring", as: :flooring
  get "concrete-calculator", to: "calculators#concrete", as: :concrete
  get "gravel-mulch-calculator", to: "calculators#gravel_mulch", as: :gravel_mulch
  get "fence-calculator", to: "calculators#fence", as: :fence
  get "roofing-calculator", to: "calculators#roofing", as: :roofing
  get "staircase-calculator", to: "calculators#staircase", as: :staircase
  get "deck-calculator", to: "calculators#deck", as: :deck
  get "wallpaper-calculator", to: "calculators#wallpaper", as: :wallpaper
  get "tile-calculator", to: "calculators#tile", as: :tile
  get "lumber-calculator", to: "calculators#lumber", as: :lumber
  get "hvac-btu-calculator", to: "calculators#hvac_btu", as: :hvac_btu
  get "sqft-cost-calculator", to: "calculators#sqft_cost", as: :sqft_cost
  get "price-per-sqm-calculator", to: "calculators#price_per_sqm", as: :price_per_sqm
  get "drywall-calculator", to: "calculators#drywall", as: :drywall
  get "insulation-calculator", to: "calculators#insulation", as: :insulation
  get "plumbing-calculator", to: "calculators#plumbing", as: :plumbing
  get "electrical-load-calculator", to: "calculators#electrical_load", as: :electrical_load
  get "retaining-wall-calculator", to: "calculators#retaining_wall", as: :retaining_wall
end
