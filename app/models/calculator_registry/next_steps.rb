# frozen_string_literal: true

class CalculatorRegistry
  # Calculator funnels — ordered "What's Next?" suggestions per calculator
  NEXT_STEPS = {
    # Finance flows
    "mortgage-calculator" => [
      { slug: "amortization-calculator", label: "See your full amortization schedule" },
      { slug: "home-affordability-calculator", label: "Check how much house you can afford" },
      { slug: "401k-calculator", label: "Plan your retirement savings" }
    ],
    "home-affordability-calculator" => [
      { slug: "mortgage-calculator", label: "Calculate your mortgage payment" },
      { slug: "rent-vs-buy-calculator", label: "Compare renting vs buying" },
      { slug: "savings-goal-calculator", label: "Plan your down payment savings" }
    ],
    "loan-calculator" => [
      { slug: "debt-payoff-calculator", label: "Plan your debt payoff strategy" },
      { slug: "amortization-calculator", label: "View your amortization schedule" },
      { slug: "credit-card-payoff-calculator", label: "Pay off credit card debt" }
    ],
    "investment-calculator" => [
      { slug: "compound-interest-calculator", label: "Explore compound interest scenarios" },
      { slug: "retirement-calculator", label: "Plan your retirement" },
      { slug: "roi-calculator", label: "Calculate your return on investment" }
    ],
    "retirement-calculator" => [
      { slug: "401k-calculator", label: "Optimize your 401(k) contributions" },
      { slug: "savings-goal-calculator", label: "Set a savings target" },
      { slug: "inflation-calculator", label: "Account for inflation" }
    ],
    "compound-interest-calculator" => [
      { slug: "investment-calculator", label: "Project your investment growth" },
      { slug: "savings-interest-calculator", label: "Calculate savings interest" },
      { slug: "cd-calculator", label: "Compare CD rates" }
    ],
    "salary-calculator" => [
      { slug: "paycheck-calculator", label: "See your take-home pay" },
      { slug: "tax-bracket-calculator", label: "Find your tax bracket" },
      { slug: "savings-goal-calculator", label: "Plan your savings" }
    ],
    # Health flows
    "bmi-calculator" => [
      { slug: "body-fat-calculator", label: "Get a more detailed body composition" },
      { slug: "calorie-calculator", label: "Calculate your daily calorie needs" },
      { slug: "tdee-calculator", label: "Find your total daily energy expenditure" }
    ],
    "calorie-calculator" => [
      { slug: "macro-calculator", label: "Calculate your macro split" },
      { slug: "tdee-calculator", label: "Find your TDEE" },
      { slug: "water-intake-calculator", label: "Calculate your water needs" }
    ],
    "body-fat-calculator" => [
      { slug: "bmi-calculator", label: "Check your BMI" },
      { slug: "lean-body-mass-calculator", label: "Calculate lean body mass" },
      { slug: "ideal-weight-calculator", label: "Find your ideal weight" }
    ],
    "tdee-calculator" => [
      { slug: "calorie-calculator", label: "Calculate daily calories" },
      { slug: "macro-calculator", label: "Get your macro breakdown" },
      { slug: "one-rep-max-calculator", label: "Find your one-rep max" }
    ],
    # Math flows
    "percentage-calculator" => [
      { slug: "fraction-calculator", label: "Convert to fractions" },
      { slug: "profit-margin-calculator", label: "Calculate profit margins" }
    ],
    # Construction flows
    "concrete-calculator" => [
      { slug: "gravel-mulch-calculator", label: "Calculate gravel for your base" },
      { slug: "flooring-calculator", label: "Estimate flooring material needs" }
    ],
    "paint-calculator" => [
      { slug: "wallpaper-calculator", label: "Compare with wallpaper quantities" },
      { slug: "flooring-calculator", label: "Calculate flooring material needs" }
    ]
  }.freeze
end
