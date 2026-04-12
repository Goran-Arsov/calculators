# frozen_string_literal: true

module Pets
  class PetMedicationDosageCalculator
    attr_reader :errors

    VALID_PET_TYPES = %w[dog cat].freeze
    LBS_TO_KG = 0.453592

    # Common pet medications with dosage ranges in mg/kg
    # Source: veterinary pharmacology references
    MEDICATIONS = {
      "benadryl" => {
        name: "Benadryl (Diphenhydramine)",
        dog: { min_mg_per_kg: 2.0, max_mg_per_kg: 4.0, frequency: "Every 8-12 hours" },
        cat: { min_mg_per_kg: 1.0, max_mg_per_kg: 2.0, frequency: "Every 8-12 hours" }
      },
      "pepcid" => {
        name: "Pepcid (Famotidine)",
        dog: { min_mg_per_kg: 0.5, max_mg_per_kg: 1.0, frequency: "Every 12-24 hours" },
        cat: { min_mg_per_kg: 0.5, max_mg_per_kg: 1.0, frequency: "Every 12-24 hours" }
      },
      "bayer_aspirin" => {
        name: "Aspirin (Buffered)",
        dog: { min_mg_per_kg: 10.0, max_mg_per_kg: 20.0, frequency: "Every 12 hours" },
        cat: { min_mg_per_kg: 6.0, max_mg_per_kg: 10.0, frequency: "Every 48-72 hours" }
      },
      "glucosamine" => {
        name: "Glucosamine",
        dog: { min_mg_per_kg: 20.0, max_mg_per_kg: 25.0, frequency: "Once daily" },
        cat: { min_mg_per_kg: 10.0, max_mg_per_kg: 15.0, frequency: "Once daily" }
      },
      "fish_oil" => {
        name: "Fish Oil (EPA + DHA)",
        dog: { min_mg_per_kg: 50.0, max_mg_per_kg: 75.0, frequency: "Once daily" },
        cat: { min_mg_per_kg: 30.0, max_mg_per_kg: 50.0, frequency: "Once daily" }
      },
      "melatonin" => {
        name: "Melatonin",
        dog: { min_mg_per_kg: 0.05, max_mg_per_kg: 0.1, frequency: "Every 8-12 hours" },
        cat: { min_mg_per_kg: 0.05, max_mg_per_kg: 0.1, frequency: "Every 8-12 hours" }
      },
      "probiotics" => {
        name: "Probiotics",
        dog: { min_mg_per_kg: 1.0, max_mg_per_kg: 5.0, frequency: "Once daily" },
        cat: { min_mg_per_kg: 1.0, max_mg_per_kg: 3.0, frequency: "Once daily" }
      }
    }.freeze

    def initialize(pet_type:, weight_lbs:, medication:)
      @pet_type = pet_type.to_s
      @weight_lbs = weight_lbs.to_f
      @medication = medication.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      weight_kg = @weight_lbs * LBS_TO_KG
      med_info = MEDICATIONS[@medication]
      dosage_info = med_info[@pet_type.to_sym]

      min_dose_mg = weight_kg * dosage_info[:min_mg_per_kg]
      max_dose_mg = weight_kg * dosage_info[:max_mg_per_kg]

      {
        valid: true,
        pet_type: @pet_type,
        weight_lbs: @weight_lbs,
        weight_kg: weight_kg.round(1),
        medication_name: med_info[:name],
        medication_key: @medication,
        min_dose_mg: min_dose_mg.round(1),
        max_dose_mg: max_dose_mg.round(1),
        min_mg_per_kg: dosage_info[:min_mg_per_kg],
        max_mg_per_kg: dosage_info[:max_mg_per_kg],
        frequency: dosage_info[:frequency]
      }
    end

    private

    def validate!
      @errors << "Pet type must be dog or cat" unless VALID_PET_TYPES.include?(@pet_type)
      @errors << "Weight must be positive" unless @weight_lbs > 0
      @errors << "Weight must be realistic (up to 250 lbs)" if @weight_lbs > 250
      @errors << "Medication not recognized" unless MEDICATIONS.key?(@medication)
    end
  end
end
