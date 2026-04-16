# frozen_string_literal: true

class CalculatorRegistry
  # Load per-category calculator definitions
  Dir[File.join(__dir__, "calculator_registry", "*.rb")].sort.each { |f| require_relative f }

  IT_TOOL_SLUGS = %w[
    secure-random-generator uuid-generator hash-generator hmac-generator
    jwt-decoder unix-timestamp-converter cron-expression-parser cron-job-generator
    color-converter color-palette-picker url-parser http-header-parser
    cidr-subnet-calculator yaml-to-json-converter csv-to-json-converter
    xml-to-json-converter sql-formatter html-entity-encoder-decoder
    code-minifier-beautifier escape-unescape-tool csv-to-excel-converter
    excel-to-csv-converter markdown-to-html-converter html-to-markdown-converter
    txt-to-pdf-converter csv-to-pdf-converter markdown-to-pdf-converter
    excel-to-pdf-converter docx-to-pdf-converter
    password-strength-calculator regex-tester string-encoder-decoder
    json-formatter word-counter character-counter case-converter
    remove-duplicates lorem-ipsum-generator text-diff-checker markdown-preview
    password-generator csp-header-builder chmod-calculator port-number-reference
    qr-code-generator base64-image-encoder markdown-table-generator
    json-to-csv-converter nginx-config-generator dockerfile-generator
    gitignore-generator env-variable-validator regex-builder
    cors-header-checker ssl-certificate-decoder ip-address-lookup
    dns-lookup mac-address-lookup
    odt-to-docx-converter odt-to-pdf-converter
    docx-to-odt-converter
    css-box-shadow-generator css-flexbox-generator px-to-rem-converter
    meta-tag-generator favicon-generator
    schema-markup-generator keyword-density-checker
    barcode-generator fake-data-generator image-resizer
    byte-converter
    http-status-code-reference open-graph-preview curl-to-code-converter
    json-to-yaml-converter json-to-typescript-generator
    html-formatter-beautifier css-formatter-beautifier
    javascript-formatter-beautifier
    html-to-jsx-converter robots-txt-generator svg-to-png-converter
    base64-encoder-decoder url-encoder-decoder hex-ascii-converter
    jwt-generator api-response-time-calculator database-size-estimator
    text-encryptor uptime-calculator
  ].freeze

  # Tools from everyday that also display on the math category page
  MATH_CROSSLIST_SLUGS = %w[
    prime-number-checker random-number-generator roman-numeral-converter
  ].freeze

  ALL_CATEGORIES = {
    "finance" => {
      title: "Finance Calculators",
      description: "Free financial calculators for mortgage, loans, investments, retirement planning, ROI, and more. Make smarter money decisions with accurate calculations.",
      calculators: FINANCE_CALCULATORS
    },
    "math" => {
      title: "Math Calculators",
      description: "Free math calculators for percentages, fractions, area, statistics, and algebra. Get instant answers with step-by-step solutions.",
      calculators: MATH_CALCULATORS
    },
    "physics" => {
      title: "Physics Calculators",
      description: "Free physics calculators for velocity, force, energy, electricity, and projectile motion. Solve physics problems instantly with clear formulas and results.",
      calculators: PHYSICS_CALCULATORS
    },
    "health" => {
      title: "Health & Fitness Calculators",
      description: "Free health calculators for BMI, calories, macros, TDEE, pace, sleep cycles, and more. Track your health metrics with science-based tools.",
      calculators: HEALTH_CALCULATORS
    },
    "construction" => {
      title: "Construction Calculators",
      description: "Free construction calculators for paint, flooring, concrete, gravel, and fencing. Estimate materials and costs before your next project.",
      calculators: CONSTRUCTION_CALCULATORS
    },
    "textile" => {
      title: "Textile & Sewing Calculators",
      description: "Free textile calculators for sewing, knitting, crochet, quilting, and cross-stitch. Calculate fabric yardage, gauge, yarn amounts, quilt backing, and more.",
      calculators: TEXTILE_CALCULATORS
    },
    "everyday" => {
      title: "Everyday Calculators",
      description: "Free everyday calculators for tips, discounts, age, dates, fuel, GPA, and cooking conversions. Quick answers for daily life.",
      calculators: EVERYDAY_CALCULATORS
    },
    "alcohol" => {
      title: "Alcohol & Brewing Calculators",
      description: "Free calculators for the alcohol industry: brewing, winemaking, distilling, and bartending. Calculate ABV, IBU, SRM color, yeast pitch rates, priming sugar, pour cost, and more.",
      calculators: ALCOHOL_CALCULATORS
    },
    "geography" => {
      title: "Geography Calculators",
      description: "Free geography calculators and mapping tools for coordinate distance, bearing, midpoint, latitude/longitude conversion, map scale, and population density. Built for travelers, GIS users, hikers, students, and planners.",
      calculators: GEOGRAPHY_CALCULATORS
    },
    "gardening" => {
      title: "Gardening & Landscaping Calculators",
      description: "Free gardening and landscaping calculators for mulch, topsoil, raised beds, compost, fertilizer, grass seed, lawn watering, plant spacing, growing degree days, tree age, and greenhouse heating. Plan your garden like a pro.",
      calculators: GARDENING_CALCULATORS
    },
    "relationships" => {
      title: "Relationship Calculators",
      description: "Free relationship calculators for love compatibility, zodiac matches, age gaps, wedding budgets, anniversary counting, breakup recovery, divorce cost, alimony, child support, and more. Fun and practical tools for every stage of dating and marriage.",
      calculators: RELATIONSHIPS_CALCULATORS
    },
    "photography" => {
      title: "Photography Calculators",
      description: "Free photography calculators for depth of field, exposure triangle, print size DPI, video file size, aspect ratio cropping, golden hour times, time-lapse intervals, and photo storage. Essential tools for photographers and videographers.",
      calculators: PHOTOGRAPHY_CALCULATORS
    },
    "education" => {
      title: "Education Calculators",
      description: "Free education calculators for student loan forgiveness, college cost comparison, scholarship ROI, class scheduling, research paper word counts, credit transfers, and 529 tuition savings plans. Smart tools for students and parents.",
      calculators: EDUCATION_CALCULATORS
    },
    "pets" => {
      title: "Pet Calculators",
      description: "Free pet calculators for cat age, cat food, fish tank stocking, pet insurance ROI, medication dosage, puppy weight prediction, and horse feed. Science-based tools for responsible pet owners.",
      calculators: PETS_CALCULATORS
    },
    "cooking" => {
      title: "Cooking Calculators",
      description: "Free cooking calculators for recipe scaling, baking substitutions, sourdough hydration, meat cooking times, BBQ smoking, pizza dough, canning altitude adjustments, freezer storage, meal prep costs, and recipe macros. Essential kitchen tools for home cooks and food enthusiasts.",
      calculators: COOKING_CALCULATORS
    },
    "automotive" => {
      title: "Automotive Calculators",
      description: "Free automotive calculators for MPG, car depreciation, tire size comparison, 0-60 time, engine horsepower, oil change intervals, total cost of ownership, towing capacity, EV range, EV charging cost, and EV vs gas comparison. Essential tools for car owners and enthusiasts.",
      calculators: AUTOMOTIVE_CALCULATORS
    }
  }.freeze

  # Maps calculator slugs to relevant blog post slugs for cross-linking
  CALCULATOR_BLOG_MAP = {
    "mortgage-calculator" => %w[how-to-calculate-monthly-mortgage-payment 15-year-vs-30-year-mortgage how-much-house-can-i-afford],
    "compound-interest-calculator" => %w[compound-interest-explained dollar-cost-averaging-strategy],
    "loan-calculator" => %w[how-to-calculate-monthly-mortgage-payment small-business-loan-guide],
    "investment-calculator" => %w[compound-interest-explained dollar-cost-averaging-strategy how-to-calculate-roi],
    "retirement-calculator" => %w[compound-interest-explained dollar-cost-averaging-strategy],
    "debt-payoff-calculator" => %w[how-to-pay-off-credit-card-debt],
    "savings-goal-calculator" => %w[compound-interest-explained],
    "roi-calculator" => %w[how-to-calculate-roi dividend-investing-yield-income],
    "profit-margin-calculator" => %w[break-even-analysis-guide],
    "break-even-calculator" => %w[break-even-analysis-guide],
    "rent-vs-buy-calculator" => %w[renting-vs-buying-complete-comparison how-much-house-can-i-afford],
    "dividend-yield-calculator" => %w[dividend-investing-yield-income how-to-calculate-roi],
    "dca-calculator" => %w[dollar-cost-averaging-strategy compound-interest-explained],
    "tax-bracket-calculator" => %w[how-tax-brackets-work],
    "auto-loan-calculator" => %w[auto-loan-tips-best-car-payment],
    "credit-card-payoff-calculator" => %w[how-to-pay-off-credit-card-debt],
    "net-worth-calculator" => %w[how-to-calculate-net-worth],
    "home-affordability-calculator" => %w[how-much-house-can-i-afford renting-vs-buying-complete-comparison 15-year-vs-30-year-mortgage],
    "business-loan-calculator" => %w[small-business-loan-guide break-even-analysis-guide],
    "markup-margin-calculator" => %w[break-even-analysis-guide],
    "bmi-calculator" => %w[bmi-chart-what-your-score-means body-fat-percentage-guide],
    "calorie-calculator" => %w[how-to-calculate-tdee-lose-weight],
    "body-fat-calculator" => %w[body-fat-percentage-guide bmi-chart-what-your-score-means],
    "tdee-calculator" => %w[how-to-calculate-tdee-lose-weight],
    "macro-calculator" => %w[how-to-calculate-tdee-lose-weight],
    "pace-calculator" => %w[running-pace-calculator-guide],
    "pregnancy-due-date-calculator" => %w[pregnancy-week-by-week-guide],
    "pregnancy-week-calculator" => %w[pregnancy-week-by-week-guide],
    "dog-age-calculator" => %w[how-much-to-feed-dog],
    "dog-food-calculator" => %w[how-much-to-feed-dog],
    "percentage-calculator" => %w[percentage-calculations-guide],
    "area-calculator" => %w[how-to-calculate-area-any-shape],
    "unit-converter" => %w[unit-conversion-complete-guide],
    "paint-calculator" => %w[how-much-paint-do-i-need],
    "concrete-calculator" => %w[how-much-concrete-do-i-need],
    "tip-calculator" => %w[tip-calculator-guide-how-much],
    "gpa-calculator" => %w[gpa-calculator-guide],
    "electricity-cost-calculator" => %w[electricity-cost-calculator-guide],
    "fuel-cost-calculator" => %w[electricity-cost-calculator-guide]
  }.freeze

  # Seasonal featured calculators - rotated by month
  SEASONAL_FEATURES = {
    1  => %w[calorie-calculator tdee-calculator savings-goal-calculator],      # New Year resolutions
    2  => %w[calorie-deficit-calculator heart-rate-zone-calculator roi-calculator],
    3  => %w[tax-bracket-calculator salary-calculator mortgage-calculator],    # Tax season
    4  => %w[tax-bracket-calculator mortgage-calculator home-affordability-calculator], # Tax + spring housing
    5  => %w[mortgage-calculator paint-calculator deck-calculator],            # Home improvement
    6  => %w[concrete-calculator roofing-calculator fuel-cost-calculator],     # Summer projects
    7  => %w[fuel-cost-calculator bmi-calculator pace-calculator],             # Summer fitness
    8  => %w[gpa-calculator grade-calculator student-loan-calculator],         # Back to school
    9  => %w[gpa-calculator budget-calculator retirement-calculator],
    10 => %w[retirement-calculator investment-calculator compound-interest-calculator],
    11 => %w[discount-calculator tip-calculator savings-goal-calculator],      # Holiday shopping
    12 => %w[discount-calculator tip-calculator savings-goal-calculator]       # Holiday shopping
  }.freeze

  # Maps calculators to relevant calculators in OTHER categories
  CROSS_CATEGORY_LINKS = {
    # Finance ↔ Construction/Health/Everyday
    "mortgage-calculator" => %w[home-affordability-calculator paint-calculator concrete-calculator],
    "loan-calculator" => %w[mortgage-calculator auto-loan-calculator debt-payoff-calculator],
    "compound-interest-calculator" => %w[investment-calculator savings-goal-calculator retirement-calculator],
    "retirement-calculator" => %w[401k-calculator compound-interest-calculator savings-goal-calculator],
    "salary-calculator" => %w[tax-bracket-calculator paycheck-calculator inflation-calculator],
    "profit-margin-calculator" => %w[roi-calculator break-even-calculator invoice-generator],
    "invoice-generator" => %w[profit-margin-calculator tax-bracket-calculator roi-calculator],
    "detailed-invoice-generator" => %w[invoice-generator profit-margin-calculator break-even-calculator],
    "home-affordability-calculator" => %w[mortgage-calculator paint-calculator concrete-calculator],
    "auto-loan-calculator" => %w[loan-calculator fuel-cost-calculator gas-mileage-calculator],
    "student-loan-calculator" => %w[gpa-calculator salary-calculator paycheck-calculator],
    # Health ↔ Everyday/Math
    "bmi-calculator" => %w[calorie-calculator tdee-calculator ideal-weight-calculator],
    "calorie-calculator" => %w[bmi-calculator macro-calculator cooking-converter],
    "tdee-calculator" => %w[calorie-calculator macro-calculator pace-calculator],
    "macro-calculator" => %w[calorie-calculator tdee-calculator keto-calculator],
    "pace-calculator" => %w[calorie-calculator speed-converter length-converter],
    "water-intake-calculator" => %w[calorie-calculator cup-converter weight-converter],
    "pregnancy-due-date-calculator" => %w[date-difference-calculator age-calculator pregnancy-week-calculator],
    "dog-food-calculator" => %w[dog-age-calculator weight-converter calorie-calculator],
    # Math ↔ Finance/Everyday
    "percentage-calculator" => %w[discount-calculator tip-calculator profit-margin-calculator],
    "fraction-calculator" => %w[percentage-calculator gcd-lcm-calculator cooking-converter],
    "area-calculator" => %w[flooring-calculator paint-calculator tile-calculator],
    "standard-deviation-calculator" => %w[sample-size-calculator percentage-calculator gpa-calculator],
    # Physics ↔ Everyday/Construction
    "velocity-calculator" => %w[force-calculator speed-converter length-converter],
    "force-calculator" => %w[velocity-calculator weight-converter kinetic-energy-calculator],
    "electricity-cost-calculator" => %w[wire-gauge-calculator electricity-bill-calculator fuel-cost-calculator],
    "unit-converter" => %w[length-converter weight-converter speed-converter],
    # Construction ↔ Finance/Math
    "concrete-calculator" => %w[gravel-mulch-calculator mortgage-calculator area-calculator],
    "paint-calculator" => %w[wallpaper-calculator flooring-calculator area-calculator],
    "flooring-calculator" => %w[area-calculator tile-calculator paint-calculator],
    "deck-calculator" => %w[lumber-calculator mortgage-calculator concrete-calculator],
    # Everyday ↔ cross-category
    "tip-calculator" => %w[discount-calculator percentage-calculator cooking-converter],
    "discount-calculator" => %w[percentage-calculator tip-calculator unit-price-calculator],
    "fuel-cost-calculator" => %w[gas-mileage-calculator moving-cost-calculator auto-loan-calculator],
    "cooking-converter" => %w[cup-converter weight-converter calorie-calculator],
    "cup-converter" => %w[cooking-converter teaspoon-converter volume-converter],
    "length-converter" => %w[area-calculator speed-converter weight-converter],
    "weight-converter" => %w[length-converter cooking-converter bmi-calculator],
    "temperature-converter" => %w[speed-converter length-converter weight-converter],
    "speed-converter" => %w[velocity-calculator length-converter pace-calculator],
    "volume-converter" => %w[cup-converter length-converter area-calculator],
    "age-calculator" => %w[date-difference-calculator dog-age-calculator pregnancy-due-date-calculator],
    "date-difference-calculator" => %w[age-calculator time-zone-converter pregnancy-due-date-calculator],
    "gpa-calculator" => %w[grade-calculator percentage-calculator student-loan-calculator],
    "electricity-bill-calculator" => %w[electricity-cost-calculator fuel-cost-calculator solar-savings-calculator],
    "work-hours-calculator" => %w[salary-calculator paycheck-calculator date-difference-calculator]
  }.freeze

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

  def self.all_calculators
    ALL_CATEGORIES.values.flat_map { |cat| cat[:calculators] }
  end

  def self.find_by_slug(slug)
    all_calculators.find { |c| c[:slug] == slug }
  end

  def self.calculators_for_category(category_slug)
    ALL_CATEGORIES.dig(category_slug, :calculators) || []
  end
end
