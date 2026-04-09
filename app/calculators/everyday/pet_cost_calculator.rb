# frozen_string_literal: true

module Everyday
  class PetCostCalculator
    attr_reader :errors

    ANNUAL_COSTS = {
      "dog_small"  => { food: 360, vet: 400, grooming: 200, insurance: 240, supplies: 150 },
      "dog_medium" => { food: 540, vet: 500, grooming: 280, insurance: 240, supplies: 140 },
      "dog_large"  => { food: 780, vet: 600, grooming: 320, insurance: 240, supplies: 160 },
      "cat"        => { food: 300, vet: 350, litter: 200, insurance: 200, supplies: 100 }
    }.freeze

    ANNUAL_TOTALS = {
      "dog_small"  => 1350,
      "dog_medium" => 1700,
      "dog_large"  => 2100,
      "cat"        => 1150
    }.freeze

    FIRST_YEAR_ADDON = 500

    def initialize(pet_type:, size: nil, ownership_years:)
      @pet_type = pet_type.to_s.downcase
      @size = size.to_s.downcase
      @ownership_years = ownership_years.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      key = cost_key
      annual_cost = ANNUAL_TOTALS[key].to_f
      first_year_cost = annual_cost + FIRST_YEAR_ADDON
      lifetime_cost = if @ownership_years >= 2
                        first_year_cost + (annual_cost * (@ownership_years - 1))
      else
                        first_year_cost
      end

      costs = ANNUAL_COSTS[key]
      food_annual = costs[:food].to_f
      vet_annual = costs[:vet].to_f
      other_annual = annual_cost - food_annual - vet_annual

      {
        valid: true,
        first_year_cost: first_year_cost.round(2),
        annual_cost: annual_cost.round(2),
        lifetime_cost: lifetime_cost.round(2),
        food_annual: food_annual.round(2),
        vet_annual: vet_annual.round(2),
        other_annual: other_annual.round(2)
      }
    end

    private

    def cost_key
      if @pet_type == "dog"
        "dog_#{@size}"
      else
        "cat"
      end
    end

    def validate!
      @errors << "Pet type must be dog or cat" unless %w[dog cat].include?(@pet_type)
      if @pet_type == "dog"
        @errors << "Dog size must be small, medium, or large" unless %w[small medium large].include?(@size)
      end
      @errors << "Ownership years must be at least 1" unless @ownership_years >= 1
    end
  end
end
