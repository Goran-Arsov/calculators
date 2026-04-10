# frozen_string_literal: true

module Construction
  class WoodShrinkageCalculator
    SPECIES = {
      "red_oak" =>    { name: "Red Oak",           tangential: 8.6, radial: 4.0 },
      "white_oak" =>  { name: "White Oak",         tangential: 10.5, radial: 5.6 },
      "hard_maple" => { name: "Hard Maple",        tangential: 9.9, radial: 4.8 },
      "soft_maple" => { name: "Soft Maple (Red)",  tangential: 8.2, radial: 4.0 },
      "black_walnut" => { name: "Black Walnut",    tangential: 7.8, radial: 5.5 },
      "cherry" =>     { name: "Black Cherry",      tangential: 7.1, radial: 3.7 },
      "white_ash" =>  { name: "White Ash",         tangential: 7.8, radial: 4.9 },
      "mahogany" =>   { name: "Mahogany (Genuine)", tangential: 4.1, radial: 3.0 },
      "poplar" =>     { name: "Yellow Poplar",     tangential: 8.2, radial: 4.6 },
      "eastern_white_pine" => { name: "Eastern White Pine", tangential: 6.1, radial: 2.1 },
      "douglas_fir" => { name: "Douglas Fir",      tangential: 7.6, radial: 4.8 },
      "yellow_birch" => { name: "Yellow Birch",    tangential: 9.5, radial: 7.3 },
      "teak" =>       { name: "Teak",              tangential: 4.0, radial: 2.5 },
      "hickory" =>    { name: "Hickory",           tangential: 11.5, radial: 7.0 },
      "beech" =>      { name: "American Beech",    tangential: 11.9, radial: 5.5 }
    }.freeze

    FIBER_SATURATION_POINT = 30.0

    attr_reader :errors

    def initialize(species:, direction:, initial_dimension:, initial_mc:, final_mc:)
      @species = species.to_s
      @direction = direction.to_s
      @initial_dimension = initial_dimension.to_f
      @initial_mc = initial_mc.to_f
      @final_mc = final_mc.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      species_data = SPECIES[@species]
      shrinkage_coefficient = species_data[@direction.to_sym]

      effective_initial = [@initial_mc, FIBER_SATURATION_POINT].min
      effective_final = [@final_mc, FIBER_SATURATION_POINT].min
      mc_change = effective_initial - effective_final

      shrinkage_fraction = (shrinkage_coefficient / 100.0) * (mc_change / FIBER_SATURATION_POINT)
      dimension_change = @initial_dimension * shrinkage_fraction
      final_dimension = @initial_dimension - dimension_change

      {
        valid: true,
        species_name: species_data[:name],
        direction: @direction,
        initial_dimension: @initial_dimension,
        final_dimension: final_dimension.round(4),
        dimension_change: dimension_change.round(4),
        shrinkage_percent: (shrinkage_fraction * 100).round(3),
        initial_mc: @initial_mc,
        final_mc: @final_mc
      }
    end

    private

    def validate!
      @errors << "Unknown species" unless SPECIES.key?(@species)
      @errors << "Direction must be tangential or radial" unless %w[tangential radial].include?(@direction)
      @errors << "Initial dimension must be greater than zero" unless @initial_dimension.positive?
      @errors << "Initial moisture content must be between 0 and 100" unless @initial_mc >= 0 && @initial_mc <= 100
      @errors << "Final moisture content must be between 0 and 100" unless @final_mc >= 0 && @final_mc <= 100
      if @errors.empty? && @final_mc > @initial_mc
        @errors << "Final moisture content must be less than or equal to initial"
      end
    end
  end
end
