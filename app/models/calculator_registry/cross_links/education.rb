# frozen_string_literal: true

class CalculatorRegistry
  module CrossLinks
    EDUCATION = {
      "student-loan-forgiveness-calculator" => %w[student-loan-calculator college-cost-comparison-calculator tuition-savings-529-calculator],
      "college-cost-comparison-calculator" => %w[student-loan-calculator tuition-savings-529-calculator scholarship-roi-calculator],
      "scholarship-roi-calculator" => %w[roi-calculator college-cost-comparison-calculator student-loan-calculator],
      "class-schedule-builder" => %w[gpa-calculator study-time-calculator work-hours-calculator],
      "research-paper-word-count-estimator" => %w[word-counter words-per-minute-calculator character-counter],
      "credit-transfer-calculator" => %w[gpa-calculator college-cost-comparison-calculator final-grade-calculator],
      "tuition-savings-529-calculator" => %w[college-cost-comparison-calculator student-loan-calculator savings-goal-calculator]
    }.freeze
  end
end
