namespace :geography do
  get "coordinate-distance-calculator", to: "calculators#coordinate_distance", as: :coordinate_distance
  get "latitude-longitude-converter", to: "calculators#latitude_longitude_converter", as: :latitude_longitude_converter
  get "bearing-calculator", to: "calculators#bearing", as: :bearing
  get "midpoint-calculator", to: "calculators#midpoint", as: :midpoint
  get "map-scale-calculator", to: "calculators#map_scale", as: :map_scale
  get "population-density-calculator", to: "calculators#population_density", as: :population_density
  get "destination-point-calculator", to: "calculators#destination_point", as: :destination_point
  get "antipode-calculator", to: "calculators#antipode", as: :antipode
  get "rhumb-line-calculator", to: "calculators#rhumb_line", as: :rhumb_line
  get "polygon-area-calculator", to: "calculators#polygon_area", as: :polygon_area
  get "hiking-time-calculator", to: "calculators#hiking_time", as: :hiking_time
  get "geohash-converter", to: "calculators#geohash", as: :geohash
  get "degrees-to-kilometers-converter", to: "calculators#degrees_to_kilometers", as: :degrees_to_kilometers
  get "flight-time-calculator", to: "calculators#flight_time", as: :flight_time
end
