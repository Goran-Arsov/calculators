# frozen_string_literal: true

module Construction
  class WoodWeightCalculator
    SPECIES_DENSITY = {
      "red_oak" =>    { name: "Red Oak",           density_lb_ft3: 44.0 },
      "white_oak" =>  { name: "White Oak",         density_lb_ft3: 47.0 },
      "hard_maple" => { name: "Hard Maple",        density_lb_ft3: 44.0 },
      "soft_maple" => { name: "Soft Maple (Red)",  density_lb_ft3: 38.0 },
      "black_walnut" => { name: "Black Walnut",    density_lb_ft3: 38.0 },
      "cherry" =>     { name: "Black Cherry",      density_lb_ft3: 35.0 },
      "white_ash" =>  { name: "White Ash",         density_lb_ft3: 41.0 },
      "mahogany" =>   { name: "Mahogany (Genuine)", density_lb_ft3: 31.0 },
      "poplar" =>     { name: "Yellow Poplar",     density_lb_ft3: 29.0 },
      "eastern_white_pine" => { name: "Eastern White Pine", density_lb_ft3: 25.0 },
      "douglas_fir" => { name: "Douglas Fir",      density_lb_ft3: 32.0 },
      "yellow_birch" => { name: "Yellow Birch",    density_lb_ft3: 43.0 },
      "teak" =>       { name: "Teak",              density_lb_ft3: 41.0 },
      "hickory" =>    { name: "Hickory",           density_lb_ft3: 51.0 },
      "beech" =>      { name: "American Beech",    density_lb_ft3: 45.0 },
      "red_cedar" =>  { name: "Western Red Cedar", density_lb_ft3: 23.0 },
      "spanish_cedar" => { name: "Spanish Cedar",  density_lb_ft3: 30.0 },
      "sapele" =>     { name: "Sapele",            density_lb_ft3: 42.0 },
      "ipe" =>        { name: "Ipe",               density_lb_ft3: 69.0 },
      "purpleheart" => { name: "Purpleheart",      density_lb_ft3: 56.0 }
    }.freeze

    LB_TO_KG = 0.453592
    FT3_TO_M3 = 0.0283168
    LB_FT3_TO_KG_M3 = 16.0185

    attr_reader :errors

    def initialize(species:, thickness_in:, width_in:, length_ft:, quantity: 1)
      @species = species.to_s
      @thickness_in = thickness_in.to_f
      @width_in = width_in.to_f
      @length_ft = length_ft.to_f
      @quantity = quantity.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      species_data = SPECIES_DENSITY[@species]
      density_lb_ft3 = species_data[:density_lb_ft3]
      density_kg_m3 = density_lb_ft3 * LB_FT3_TO_KG_M3

      volume_ft3_per_piece = (@thickness_in * @width_in * (@length_ft * 12.0)) / 1728.0
      weight_lb_per_piece = volume_ft3_per_piece * density_lb_ft3

      total_volume_ft3 = volume_ft3_per_piece * @quantity
      total_volume_m3 = total_volume_ft3 * FT3_TO_M3
      total_weight_lb = weight_lb_per_piece * @quantity
      total_weight_kg = total_weight_lb * LB_TO_KG

      {
        valid: true,
        species_name: species_data[:name],
        density_lb_ft3: density_lb_ft3,
        density_kg_m3: density_kg_m3.round(2),
        volume_ft3_per_piece: volume_ft3_per_piece.round(4),
        weight_lb_per_piece: weight_lb_per_piece.round(2),
        total_volume_ft3: total_volume_ft3.round(4),
        total_volume_m3: total_volume_m3.round(4),
        total_weight_lb: total_weight_lb.round(2),
        total_weight_kg: total_weight_kg.round(2)
      }
    end

    private

    def validate!
      @errors << "Unknown species" unless SPECIES_DENSITY.key?(@species)
      @errors << "Thickness must be greater than zero" unless @thickness_in.positive?
      @errors << "Width must be greater than zero" unless @width_in.positive?
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Quantity must be at least 1" unless @quantity >= 1
    end
  end
end
