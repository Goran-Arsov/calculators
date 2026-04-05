Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Finance calculators
  namespace :finance do
    get "mortgage-calculator", to: "calculators#mortgage", as: :mortgage
    get "compound-interest-calculator", to: "calculators#compound_interest", as: :compound_interest
    get "loan-calculator", to: "calculators#loan", as: :loan
    get "investment-calculator", to: "calculators#investment", as: :investment
    get "retirement-calculator", to: "calculators#retirement", as: :retirement
    get "debt-payoff-calculator", to: "calculators#debt_payoff", as: :debt_payoff
    get "salary-calculator", to: "calculators#salary", as: :salary
    get "savings-goal-calculator", to: "calculators#savings_goal", as: :savings_goal
    get "roi-calculator", to: "calculators#roi", as: :roi
    get "profit-margin-calculator", to: "calculators#profit_margin", as: :profit_margin
    get "inflation-calculator", to: "calculators#inflation", as: :inflation
    get "break-even-calculator", to: "calculators#break_even", as: :break_even
    get "markup-margin-calculator", to: "calculators#markup_margin", as: :markup_margin
    get "rent-vs-buy-calculator", to: "calculators#rent_vs_buy", as: :rent_vs_buy
    get "dividend-yield-calculator", to: "calculators#dividend_yield", as: :dividend_yield
    get "dca-calculator", to: "calculators#dca", as: :dca
    get "solar-savings-calculator", to: "calculators#solar_savings", as: :solar_savings
    get "tax-bracket-calculator", to: "calculators#tax_bracket", as: :tax_bracket
    get "auto-loan-calculator", to: "calculators#auto_loan", as: :auto_loan
    get "credit-card-payoff-calculator", to: "calculators#credit_card_payoff", as: :credit_card_payoff
    get "net-worth-calculator", to: "calculators#net_worth", as: :net_worth
    get "home-affordability-calculator", to: "calculators#home_affordability", as: :home_affordability
    get "business-loan-calculator", to: "calculators#business_loan", as: :business_loan
    get "currency-converter", to: "calculators#currency_converter", as: :currency_converter
    get "paycheck-calculator", to: "calculators#paycheck", as: :paycheck
    get "401k-calculator", to: "calculators#four_oh_one_k", as: :four_oh_one_k
    get "amortization-calculator", to: "calculators#amortization", as: :amortization
    get "stock-profit-calculator", to: "calculators#stock_profit", as: :stock_profit
    get "cd-calculator", to: "calculators#cd", as: :cd
    get "savings-interest-calculator", to: "calculators#savings_interest", as: :savings_interest
    get "house-flip-calculator", to: "calculators#house_flip", as: :house_flip
    get "student-loan-calculator", to: "calculators#student_loan", as: :student_loan
    get "estate-tax-calculator", to: "calculators#estate_tax", as: :estate_tax
    get "crypto-profit-calculator", to: "calculators#crypto_profit", as: :crypto_profit
  end

  # Math calculators
  namespace :math do
    get "percentage-calculator", to: "calculators#percentage", as: :percentage
    get "fraction-calculator", to: "calculators#fraction", as: :fraction
    get "area-calculator", to: "calculators#area", as: :area
    get "circumference-calculator", to: "calculators#circumference", as: :circumference
    get "exponent-calculator", to: "calculators#exponent", as: :exponent
    get "pythagorean-theorem-calculator", to: "calculators#pythagorean", as: :pythagorean
    get "quadratic-equation-calculator", to: "calculators#quadratic", as: :quadratic
    get "standard-deviation-calculator", to: "calculators#standard_deviation", as: :standard_deviation
    get "gcd-lcm-calculator", to: "calculators#gcd_lcm", as: :gcd_lcm
    get "sample-size-calculator", to: "calculators#sample_size", as: :sample_size
    get "aspect-ratio-calculator", to: "calculators#aspect_ratio", as: :aspect_ratio
    get "matrix-calculator", to: "calculators#matrix", as: :matrix
    get "logarithm-calculator", to: "calculators#logarithm", as: :logarithm
    get "probability-calculator", to: "calculators#probability", as: :probability
    get "permutation-combination-calculator", to: "calculators#permutation_combination", as: :permutation_combination
    get "mean-median-mode-calculator", to: "calculators#mean_median_mode", as: :mean_median_mode
    get "base-converter", to: "calculators#base_converter", as: :base_converter
    get "significant-figures-calculator", to: "calculators#sig_figs", as: :sig_figs
    get "scientific-notation-calculator", to: "calculators#scientific_notation", as: :scientific_notation
  end

  # Physics calculators
  namespace :physics do
    get "velocity-calculator", to: "calculators#velocity", as: :velocity
    get "force-calculator", to: "calculators#force", as: :force
    get "kinetic-energy-calculator", to: "calculators#kinetic_energy", as: :kinetic_energy
    get "ohms-law-calculator", to: "calculators#ohms_law", as: :ohms_law
    get "projectile-motion-calculator", to: "calculators#projectile_motion", as: :projectile_motion
    get "element-mass-calculator", to: "calculators#element_mass", as: :element_mass
    get "element-volume-calculator", to: "calculators#element_volume", as: :element_volume
    get "unit-converter", to: "calculators#unit_converter", as: :unit_converter
    get "electricity-cost-calculator", to: "calculators#electricity_cost", as: :electricity_cost
    get "wire-gauge-calculator", to: "calculators#wire_gauge", as: :wire_gauge
    get "decibel-calculator", to: "calculators#decibel", as: :decibel
    get "wavelength-frequency-calculator", to: "calculators#wavelength_frequency", as: :wavelength_frequency
    get "planet-weight-calculator", to: "calculators#planet_weight", as: :planet_weight
    get "resistor-color-code-calculator", to: "calculators#resistor_color_code", as: :resistor_color_code
    get "gear-ratio-calculator", to: "calculators#gear_ratio", as: :gear_ratio
    get "pressure-converter", to: "calculators#pressure_converter", as: :pressure_converter
    get "heat-transfer-calculator", to: "calculators#heat_transfer", as: :heat_transfer
    get "spring-constant-calculator", to: "calculators#spring_constant", as: :spring_constant
  end

  # Health calculators
  namespace :health do
    get "bmi-calculator", to: "calculators#bmi", as: :bmi
    get "calorie-calculator", to: "calculators#calorie", as: :calorie
    get "body-fat-calculator", to: "calculators#body_fat", as: :body_fat
    get "pregnancy-due-date-calculator", to: "calculators#pregnancy_due_date", as: :pregnancy_due_date
    get "tdee-calculator", to: "calculators#tdee", as: :tdee
    get "macro-calculator", to: "calculators#macro", as: :macro
    get "pace-calculator", to: "calculators#pace", as: :pace
    get "water-intake-calculator", to: "calculators#water_intake", as: :water_intake
    get "sleep-calculator", to: "calculators#sleep", as: :sleep
    get "one-rep-max-calculator", to: "calculators#one_rep_max", as: :one_rep_max
    get "dog-age-calculator", to: "calculators#dog_age", as: :dog_age
    get "pregnancy-week-calculator", to: "calculators#pregnancy_week", as: :pregnancy_week
    get "dog-food-calculator", to: "calculators#dog_food", as: :dog_food
    get "ideal-weight-calculator", to: "calculators#ideal_weight", as: :ideal_weight
    get "bac-calculator", to: "calculators#bac", as: :bac
    get "conception-calculator", to: "calculators#conception", as: :conception
    get "heart-rate-zone-calculator", to: "calculators#heart_rate_zone", as: :heart_rate_zone
    get "keto-calculator", to: "calculators#keto", as: :keto
    get "intermittent-fasting-calculator", to: "calculators#intermittent_fasting", as: :intermittent_fasting
    get "ovulation-calculator", to: "calculators#ovulation", as: :ovulation
    get "blood-pressure-calculator", to: "calculators#blood_pressure", as: :blood_pressure
    get "lean-body-mass-calculator", to: "calculators#lean_body_mass", as: :lean_body_mass
  end

  # Construction calculators
  namespace :construction do
    get "paint-calculator", to: "calculators#paint", as: :paint
    get "flooring-calculator", to: "calculators#flooring", as: :flooring
    get "concrete-calculator", to: "calculators#concrete", as: :concrete
    get "gravel-mulch-calculator", to: "calculators#gravel_mulch", as: :gravel_mulch
    get "fence-calculator", to: "calculators#fence", as: :fence
    get "roofing-calculator", to: "calculators#roofing", as: :roofing
    get "staircase-calculator", to: "calculators#staircase", as: :staircase
    get "deck-calculator", to: "calculators#deck", as: :deck
    get "wallpaper-calculator", to: "calculators#wallpaper", as: :wallpaper
    get "tile-calculator", to: "calculators#tile", as: :tile
    get "lumber-calculator", to: "calculators#lumber", as: :lumber
    get "hvac-btu-calculator", to: "calculators#hvac_btu", as: :hvac_btu
  end

  # Everyday calculators
  namespace :everyday do
    get "tip-calculator", to: "calculators#tip", as: :tip
    get "discount-calculator", to: "calculators#discount", as: :discount
    get "age-calculator", to: "calculators#age", as: :age
    get "date-difference-calculator", to: "calculators#date_difference", as: :date_difference
    get "gas-mileage-calculator", to: "calculators#gas_mileage", as: :gas_mileage
    get "fuel-cost-calculator", to: "calculators#fuel_cost", as: :fuel_cost
    get "gpa-calculator", to: "calculators#gpa", as: :gpa
    get "cooking-converter", to: "calculators#cooking_converter", as: :cooking_converter
    get "time-zone-converter", to: "calculators#time_zone_converter", as: :time_zone_converter
    get "shoe-size-converter", to: "calculators#shoe_size", as: :shoe_size
    get "grade-calculator", to: "calculators#grade", as: :grade
    get "electricity-bill-calculator", to: "calculators#electricity_bill", as: :electricity_bill
    get "moving-cost-calculator", to: "calculators#moving_cost", as: :moving_cost
    get "password-strength-calculator", to: "calculators#password_strength", as: :password_strength
    get "screen-size-calculator", to: "calculators#screen_size", as: :screen_size
    get "bandwidth-calculator", to: "calculators#bandwidth", as: :bandwidth
    get "unit-price-calculator", to: "calculators#unit_price", as: :unit_price
  end

  # Blog
  get "blog", to: "blog#index", as: :blog
  get "blog/:slug", to: "blog#show", as: :blog_post

  # Static pages
  get "privacy-policy", to: "pages#privacy_policy", as: :privacy_policy
  get "terms-of-service", to: "pages#terms_of_service", as: :terms_of_service
  get "about", to: "pages#about", as: :about
  get "contact", to: "pages#contact", as: :contact
  get "disclaimer", to: "pages#disclaimer", as: :disclaimer

  # SEO
  get "sitemap.xml", to: "sitemap#show", defaults: { format: :xml }
  get "robots.txt", to: "robots#show", defaults: { format: :text }

  # Category landing pages (must be last to avoid catching other routes)
  get ":category", to: "categories#show", as: :category,
      constraints: { category: /finance|math|physics|health|construction|everyday/ }

  root "home#index"
end
