# frozen_string_literal: true

module Health
  module Constants
    ACTIVITY_MULTIPLIERS = {
      "sedentary" => 1.2,
      "light" => 1.375,
      "moderate" => 1.55,
      "active" => 1.725,
      "very_active" => 1.9
    }.freeze

    ACTIVITY_LEVELS = {
      "sedentary" => { multiplier: 1.2, label: "Sedentary (little or no exercise)" },
      "light" => { multiplier: 1.375, label: "Lightly active (1-3 days/week)" },
      "moderate" => { multiplier: 1.55, label: "Moderately active (3-5 days/week)" },
      "active" => { multiplier: 1.725, label: "Very active (6-7 days/week)" },
      "very_active" => { multiplier: 1.9, label: "Extra active (very hard exercise/physical job)" }
    }.freeze
  end
end
