# frozen_string_literal: true

module Pets
  class PetInsuranceRoiCalculator
    attr_reader :errors

    VALID_PET_TYPES = %w[dog cat].freeze
    VALID_BREED_SIZES = %w[small medium large giant].freeze

    # Average annual vet costs by pet type and breed size (routine + emergency averaged)
    ANNUAL_VET_COSTS = {
      "dog" => { "small" => 800, "medium" => 1000, "large" => 1200, "giant" => 1500 },
      "cat" => { "small" => 600, "medium" => 700, "large" => 800, "giant" => 800 }
    }.freeze

    # Probability of a major health event per year (increases with age)
    BASE_EMERGENCY_PROBABILITY = 0.15
    AGE_RISK_INCREMENT = 0.02

    # Average cost of a major health event
    MAJOR_EVENT_COSTS = {
      "dog" => { "small" => 3000, "medium" => 4000, "large" => 5000, "giant" => 6000 },
      "cat" => { "small" => 2500, "medium" => 3000, "large" => 3500, "giant" => 3500 }
    }.freeze

    def initialize(pet_type:, breed_size: "medium", pet_age:, expected_lifespan:, monthly_premium:, annual_deductible:, reimbursement_rate: 80)
      @pet_type = pet_type.to_s
      @breed_size = breed_size.to_s
      @pet_age = pet_age.to_i
      @expected_lifespan = expected_lifespan.to_i
      @monthly_premium = monthly_premium.to_f
      @annual_deductible = annual_deductible.to_f
      @reimbursement_rate = reimbursement_rate.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      remaining_years = @expected_lifespan - @pet_age
      total_premiums = @monthly_premium * 12 * remaining_years
      total_deductibles = @annual_deductible * remaining_years

      estimated_vet_bills = calculate_lifetime_vet_costs(remaining_years)
      estimated_emergencies = calculate_emergency_costs(remaining_years)
      total_estimated_costs = estimated_vet_bills + estimated_emergencies

      insurance_payouts = calculate_insurance_payouts(estimated_vet_bills, estimated_emergencies, remaining_years)
      total_insurance_cost = total_premiums + total_deductibles
      net_savings = insurance_payouts - total_insurance_cost
      roi_percentage = total_insurance_cost > 0 ? ((insurance_payouts - total_insurance_cost) / total_insurance_cost * 100) : 0

      {
        valid: true,
        pet_type: @pet_type,
        breed_size: @breed_size,
        remaining_years: remaining_years,
        total_premiums: total_premiums.round(0),
        total_deductibles: total_deductibles.round(0),
        total_insurance_cost: total_insurance_cost.round(0),
        estimated_vet_bills: estimated_vet_bills.round(0),
        estimated_emergencies: estimated_emergencies.round(0),
        total_estimated_costs: total_estimated_costs.round(0),
        insurance_payouts: insurance_payouts.round(0),
        net_savings: net_savings.round(0),
        roi_percentage: roi_percentage.round(1),
        recommendation: net_savings > 0 ? "Insurance likely saves money" : "Insurance may not be cost-effective"
      }
    end

    private

    def calculate_lifetime_vet_costs(remaining_years)
      annual_cost = ANNUAL_VET_COSTS[@pet_type][@breed_size]
      # Costs increase ~5% per year as pet ages
      total = 0.0
      remaining_years.times do |year|
        age_at_year = @pet_age + year
        age_factor = 1.0 + (age_at_year * 0.05)
        total += annual_cost * age_factor
      end
      total
    end

    def calculate_emergency_costs(remaining_years)
      event_cost = MAJOR_EVENT_COSTS[@pet_type][@breed_size]
      total = 0.0
      remaining_years.times do |year|
        age_at_year = @pet_age + year
        probability = BASE_EMERGENCY_PROBABILITY + (age_at_year * AGE_RISK_INCREMENT)
        probability = [ probability, 0.6 ].min
        total += event_cost * probability
      end
      total
    end

    def calculate_insurance_payouts(vet_bills, emergencies, remaining_years)
      total_claims = vet_bills + emergencies
      # Insurance only covers amounts above deductible
      total_above_deductible = [ total_claims - (@annual_deductible * remaining_years), 0 ].max
      total_above_deductible * @reimbursement_rate
    end

    def validate!
      @errors << "Pet type must be dog or cat" unless VALID_PET_TYPES.include?(@pet_type)
      @errors << "Breed size must be #{VALID_BREED_SIZES.join(', ')}" unless VALID_BREED_SIZES.include?(@breed_size)
      @errors << "Pet age must be 0 or older" unless @pet_age >= 0
      @errors << "Expected lifespan must be positive" unless @expected_lifespan > 0
      @errors << "Pet age must be less than expected lifespan" unless @pet_age < @expected_lifespan
      @errors << "Monthly premium must be positive" unless @monthly_premium > 0
      @errors << "Annual deductible cannot be negative" if @annual_deductible < 0
      @errors << "Reimbursement rate must be between 1 and 100" unless @reimbursement_rate > 0 && @reimbursement_rate <= 1
    end
  end
end
