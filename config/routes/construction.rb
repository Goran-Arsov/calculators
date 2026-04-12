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

  # Woodworking
  get "miter-angle-calculator", to: "calculators#miter_angle", as: :miter_angle
  get "wood-moisture-calculator", to: "calculators#wood_moisture", as: :wood_moisture
  get "wood-shrinkage-calculator", to: "calculators#wood_shrinkage", as: :wood_shrinkage
  get "wood-weight-calculator", to: "calculators#wood_weight", as: :wood_weight
  get "rip-cut-calculator", to: "calculators#rip_cut", as: :rip_cut
  get "cabinet-door-calculator", to: "calculators#cabinet_door", as: :cabinet_door

  # Home improvement
  get "grout-calculator", to: "calculators#grout", as: :grout
  get "carpet-calculator", to: "calculators#carpet", as: :carpet
  get "baseboard-calculator", to: "calculators#baseboard", as: :baseboard
  get "siding-calculator", to: "calculators#siding", as: :siding
  get "gutter-calculator", to: "calculators#gutter", as: :gutter
  get "water-heater-sizing-calculator", to: "calculators#water_heater_sizing", as: :water_heater_sizing
  get "pool-volume-calculator", to: "calculators#pool_volume", as: :pool_volume
  get "kitchen-remodel-cost-calculator", to: "calculators#kitchen_remodel", as: :kitchen_remodel
  get "bathroom-remodel-cost-calculator", to: "calculators#bathroom_remodel", as: :bathroom_remodel
  get "attic-ventilation-calculator", to: "calculators#attic_ventilation", as: :attic_ventilation

  # Structural & specialty
  get "solar-panel-layout-calculator", to: "calculators#solar_panel_layout", as: :solar_panel_layout
  get "rebar-spacing-calculator", to: "calculators#rebar_spacing", as: :rebar_spacing
  get "concrete-mix-calculator", to: "calculators#concrete_mix", as: :concrete_mix
  get "beam-load-span-calculator", to: "calculators#beam_load_span", as: :beam_load_span
  get "window-u-value-calculator", to: "calculators#window_u_value", as: :window_u_value
  get "drainage-slope-calculator", to: "calculators#drainage_slope", as: :drainage_slope
  get "brick-block-calculator", to: "calculators#brick_block", as: :brick_block
  get "septic-tank-size-calculator", to: "calculators#septic_tank_size", as: :septic_tank_size
end
