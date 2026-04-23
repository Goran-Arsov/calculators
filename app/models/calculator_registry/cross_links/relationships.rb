# frozen_string_literal: true

class CalculatorRegistry
  module CrossLinks
    RELATIONSHIPS = {
      "love-compatibility-calculator" => %w[zodiac-compatibility-calculator flames-calculator age-gap-calculator],
      "zodiac-compatibility-calculator" => %w[love-compatibility-calculator flames-calculator age-gap-calculator],
      "age-gap-calculator" => %w[half-your-age-plus-seven-calculator love-compatibility-calculator dating-duration-calculator],
      "when-will-i-meet-someone-calculator" => %w[dating-pool-calculator love-compatibility-calculator zodiac-compatibility-calculator],
      "flames-calculator" => %w[love-compatibility-calculator zodiac-compatibility-calculator age-gap-calculator],
      "wedding-budget-planner-calculator" => %w[wedding-cost-splitter honeymoon-savings-calculator engagement-ring-budget-calculator],
      "wedding-cost-splitter" => %w[wedding-budget-planner-calculator honeymoon-savings-calculator split-bill-calculator],
      "honeymoon-savings-calculator" => %w[wedding-budget-planner-calculator travel-budget-calculator savings-goal-calculator],
      "engagement-ring-budget-calculator" => %w[wedding-budget-planner-calculator honeymoon-savings-calculator savings-goal-calculator],
      "cost-of-raising-a-child-calculator" => %w[pet-cost-calculator pregnancy-calorie-calculator child-support-calculator],
      "date-night-budget-calculator" => %w[split-bill-calculator restaurant-tip-calculator travel-budget-calculator],
      "anniversary-calculator" => %w[age-calculator date-difference-calculator days-until-wedding-calculator],
      "dating-duration-calculator" => %w[anniversary-calculator age-gap-calculator relationship-milestone-calculator],
      "days-until-wedding-calculator" => %w[wedding-budget-planner-calculator anniversary-calculator dating-duration-calculator],
      "relationship-milestone-calculator" => %w[dating-duration-calculator anniversary-calculator age-gap-calculator],
      "breakup-recovery-calculator" => %w[dating-duration-calculator date-difference-calculator age-gap-calculator],
      "divorce-cost-calculator" => %w[alimony-calculator child-support-calculator cost-of-raising-a-child-calculator],
      "alimony-calculator" => %w[divorce-cost-calculator child-support-calculator cost-of-raising-a-child-calculator],
      "child-support-calculator" => %w[alimony-calculator divorce-cost-calculator cost-of-raising-a-child-calculator],
      "dating-pool-calculator" => %w[when-will-i-meet-someone-calculator love-compatibility-calculator age-gap-calculator],
      "half-your-age-plus-seven-calculator" => %w[age-gap-calculator love-compatibility-calculator dating-duration-calculator],
      "online-dating-roi-calculator" => %w[dating-pool-calculator when-will-i-meet-someone-calculator roi-calculator]
    }.freeze
  end
end
