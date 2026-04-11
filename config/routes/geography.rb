namespace :geography do
  get "coordinate-distance-calculator", to: "calculators#coordinate_distance", as: :coordinate_distance
  get "latitude-longitude-converter", to: "calculators#latitude_longitude_converter", as: :latitude_longitude_converter
  get "bearing-calculator", to: "calculators#bearing", as: :bearing
  get "midpoint-calculator", to: "calculators#midpoint", as: :midpoint
  get "map-scale-calculator", to: "calculators#map_scale", as: :map_scale
  get "population-density-calculator", to: "calculators#population_density", as: :population_density
end
