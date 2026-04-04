module CalculatorHelper
  FINANCE_CALCULATORS = [
    { name: "Mortgage Calculator", slug: "mortgage-calculator", path: :finance_mortgage_path, description: "Calculate your monthly mortgage payment, total interest, and total cost of your home loan.", icon_path: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-4 0h4" },
    { name: "Compound Interest Calculator", slug: "compound-interest-calculator", path: :finance_compound_interest_path, description: "See how your money grows over time with the power of compound interest.", icon_path: "M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" },
    { name: "Loan Calculator", slug: "loan-calculator", path: :finance_loan_path, description: "Calculate monthly payments, total interest, and payoff date for any loan.", icon_path: "M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" },
    { name: "Investment Calculator", slug: "investment-calculator", path: :finance_investment_path, description: "Project the future value of your investments with regular contributions.", icon_path: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Retirement Calculator", slug: "retirement-calculator", path: :finance_retirement_path, description: "Plan your retirement savings and estimate your monthly retirement income.", icon_path: "M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" },
    { name: "Debt Payoff Calculator", slug: "debt-payoff-calculator", path: :finance_debt_payoff_path, description: "Find out when you'll be debt-free and how much interest you'll pay.", icon_path: "M9 14l6-6m-5.5.5h.01m4.99 5h.01M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16l3.5-2 3.5 2 3.5-2 3.5 2z" },
    { name: "Salary Calculator", slug: "salary-calculator", path: :finance_salary_path, description: "Convert between hourly, daily, weekly, biweekly, monthly, and annual salary.", icon_path: "M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" },
    { name: "Savings Goal Calculator", slug: "savings-goal-calculator", path: :finance_savings_goal_path, description: "Calculate how much you need to save monthly to reach your financial goal.", icon_path: "M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" }
  ].freeze

  MATH_CALCULATORS = [
    { name: "Percentage Calculator", slug: "percentage-calculator", path: :math_percentage_path, description: "Calculate percentages, percentage change, and percentage of a number.", icon_path: "M7 20l4-16m2 16l4-16M6 9h14M4 15h14" },
    { name: "Fraction Calculator", slug: "fraction-calculator", path: :math_fraction_path, description: "Add, subtract, multiply, and divide fractions with step-by-step solutions.", icon_path: "M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" },
    { name: "Area Calculator", slug: "area-calculator", path: :math_area_path, description: "Calculate the area of common shapes including rectangles, circles, and triangles.", icon_path: "M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6z" },
    { name: "Circle Calculator", slug: "circumference-calculator", path: :math_circumference_path, description: "Calculate the circumference and area of a circle from radius or diameter.", icon_path: "M12 2a10 10 0 100 20 10 10 0 000-20z" },
    { name: "Exponent Calculator", slug: "exponent-calculator", path: :math_exponent_path, description: "Calculate the result of raising a number to any power.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" }
  ].freeze

  HEALTH_CALCULATORS = [
    { name: "BMI Calculator", slug: "bmi-calculator", path: :health_bmi_path, description: "Calculate your Body Mass Index and find out your weight category.", icon_path: "M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" },
    { name: "Calorie Calculator", slug: "calorie-calculator", path: :health_calorie_path, description: "Estimate your daily calorie needs based on your age, weight, height, and activity level.", icon_path: "M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z" },
    { name: "Body Fat Calculator", slug: "body-fat-calculator", path: :health_body_fat_path, description: "Estimate your body fat percentage using the U.S. Navy method.", icon_path: "M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" }
  ].freeze

  ALL_CATEGORIES = {
    "finance" => {
      title: "Finance Calculators",
      description: "Free financial calculators for mortgage, loans, investments, retirement planning, and more. Make smarter money decisions with accurate calculations.",
      calculators: FINANCE_CALCULATORS
    },
    "math" => {
      title: "Math Calculators",
      description: "Free math calculators for percentages, fractions, area, circumference, and exponents. Get instant answers with step-by-step solutions.",
      calculators: MATH_CALCULATORS
    },
    "health" => {
      title: "Health Calculators",
      description: "Free health calculators for BMI, calories, and body fat percentage. Track your health metrics with accurate, science-based tools.",
      calculators: HEALTH_CALCULATORS
    }
  }.freeze

  def resolve_calculator_path(calc)
    send(calc[:path])
  end

  def calculators_for_category(category_slug)
    ALL_CATEGORIES.dig(category_slug, :calculators) || []
  end

  def related_calculators(current_slug, category_slug, count: 3)
    calculators_for_category(category_slug)
      .reject { |c| c[:slug] == current_slug }
      .sample(count)
      .map { |c| c.merge(path: resolve_calculator_path(c)) }
  end
end
