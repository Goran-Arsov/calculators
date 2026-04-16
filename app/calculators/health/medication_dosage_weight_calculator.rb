# frozen_string_literal: true

module Health
  class MedicationDosageWeightCalculator
    attr_reader :errors

    # Common mg/kg dosing ranges (for educational purposes only)
    MEDICATIONS = {
      "ibuprofen" => { name: "Ibuprofen", dose_mg_per_kg: 10, max_single_mg: 400, max_daily_mg: 1200, doses_per_day: 3, notes: "Take with food. Not for children under 6 months." },
      "acetaminophen" => { name: "Acetaminophen (Paracetamol)", dose_mg_per_kg: 15, max_single_mg: 1000, max_daily_mg: 4000, doses_per_day: 4, notes: "Do not exceed daily maximum. Avoid with liver disease." },
      "amoxicillin" => { name: "Amoxicillin", dose_mg_per_kg: 25, max_single_mg: 500, max_daily_mg: 1500, doses_per_day: 3, notes: "Complete the full course as prescribed." },
      "cetirizine" => { name: "Cetirizine (Zyrtec)", dose_mg_per_kg: 0.25, max_single_mg: 10, max_daily_mg: 10, doses_per_day: 1, notes: "May cause drowsiness." },
      "diphenhydramine" => { name: "Diphenhydramine (Benadryl)", dose_mg_per_kg: 1.25, max_single_mg: 50, max_daily_mg: 300, doses_per_day: 4, notes: "Causes drowsiness. Not recommended for children under 2." },
      "custom" => { name: "Custom Medication", dose_mg_per_kg: nil, max_single_mg: nil, max_daily_mg: nil, doses_per_day: nil, notes: "Consult a healthcare provider for proper dosing." }
    }.freeze

    def initialize(weight:, weight_unit: "kg", medication: "custom", dose_mg_per_kg: nil, doses_per_day: nil, max_single_mg: nil, max_daily_mg: nil)
      @weight = weight.to_f
      @weight_unit = weight_unit.to_s
      @medication = medication.to_s
      @dose_mg_per_kg = dose_mg_per_kg&.to_f
      @doses_per_day = doses_per_day&.to_i
      @max_single_mg = max_single_mg&.to_f
      @max_daily_mg = max_daily_mg&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      weight_kg = @weight_unit == "lbs" ? @weight * 0.453592 : @weight
      med = MEDICATIONS[@medication]

      dose_rate = resolved_dose_mg_per_kg(med)
      doses_day = resolved_doses_per_day(med)
      single_max = resolved_max_single(med)
      daily_max = resolved_max_daily(med)

      calculated_single_dose = (weight_kg * dose_rate).round(1)
      capped_single_dose = single_max ? [ calculated_single_dose, single_max ].min : calculated_single_dose
      calculated_daily_total = (capped_single_dose * doses_day).round(1)
      capped_daily_total = daily_max ? [ calculated_daily_total, daily_max ].min : calculated_daily_total

      {
        valid: true,
        medication_name: med ? med[:name] : "Custom Medication",
        weight_kg: weight_kg.round(1),
        weight_lbs: (weight_kg / 0.453592).round(1),
        dose_mg_per_kg: dose_rate,
        calculated_single_dose_mg: calculated_single_dose,
        recommended_single_dose_mg: capped_single_dose,
        doses_per_day: doses_day,
        calculated_daily_total_mg: calculated_daily_total,
        recommended_daily_total_mg: capped_daily_total,
        max_single_dose_mg: single_max,
        max_daily_dose_mg: daily_max,
        capped: calculated_single_dose > (single_max || Float::INFINITY) || calculated_daily_total > (daily_max || Float::INFINITY),
        notes: med ? med[:notes] : "Consult a healthcare provider for proper dosing."
      }
    end

    private

    def resolved_dose_mg_per_kg(med)
      @dose_mg_per_kg || (med && med[:dose_mg_per_kg]) || 0
    end

    def resolved_doses_per_day(med)
      @doses_per_day || (med && med[:doses_per_day]) || 1
    end

    def resolved_max_single(med)
      @max_single_mg || (med && med[:max_single_mg])
    end

    def resolved_max_daily(med)
      @max_daily_mg || (med && med[:max_daily_mg])
    end

    def validate!
      @errors << "Weight must be positive" unless @weight > 0
      @errors << "Weight seems unrealistically high" if @weight > 500
      unless %w[kg lbs].include?(@weight_unit)
        @errors << "Weight unit must be kg or lbs"
      end
      unless MEDICATIONS.key?(@medication)
        @errors << "Unknown medication"
      end
      if @medication == "custom"
        if @dose_mg_per_kg.nil? || @dose_mg_per_kg <= 0
          @errors << "Custom dose per kg must be positive"
        end
      end
    end
  end
end
