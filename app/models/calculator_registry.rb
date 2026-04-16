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

  # Maps calculators to relevant calculators in OTHER categories (or adjacent
  # tools in the same category). The _cross_category_calculators partial shows
  # the first 3 entries in a "You Might Also Need" section on each calc page,
  # so keep the list focused on genuinely complementary tools.
  CROSS_CATEGORY_LINKS = {
    # ── Finance ───────────────────────────────────────────────────────────
    "mortgage-calculator" => %w[home-affordability-calculator amortization-calculator refinance-calculator],
    "loan-calculator" => %w[mortgage-calculator auto-loan-calculator debt-payoff-calculator],
    "compound-interest-calculator" => %w[investment-calculator savings-goal-calculator retirement-calculator],
    "investment-calculator" => %w[compound-interest-calculator retirement-calculator roi-calculator],
    "retirement-calculator" => %w[401k-calculator compound-interest-calculator savings-goal-calculator],
    "pension-calculator" => %w[retirement-calculator 401k-calculator compound-interest-calculator],
    "401k-calculator" => %w[retirement-calculator pension-calculator compound-interest-calculator],
    "fire-calculator" => %w[retirement-calculator savings-goal-calculator compound-interest-calculator],
    "salary-calculator" => %w[tax-bracket-calculator paycheck-calculator inflation-calculator],
    "salary-converter" => %w[salary-calculator hourly-to-salary-calculator paycheck-calculator],
    "hourly-to-salary-calculator" => %w[salary-converter salary-calculator paycheck-calculator],
    "hourly-to-project-calculator" => %w[freelance-rate-calculator hourly-to-salary-calculator side-hustle-calculator],
    "hourly-paycheck-calculator" => %w[paycheck-calculator overtime-calculator hourly-to-salary-calculator],
    "overtime-calculator" => %w[hourly-paycheck-calculator paycheck-calculator work-hours-calculator],
    "paycheck-calculator" => %w[salary-calculator tax-bracket-calculator overtime-calculator],
    "net-pay-calculator" => %w[paycheck-calculator salary-calculator tax-bracket-calculator],
    "tax-bracket-calculator" => %w[paycheck-calculator salary-calculator capital-gains-tax-calculator],
    "capital-gains-tax-calculator" => %w[stock-profit-calculator estate-tax-calculator tax-bracket-calculator],
    "estate-tax-calculator" => %w[inheritance-tax-calculator capital-gains-tax-calculator net-worth-calculator],
    "inheritance-tax-calculator" => %w[estate-tax-calculator capital-gains-tax-calculator net-worth-calculator],
    "sales-tax-calculator" => %w[vat-calculator markup-margin-calculator profit-margin-calculator],
    "vat-calculator" => %w[sales-tax-calculator markup-margin-calculator profit-margin-calculator],
    "side-hustle-calculator" => %w[freelance-tax-calculator freelance-rate-calculator hourly-to-project-calculator],
    "freelance-rate-calculator" => %w[hourly-to-project-calculator freelance-tax-calculator salary-converter],
    "freelance-tax-calculator" => %w[side-hustle-calculator freelance-rate-calculator tax-bracket-calculator],
    "profit-margin-calculator" => %w[roi-calculator break-even-calculator markup-margin-calculator],
    "markup-margin-calculator" => %w[profit-margin-calculator break-even-calculator sales-tax-calculator],
    "break-even-calculator" => %w[profit-margin-calculator markup-margin-calculator saas-metrics-calculator],
    "roi-calculator" => %w[profit-margin-calculator investment-calculator stock-profit-calculator],
    "invoice-generator" => %w[profit-margin-calculator tax-bracket-calculator roi-calculator],
    "detailed-invoice-generator" => %w[invoice-generator profit-margin-calculator break-even-calculator],
    "saas-metrics-calculator" => %w[revenue-per-employee-calculator cost-per-acquisition-calculator startup-runway-calculator],
    "startup-runway-calculator" => %w[saas-metrics-calculator business-loan-calculator revenue-per-employee-calculator],
    "revenue-per-employee-calculator" => %w[saas-metrics-calculator profit-margin-calculator break-even-calculator],
    "cost-per-acquisition-calculator" => %w[cost-per-lead-calculator cost-per-click-calculator saas-metrics-calculator],
    "cost-per-click-calculator" => %w[cost-per-lead-calculator cost-per-acquisition-calculator roi-calculator],
    "cost-per-lead-calculator" => %w[cost-per-acquisition-calculator cost-per-click-calculator roi-calculator],
    "earnings-per-share-calculator" => %w[dividend-yield-calculator stock-profit-calculator roi-calculator],
    "stock-profit-calculator" => %w[roi-calculator dividend-yield-calculator capital-gains-tax-calculator],
    "dividend-yield-calculator" => %w[stock-profit-calculator investment-calculator roi-calculator],
    "dca-calculator" => %w[investment-calculator compound-interest-calculator stock-profit-calculator],
    "crypto-profit-calculator" => %w[stock-profit-calculator roi-calculator capital-gains-tax-calculator],
    "options-profit-calculator" => %w[stock-profit-calculator crypto-profit-calculator roi-calculator],
    "bond-yield-calculator" => %w[dividend-yield-calculator cd-calculator investment-calculator],
    "cd-calculator" => %w[savings-interest-calculator money-market-calculator compound-interest-calculator],
    "money-market-calculator" => %w[cd-calculator savings-growth-calculator savings-interest-calculator],
    "savings-interest-calculator" => %w[savings-growth-calculator compound-interest-calculator cd-calculator],
    "savings-growth-calculator" => %w[compound-interest-calculator savings-interest-calculator cd-calculator],
    "savings-goal-calculator" => %w[savings-per-month-calculator compound-interest-calculator emergency-fund-calculator],
    "savings-per-month-calculator" => %w[savings-goal-calculator emergency-fund-calculator down-payment-calculator],
    "emergency-fund-calculator" => %w[savings-goal-calculator net-worth-calculator savings-per-month-calculator],
    "down-payment-calculator" => %w[mortgage-calculator home-affordability-calculator savings-goal-calculator],
    "net-worth-calculator" => %w[emergency-fund-calculator retirement-calculator savings-goal-calculator],
    "inflation-calculator" => %w[retirement-calculator cost-of-living-calculator salary-calculator],
    "cost-of-living-calculator" => %w[salary-calculator currency-converter rent-affordability-calculator],
    "currency-converter" => %w[cost-of-living-calculator inflation-calculator salary-calculator],
    # Loans by asset
    "auto-loan-calculator" => %w[car-loan-calculator lease-vs-buy-calculator fuel-cost-calculator],
    "car-loan-calculator" => %w[auto-loan-calculator lease-vs-buy-calculator mpg-calculator],
    "motorcycle-loan-calculator" => %w[auto-loan-calculator personal-loan-calculator loan-calculator],
    "rv-loan-calculator" => %w[auto-loan-calculator boat-loan-calculator motorcycle-loan-calculator],
    "boat-loan-calculator" => %w[rv-loan-calculator auto-loan-calculator personal-loan-calculator],
    "lease-vs-buy-calculator" => %w[auto-loan-calculator car-loan-calculator mpg-calculator],
    "personal-loan-calculator" => %w[loan-calculator debt-payoff-calculator credit-card-payoff-calculator],
    "business-loan-calculator" => %w[loan-calculator startup-runway-calculator break-even-calculator],
    "student-loan-calculator" => %w[student-loan-forgiveness-calculator tuition-savings-529-calculator gpa-calculator],
    # Debt
    "debt-payoff-calculator" => %w[debt-snowball-vs-avalanche-calculator credit-card-payoff-calculator personal-loan-calculator],
    "credit-card-payoff-calculator" => %w[debt-payoff-calculator debt-snowball-vs-avalanche-calculator personal-loan-calculator],
    "debt-snowball-vs-avalanche-calculator" => %w[debt-payoff-calculator credit-card-payoff-calculator loan-calculator],
    # Real estate
    "home-affordability-calculator" => %w[mortgage-calculator down-payment-calculator rent-vs-buy-calculator],
    "rent-vs-buy-calculator" => %w[rent-affordability-calculator home-affordability-calculator mortgage-calculator],
    "rent-affordability-calculator" => %w[rent-vs-buy-calculator home-affordability-calculator salary-calculator],
    "amortization-calculator" => %w[mortgage-calculator loan-calculator refinance-calculator],
    "refinance-calculator" => %w[mortgage-calculator heloc-calculator home-equity-loan-calculator],
    "heloc-calculator" => %w[home-equity-loan-calculator mortgage-calculator refinance-calculator],
    "home-equity-loan-calculator" => %w[heloc-calculator refinance-calculator mortgage-calculator],
    "house-flip-calculator" => %w[mortgage-calculator roi-calculator refinance-calculator],
    "fha-mortgage-calculator" => %w[mortgage-calculator va-mortgage-calculator jumbo-mortgage-calculator],
    "va-mortgage-calculator" => %w[mortgage-calculator fha-mortgage-calculator jumbo-mortgage-calculator],
    "jumbo-mortgage-calculator" => %w[mortgage-calculator fha-mortgage-calculator va-mortgage-calculator],
    # Other finance
    "solar-savings-calculator" => %w[electricity-bill-calculator solar-panel-layout-calculator electricity-cost-calculator],
    "tip-pooling-calculator" => %w[tip-calculator overtime-calculator hourly-paycheck-calculator],

    # ── Health ────────────────────────────────────────────────────────────
    "bmi-calculator" => %w[calorie-calculator tdee-calculator ideal-weight-calculator],
    "bmi-calculator-kids" => %w[bmi-calculator body-fat-calculator ideal-weight-calculator],
    "bmi-calculator-men" => %w[bmi-calculator body-fat-calculator tdee-calculator],
    "bmi-calculator-women" => %w[bmi-calculator body-fat-calculator ideal-weight-calculator],
    "calorie-calculator" => %w[tdee-calculator macro-calculator calorie-deficit-calculator],
    "tdee-calculator" => %w[calorie-calculator macro-calculator weight-loss-calorie-calculator],
    "macro-calculator" => %w[calorie-calculator tdee-calculator keto-calculator],
    "calorie-deficit-calculator" => %w[weight-loss-calorie-calculator tdee-calculator macro-calculator],
    "weight-loss-calorie-calculator" => %w[calorie-deficit-calculator tdee-calculator macro-calculator],
    "bulking-calorie-calculator" => %w[calorie-calculator macro-calculator tdee-calculator],
    "keto-calculator" => %w[macro-calculator calorie-calculator tdee-calculator],
    "intermittent-fasting-calculator" => %w[calorie-calculator macro-calculator tdee-calculator],
    "protein-intake-calculator" => %w[protein-per-meal-calculator macro-calculator calorie-calculator],
    "protein-per-meal-calculator" => %w[protein-intake-calculator macro-calculator calorie-calculator],
    "calories-per-100g-calculator" => %w[calories-per-serving-calculator calorie-calculator macro-calculator],
    "calories-per-serving-calculator" => %w[calories-per-100g-calculator calorie-calculator macros-per-recipe-calculator],
    "body-fat-calculator" => %w[lean-body-mass-calculator ffmi-calculator ideal-weight-calculator],
    "lean-body-mass-calculator" => %w[body-fat-calculator ffmi-calculator ideal-weight-calculator],
    "ffmi-calculator" => %w[body-fat-calculator lean-body-mass-calculator bmi-calculator],
    "ideal-weight-calculator" => %w[bmi-calculator body-fat-calculator lean-body-mass-calculator],
    "wrist-height-ratio-calculator" => %w[bmi-calculator body-fat-calculator ideal-weight-calculator],
    "pace-calculator" => %w[running-pace-zone-calculator heart-rate-zone-calculator steps-per-mile-calculator],
    "running-pace-zone-calculator" => %w[pace-calculator heart-rate-zone-calculator vo2-max-calculator],
    "cycling-ftp-zone-calculator" => %w[heart-rate-zone-calculator running-pace-zone-calculator pace-calculator],
    "swim-pace-calculator" => %w[pace-calculator running-pace-zone-calculator heart-rate-zone-calculator],
    "heart-rate-zone-calculator" => %w[running-pace-zone-calculator vo2-max-calculator pace-calculator],
    "vo2-max-calculator" => %w[heart-rate-zone-calculator running-pace-zone-calculator pace-calculator],
    "steps-per-mile-calculator" => %w[pace-calculator running-pace-zone-calculator calorie-calculator],
    "one-rep-max-calculator" => %w[tdee-calculator macro-calculator ffmi-calculator],
    "water-intake-calculator" => %w[calorie-calculator cup-converter weight-converter],
    "sleep-calculator" => %w[caffeine-half-life-calculator biological-age-calculator heart-rate-zone-calculator],
    "caffeine-half-life-calculator" => %w[sleep-calculator alcohol-burnoff-calculator bac-calculator],
    "bac-calculator" => %w[alcohol-burnoff-calculator caffeine-half-life-calculator cocktail-abv-calculator],
    "alcohol-burnoff-calculator" => %w[bac-calculator caffeine-half-life-calculator cocktail-abv-calculator],
    "biological-age-calculator" => %w[bmi-calculator heart-rate-zone-calculator sleep-calculator],
    "blood-pressure-calculator" => %w[heart-rate-zone-calculator biological-age-calculator bmi-calculator],
    "blood-type-compatibility-calculator" => %w[biological-age-calculator bmi-calculator body-fat-calculator],
    "medication-dosage-calculator" => %w[pet-medication-dosage-calculator weight-converter caffeine-half-life-calculator],
    "hearing-loss-exposure-calculator" => %w[decibel-calculator blood-pressure-calculator biological-age-calculator],
    "wheelchair-ramp-calculator" => %w[staircase-calculator drainage-slope-calculator miter-angle-calculator],
    # Pregnancy / fertility
    "pregnancy-due-date-calculator" => %w[pregnancy-week-calculator conception-calculator pregnancy-weight-calculator],
    "pregnancy-week-calculator" => %w[pregnancy-due-date-calculator pregnancy-weight-calculator conception-calculator],
    "pregnancy-weight-calculator" => %w[pregnancy-due-date-calculator pregnancy-calorie-calculator bmi-calculator],
    "pregnancy-calorie-calculator" => %w[pregnancy-weight-calculator calorie-calculator macro-calculator],
    "conception-calculator" => %w[ovulation-calculator pregnancy-due-date-calculator pregnancy-week-calculator],
    "ovulation-calculator" => %w[conception-calculator pregnancy-due-date-calculator pregnancy-week-calculator],
    "ivf-due-date-calculator" => %w[pregnancy-due-date-calculator conception-calculator ovulation-calculator],
    "dog-food-calculator" => %w[dog-age-calculator weight-converter calorie-calculator],
    "dog-age-calculator" => %w[dog-food-calculator cat-age-calculator age-calculator],

    # ── Math ──────────────────────────────────────────────────────────────
    "scientific-calculator" => %w[base-converter exponent-calculator logarithm-calculator],
    "percentage-calculator" => %w[discount-calculator tip-calculator profit-margin-calculator],
    "percentage-increase-calculator" => %w[percentage-calculator percentage-decrease-calculator percentage-off-calculator],
    "percentage-decrease-calculator" => %w[percentage-calculator percentage-increase-calculator percentage-off-calculator],
    "percentage-off-calculator" => %w[percentage-calculator discount-calculator sale-price-calculator],
    "fraction-calculator" => %w[percentage-calculator gcd-lcm-calculator cooking-converter],
    "area-calculator" => %w[flooring-calculator paint-calculator tile-calculator],
    "circumference-calculator" => %w[area-calculator pythagorean-theorem-calculator aspect-ratio-calculator],
    "exponent-calculator" => %w[logarithm-calculator scientific-notation-calculator base-arithmetic-calculator],
    "pythagorean-theorem-calculator" => %w[area-calculator quadratic-equation-calculator rafter-length-calculator],
    "quadratic-equation-calculator" => %w[pythagorean-theorem-calculator exponent-calculator complex-number-calculator],
    "standard-deviation-calculator" => %w[mean-median-mode-calculator probability-calculator sample-size-calculator],
    "mean-median-mode-calculator" => %w[standard-deviation-calculator probability-calculator gpa-calculator],
    "gcd-lcm-calculator" => %w[fraction-calculator modular-arithmetic-calculator prime-number-checker],
    "sample-size-calculator" => %w[standard-deviation-calculator probability-calculator mean-median-mode-calculator],
    "aspect-ratio-calculator" => %w[area-calculator print-size-dpi-calculator screen-size-calculator],
    "matrix-calculator" => %w[eigenvalue-calculator vector-calculator set-operations-calculator],
    "logarithm-calculator" => %w[exponent-calculator scientific-notation-calculator derivative-calculator],
    "probability-calculator" => %w[permutation-combination-calculator standard-deviation-calculator sample-size-calculator],
    "permutation-combination-calculator" => %w[probability-calculator standard-deviation-calculator gcd-lcm-calculator],
    "base-converter" => %w[base-arithmetic-calculator hex-ascii-converter scientific-notation-calculator],
    "significant-figures-calculator" => %w[scientific-notation-calculator exponent-calculator logarithm-calculator],
    "scientific-notation-calculator" => %w[exponent-calculator logarithm-calculator significant-figures-calculator],
    "integral-calculator" => %w[derivative-calculator limit-calculator taylor-series-calculator],
    "derivative-calculator" => %w[integral-calculator limit-calculator taylor-series-calculator],
    "limit-calculator" => %w[derivative-calculator integral-calculator taylor-series-calculator],
    "taylor-series-calculator" => %w[integral-calculator derivative-calculator logarithm-calculator],
    "complex-number-calculator" => %w[vector-calculator quadratic-equation-calculator matrix-calculator],
    "vector-calculator" => %w[matrix-calculator complex-number-calculator eigenvalue-calculator],
    "eigenvalue-calculator" => %w[matrix-calculator vector-calculator complex-number-calculator],
    "boolean-algebra-simplifier" => %w[base-converter set-operations-calculator modular-arithmetic-calculator],
    "base-arithmetic-calculator" => %w[base-converter hex-ascii-converter modular-arithmetic-calculator],
    "modular-arithmetic-calculator" => %w[gcd-lcm-calculator prime-number-checker base-arithmetic-calculator],
    "set-operations-calculator" => %w[boolean-algebra-simplifier probability-calculator permutation-combination-calculator],

    # ── Physics ───────────────────────────────────────────────────────────
    "velocity-calculator" => %w[force-calculator speed-converter projectile-motion-calculator],
    "force-calculator" => %w[velocity-calculator kinetic-energy-calculator centripetal-force-calculator],
    "kinetic-energy-calculator" => %w[velocity-calculator force-calculator spring-constant-calculator],
    "projectile-motion-calculator" => %w[velocity-calculator force-calculator pendulum-calculator],
    "centripetal-force-calculator" => %w[force-calculator velocity-calculator spring-constant-calculator],
    "spring-constant-calculator" => %w[kinetic-energy-calculator force-calculator pendulum-calculator],
    "pendulum-calculator" => %w[kinetic-energy-calculator spring-constant-calculator wavelength-frequency-calculator],
    "buoyancy-calculator" => %w[pressure-converter element-volume-calculator pool-volume-calculator],
    "doppler-effect-calculator" => %w[velocity-calculator wavelength-frequency-calculator decibel-calculator],
    "wavelength-frequency-calculator" => %w[doppler-effect-calculator decibel-calculator lens-optics-calculator],
    "decibel-calculator" => %w[hearing-loss-exposure-calculator wavelength-frequency-calculator doppler-effect-calculator],
    "lens-optics-calculator" => %w[depth-of-field-calculator exposure-triangle-calculator aspect-ratio-calculator],
    "ohms-law-calculator" => %w[electrical-power-calculator resistor-color-code-calculator wire-gauge-calculator],
    "electrical-power-calculator" => %w[ohms-law-calculator electricity-cost-calculator resistor-color-code-calculator],
    "resistor-color-code-calculator" => %w[ohms-law-calculator electrical-power-calculator capacitor-calculator],
    "capacitor-calculator" => %w[inductor-calculator transformer-turns-ratio-calculator electrical-power-calculator],
    "inductor-calculator" => %w[capacitor-calculator transformer-turns-ratio-calculator electrical-power-calculator],
    "transformer-turns-ratio-calculator" => %w[ohms-law-calculator electrical-power-calculator voltage-drop-calculator],
    "wire-gauge-calculator" => %w[voltage-drop-calculator electrical-load-calculator wire-ampacity-calculator],
    "electricity-cost-calculator" => %w[electricity-bill-calculator kwh-to-cost-calculator solar-savings-calculator],
    "radioactive-decay-calculator" => %w[caffeine-half-life-calculator exponent-calculator compound-interest-calculator],
    "heat-transfer-calculator" => %w[heat-loss-calculator insulation-calculator radiant-floor-heat-calculator],
    "element-mass-calculator" => %w[element-volume-calculator weight-converter volume-converter],
    "element-volume-calculator" => %w[element-mass-calculator volume-converter buoyancy-calculator],
    "gear-ratio-calculator" => %w[velocity-calculator engine-horsepower-calculator aspect-ratio-calculator],
    "pressure-converter" => %w[unit-converter temperature-converter buoyancy-calculator],
    "planet-weight-calculator" => %w[weight-converter force-calculator kinetic-energy-calculator],
    "unit-converter" => %w[length-converter weight-converter speed-converter],

    # ── Automotive ────────────────────────────────────────────────────────
    "mpg-calculator" => %w[fuel-cost-calculator gas-mileage-calculator car-payment-total-cost-calculator],
    "car-depreciation-calculator" => %w[auto-loan-calculator car-loan-calculator lease-vs-buy-calculator],
    "tire-size-comparison-calculator" => %w[mpg-calculator engine-horsepower-calculator zero-to-sixty-calculator],
    "zero-to-sixty-calculator" => %w[engine-horsepower-calculator tire-size-comparison-calculator velocity-calculator],
    "engine-horsepower-calculator" => %w[zero-to-sixty-calculator tire-size-comparison-calculator towing-capacity-calculator],
    "oil-change-interval-calculator" => %w[car-payment-total-cost-calculator mpg-calculator car-depreciation-calculator],
    "car-payment-total-cost-calculator" => %w[auto-loan-calculator car-loan-calculator lease-vs-buy-calculator],
    "towing-capacity-calculator" => %w[engine-horsepower-calculator mpg-calculator rv-loan-calculator],
    "ev-range-calculator" => %w[ev-charging-cost-calculator ev-vs-gas-comparison-calculator mpg-calculator],
    "ev-charging-cost-calculator" => %w[ev-range-calculator ev-vs-gas-comparison-calculator electricity-cost-calculator],
    "ev-vs-gas-comparison-calculator" => %w[ev-range-calculator ev-charging-cost-calculator mpg-calculator],

    # ── Construction ──────────────────────────────────────────────────────
    "concrete-calculator" => %w[gravel-mulch-calculator concrete-mix-calculator rebar-spacing-calculator],
    "paint-calculator" => %w[wallpaper-calculator flooring-calculator area-calculator],
    "flooring-calculator" => %w[area-calculator tile-calculator carpet-calculator],
    "tile-calculator" => %w[grout-calculator flooring-calculator area-calculator],
    "deck-calculator" => %w[lumber-calculator fence-calculator concrete-calculator],
    "fence-calculator" => %w[deck-calculator lumber-calculator gravel-mulch-calculator],
    "roofing-calculator" => %w[rafter-length-calculator roof-pitch-calculator attic-ventilation-calculator],
    "staircase-calculator" => %w[wheelchair-ramp-calculator rafter-length-calculator deck-calculator],
    "wallpaper-calculator" => %w[paint-calculator area-calculator flooring-calculator],
    "lumber-calculator" => %w[board-foot-calculator plywood-sheets-calculator wood-weight-calculator],
    "hvac-btu-calculator" => %w[cooling-load-calculator heat-loss-calculator heat-pump-capacity-calculator],
    "drywall-calculator" => %w[drywall-screws-calculator insulation-calculator paint-calculator],
    "insulation-calculator" => %w[heat-loss-calculator window-u-value-calculator drywall-calculator],
    "plumbing-calculator" => %w[pipe-friction-loss-calculator water-heater-sizing-calculator septic-tank-size-calculator],
    "electrical-load-calculator" => %w[wire-ampacity-calculator voltage-drop-calculator generator-sizing-calculator],
    "retaining-wall-calculator" => %w[gravel-mulch-calculator concrete-calculator paver-calculator],
    "miter-angle-calculator" => %w[rafter-length-calculator crown-molding-calculator cabinet-door-calculator],
    "wood-moisture-calculator" => %w[wood-shrinkage-calculator wood-weight-calculator board-foot-calculator],
    "wood-shrinkage-calculator" => %w[wood-moisture-calculator wood-weight-calculator lumber-calculator],
    "wood-weight-calculator" => %w[board-foot-calculator lumber-calculator wood-shrinkage-calculator],
    "rip-cut-calculator" => %w[board-foot-calculator lumber-calculator plywood-sheets-calculator],
    "cabinet-door-calculator" => %w[miter-angle-calculator wood-weight-calculator crown-molding-calculator],
    "grout-calculator" => %w[tile-calculator caulk-calculator paint-calculator],
    "carpet-calculator" => %w[flooring-calculator area-calculator paint-calculator],
    "baseboard-calculator" => %w[crown-molding-calculator caulk-calculator paint-calculator],
    "siding-calculator" => %w[area-calculator paint-calculator insulation-calculator],
    "gutter-calculator" => %w[roofing-calculator roof-pitch-calculator drainage-slope-calculator],
    "water-heater-sizing-calculator" => %w[plumbing-calculator pipe-friction-loss-calculator heat-loss-calculator],
    "pool-volume-calculator" => %w[buoyancy-calculator volume-converter hvac-btu-calculator],
    "kitchen-remodel-cost-calculator" => %w[bathroom-remodel-cost-calculator cabinet-door-calculator flooring-calculator],
    "bathroom-remodel-cost-calculator" => %w[kitchen-remodel-cost-calculator plumbing-calculator tile-calculator],
    "attic-ventilation-calculator" => %w[insulation-calculator heat-loss-calculator erv-hrv-ventilation-calculator],
    "solar-panel-layout-calculator" => %w[solar-savings-calculator solar-inverter-sizing-calculator electricity-cost-calculator],
    "rebar-spacing-calculator" => %w[concrete-mix-calculator concrete-calculator beam-load-span-calculator],
    "concrete-mix-calculator" => %w[concrete-calculator rebar-spacing-calculator spread-footing-calculator],
    "beam-load-span-calculator" => %w[joist-calculator rafter-length-calculator lumber-calculator],
    "window-u-value-calculator" => %w[insulation-calculator heat-loss-calculator heating-cost-calculator],
    "drainage-slope-calculator" => %w[gutter-calculator pipe-friction-loss-calculator excavation-calculator],
    "brick-block-calculator" => %w[paver-calculator retaining-wall-calculator concrete-calculator],
    "septic-tank-size-calculator" => %w[water-heater-sizing-calculator plumbing-calculator pool-volume-calculator],
    "asphalt-calculator" => %w[concrete-calculator gravel-mulch-calculator paver-calculator],
    "excavation-calculator" => %w[concrete-calculator gravel-mulch-calculator drainage-slope-calculator],
    "paver-calculator" => %w[concrete-calculator gravel-mulch-calculator retaining-wall-calculator],
    "board-foot-calculator" => %w[lumber-calculator wood-weight-calculator rip-cut-calculator],
    "rafter-length-calculator" => %w[roof-pitch-calculator roofing-calculator lumber-calculator],
    "roof-pitch-calculator" => %w[rafter-length-calculator roofing-calculator attic-ventilation-calculator],
    "stud-count-calculator" => %w[drywall-calculator lumber-calculator plywood-sheets-calculator],
    "plywood-sheets-calculator" => %w[stud-count-calculator lumber-calculator joist-calculator],
    "joist-calculator" => %w[beam-load-span-calculator plywood-sheets-calculator lumber-calculator],
    "voltage-drop-calculator" => %w[electrical-load-calculator wire-ampacity-calculator wire-gauge-calculator],
    "conduit-fill-calculator" => %w[wire-ampacity-calculator voltage-drop-calculator electrical-load-calculator],
    "pipe-friction-loss-calculator" => %w[plumbing-calculator water-heater-sizing-calculator pool-volume-calculator],
    "heat-loss-calculator" => %w[insulation-calculator window-u-value-calculator heating-cost-calculator],
    "duct-size-calculator" => %w[static-pressure-calculator hvac-btu-calculator air-change-rate-calculator],
    "spread-footing-calculator" => %w[concrete-mix-calculator rebar-spacing-calculator beam-load-span-calculator],
    "caulk-calculator" => %w[grout-calculator paint-calculator baseboard-calculator],
    "crown-molding-calculator" => %w[baseboard-calculator miter-angle-calculator paint-calculator],
    "chimney-flue-calculator" => %w[heat-loss-calculator hvac-btu-calculator heating-cost-calculator],
    "cooling-load-calculator" => %w[heat-loss-calculator hvac-btu-calculator insulation-calculator],
    "heat-pump-capacity-calculator" => %w[seer-eer-hspf-calculator cooling-load-calculator heat-loss-calculator],
    "seer-eer-hspf-calculator" => %w[heat-pump-capacity-calculator hvac-btu-calculator electricity-cost-calculator],
    "dehumidifier-sizing-calculator" => %w[psychrometric-calculator air-change-rate-calculator hvac-btu-calculator],
    "psychrometric-calculator" => %w[dehumidifier-sizing-calculator air-change-rate-calculator temperature-converter],
    "air-change-rate-calculator" => %w[erv-hrv-ventilation-calculator duct-size-calculator dehumidifier-sizing-calculator],
    "erv-hrv-ventilation-calculator" => %w[air-change-rate-calculator cooling-load-calculator heat-loss-calculator],
    "radiator-btu-calculator" => %w[heat-loss-calculator radiant-floor-heat-calculator heating-cost-calculator],
    "heating-cost-calculator" => %w[heat-loss-calculator electricity-bill-calculator solar-savings-calculator],
    "static-pressure-calculator" => %w[duct-size-calculator hvac-btu-calculator air-change-rate-calculator],
    "generator-sizing-calculator" => %w[electrical-load-calculator battery-backup-runtime-calculator wire-ampacity-calculator],
    "wire-ampacity-calculator" => %w[voltage-drop-calculator conduit-fill-calculator electrical-load-calculator],
    "radiant-floor-heat-calculator" => %w[heat-loss-calculator radiator-btu-calculator heating-cost-calculator],
    "drywall-screws-calculator" => %w[drywall-calculator stud-count-calculator plywood-sheets-calculator],
    "snow-melt-btu-calculator" => %w[heat-loss-calculator heating-cost-calculator hvac-btu-calculator],
    "solar-inverter-sizing-calculator" => %w[solar-panel-layout-calculator battery-backup-runtime-calculator solar-savings-calculator],
    "battery-backup-runtime-calculator" => %w[generator-sizing-calculator solar-inverter-sizing-calculator electricity-bill-calculator],

    # ── Everyday ──────────────────────────────────────────────────────────
    "tip-calculator" => %w[discount-calculator percentage-calculator restaurant-tip-calculator],
    "discount-calculator" => %w[percentage-off-calculator sale-price-calculator coupon-calculator],
    "fuel-cost-calculator" => %w[gas-mileage-calculator mpg-calculator auto-loan-calculator],
    "gas-mileage-calculator" => %w[fuel-cost-calculator mpg-calculator ev-vs-gas-comparison-calculator],
    "cooking-converter" => %w[cup-converter weight-converter recipe-scaler],
    "cup-converter" => %w[cooking-converter teaspoon-converter volume-converter],
    "teaspoon-converter" => %w[tablespoon-converter cup-converter cooking-converter],
    "tablespoon-converter" => %w[teaspoon-converter cup-converter cooking-converter],
    "length-converter" => %w[area-calculator speed-converter weight-converter],
    "weight-converter" => %w[length-converter cooking-converter bmi-calculator],
    "temperature-converter" => %w[speed-converter length-converter weight-converter],
    "speed-converter" => %w[velocity-calculator length-converter pace-calculator],
    "volume-converter" => %w[cup-converter length-converter area-calculator],
    "byte-converter" => %w[bandwidth-calculator database-size-estimator data-usage-cost-calculator],
    "age-calculator" => %w[date-difference-calculator dog-age-calculator anniversary-calculator],
    "date-difference-calculator" => %w[age-calculator time-zone-converter business-days-calculator],
    "gpa-calculator" => %w[grade-calculator final-grade-calculator percentage-calculator],
    "grade-calculator" => %w[gpa-calculator final-grade-calculator percentage-calculator],
    "final-grade-calculator" => %w[grade-calculator gpa-calculator percentage-calculator],
    "electricity-bill-calculator" => %w[electricity-cost-calculator kwh-to-cost-calculator solar-savings-calculator],
    "electricity-usage-calculator" => %w[electricity-bill-calculator electricity-cost-calculator kwh-to-cost-calculator],
    "kwh-to-cost-calculator" => %w[electricity-cost-calculator electricity-bill-calculator electricity-usage-calculator],
    "work-hours-calculator" => %w[time-card-calculator shift-duration-calculator overtime-calculator],
    "time-card-calculator" => %w[work-hours-calculator shift-duration-calculator hourly-paycheck-calculator],
    "shift-duration-calculator" => %w[work-hours-calculator time-card-calculator overtime-calculator],
    "work-break-calculator" => %w[work-hours-calculator time-card-calculator shift-duration-calculator],
    "time-zone-converter" => %w[timezone-meeting-planner date-difference-calculator age-calculator],
    "timezone-meeting-planner" => %w[time-zone-converter date-difference-calculator work-hours-calculator],
    "shoe-size-converter" => %w[length-converter weight-converter cooking-converter],
    "moving-cost-calculator" => %w[fuel-cost-calculator rent-affordability-calculator rent-per-sqm-calculator],
    "password-strength-calculator" => %w[password-generator hash-generator secure-random-generator],
    "screen-size-calculator" => %w[aspect-ratio-calculator length-converter video-file-size-calculator],
    "bandwidth-calculator" => %w[byte-converter data-usage-cost-calculator api-response-time-calculator],
    "unit-price-calculator" => %w[price-per-weight-calculator price-per-liter-calculator cost-per-serving-calculator],
    "words-per-minute-calculator" => %w[word-counter character-counter research-paper-word-count-estimator],
    "business-days-calculator" => %w[date-difference-calculator age-calculator days-until-calculator],
    "days-until-calculator" => %w[date-difference-calculator age-calculator anniversary-calculator],
    "subscription-cost-calculator" => %w[cost-per-day-calculator cost-per-hour-calculator cost-per-wear-calculator],
    "carbon-footprint-calculator" => %w[electricity-bill-calculator fuel-cost-calculator mpg-calculator],
    "calorie-tracker" => %w[calorie-calculator macro-calculator tdee-calculator],
    "split-bill-calculator" => %w[tip-calculator restaurant-tip-calculator bar-tip-calculator],
    "travel-budget-calculator" => %w[moving-cost-calculator fuel-cost-calculator flight-time-calculator],
    "pet-cost-calculator" => %w[cat-food-calculator dog-food-calculator pet-insurance-roi-calculator],
    "restaurant-tip-calculator" => %w[tip-calculator bar-tip-calculator hair-salon-tip-calculator],
    "bar-tip-calculator" => %w[restaurant-tip-calculator tip-calculator hair-salon-tip-calculator],
    "delivery-tip-calculator" => %w[restaurant-tip-calculator tip-calculator hair-salon-tip-calculator],
    "hair-salon-tip-calculator" => %w[tip-calculator restaurant-tip-calculator bar-tip-calculator],
    "cost-per-day-calculator" => %w[cost-per-hour-calculator subscription-cost-calculator cost-per-wear-calculator],
    "cost-per-hour-calculator" => %w[cost-per-day-calculator hourly-paycheck-calculator subscription-cost-calculator],
    "cost-per-km-calculator" => %w[cost-per-mile-calculator fuel-cost-calculator mpg-calculator],
    "cost-per-mile-calculator" => %w[cost-per-km-calculator fuel-cost-calculator mpg-calculator],
    "cost-per-page-calculator" => %w[cost-per-serving-calculator print-size-dpi-calculator unit-price-calculator],
    "cost-per-person-calculator" => %w[cost-per-serving-calculator split-bill-calculator wedding-cost-splitter],
    "cost-per-serving-calculator" => %w[cost-per-person-calculator unit-price-calculator price-per-weight-calculator],
    "cost-per-wear-calculator" => %w[cost-per-day-calculator subscription-cost-calculator unit-price-calculator],
    "coupon-calculator" => %w[discount-calculator percentage-off-calculator sale-price-calculator],
    "clearance-calculator" => %w[discount-calculator percentage-off-calculator sale-price-calculator],
    "sale-price-calculator" => %w[discount-calculator percentage-off-calculator coupon-calculator],
    "price-per-liter-calculator" => %w[unit-price-calculator price-per-weight-calculator cost-per-serving-calculator],
    "price-per-weight-calculator" => %w[unit-price-calculator price-per-liter-calculator cost-per-serving-calculator],
    "rent-per-sqm-calculator" => %w[rent-affordability-calculator rent-vs-buy-calculator home-affordability-calculator],
    "fuel-cost-trip-calculator" => %w[fuel-cost-calculator gas-mileage-calculator mpg-calculator],
    "data-usage-cost-calculator" => %w[bandwidth-calculator byte-converter subscription-cost-calculator],

    # ── Cooking ───────────────────────────────────────────────────────────
    "recipe-scaler" => %w[baking-substitution-calculator cup-converter cooking-converter],
    "baking-substitution-calculator" => %w[recipe-scaler cup-converter sourdough-hydration-calculator],
    "sourdough-hydration-calculator" => %w[pizza-dough-calculator baking-substitution-calculator recipe-scaler],
    "meat-cooking-time-calculator" => %w[smoke-time-calculator cooking-converter recipe-scaler],
    "smoke-time-calculator" => %w[meat-cooking-time-calculator cooking-converter recipe-scaler],
    "pizza-dough-calculator" => %w[sourdough-hydration-calculator recipe-scaler baking-substitution-calculator],
    "canning-altitude-calculator" => %w[meat-cooking-time-calculator freezer-storage-time-calculator baking-substitution-calculator],
    "freezer-storage-time-calculator" => %w[meat-cooking-time-calculator canning-altitude-calculator meal-prep-cost-calculator],
    "meal-prep-cost-calculator" => %w[cost-per-serving-calculator macros-per-recipe-calculator cooking-converter],
    "macros-per-recipe-calculator" => %w[macro-calculator calorie-calculator cost-per-serving-calculator],

    # ── Textile ───────────────────────────────────────────────────────────
    "fabric-yardage-calculator" => %w[seam-allowance-converter fabric-gsm-calculator length-converter],
    "seam-allowance-converter" => %w[fabric-yardage-calculator length-converter knitting-gauge-calculator],
    "knitting-gauge-calculator" => %w[crochet-gauge-calculator knitting-needle-hook-size-converter yarn-yardage-calculator],
    "crochet-gauge-calculator" => %w[knitting-gauge-calculator yarn-yardage-calculator knitting-needle-hook-size-converter],
    "knitting-needle-hook-size-converter" => %w[knitting-gauge-calculator crochet-gauge-calculator yarn-yardage-calculator],
    "yarn-yardage-calculator" => %w[knitting-gauge-calculator crochet-gauge-calculator fabric-yardage-calculator],
    "quilt-backing-calculator" => %w[half-square-triangle-calculator quilt-binding-strips-calculator fabric-yardage-calculator],
    "half-square-triangle-calculator" => %w[quilt-backing-calculator quilt-binding-strips-calculator fabric-yardage-calculator],
    "quilt-binding-strips-calculator" => %w[quilt-backing-calculator half-square-triangle-calculator fabric-yardage-calculator],
    "fabric-gsm-calculator" => %w[fabric-yardage-calculator fabric-shrinkage-calculator weight-converter],
    "fabric-shrinkage-calculator" => %w[fabric-gsm-calculator fabric-yardage-calculator length-converter],
    "cross-stitch-fabric-calculator" => %w[fabric-yardage-calculator knitting-gauge-calculator fabric-gsm-calculator],

    # ── Relationships ─────────────────────────────────────────────────────
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
    "online-dating-roi-calculator" => %w[dating-pool-calculator when-will-i-meet-someone-calculator roi-calculator],

    # ── Photography ───────────────────────────────────────────────────────
    "depth-of-field-calculator" => %w[exposure-triangle-calculator print-size-dpi-calculator aspect-ratio-crop-calculator],
    "exposure-triangle-calculator" => %w[depth-of-field-calculator golden-hour-calculator lens-optics-calculator],
    "print-size-dpi-calculator" => %w[aspect-ratio-crop-calculator aspect-ratio-calculator depth-of-field-calculator],
    "video-file-size-calculator" => %w[photo-storage-calculator aspect-ratio-crop-calculator bandwidth-calculator],
    "aspect-ratio-crop-calculator" => %w[aspect-ratio-calculator print-size-dpi-calculator depth-of-field-calculator],
    "golden-hour-calculator" => %w[timelapse-interval-calculator exposure-triangle-calculator latitude-longitude-converter],
    "timelapse-interval-calculator" => %w[golden-hour-calculator video-file-size-calculator photo-storage-calculator],
    "photo-storage-calculator" => %w[video-file-size-calculator byte-converter bandwidth-calculator],

    # ── Education ─────────────────────────────────────────────────────────
    "student-loan-forgiveness-calculator" => %w[student-loan-calculator college-cost-comparison-calculator tuition-savings-529-calculator],
    "college-cost-comparison-calculator" => %w[student-loan-calculator tuition-savings-529-calculator scholarship-roi-calculator],
    "scholarship-roi-calculator" => %w[roi-calculator college-cost-comparison-calculator student-loan-calculator],
    "class-schedule-builder" => %w[gpa-calculator study-time-calculator work-hours-calculator],
    "research-paper-word-count-estimator" => %w[word-counter words-per-minute-calculator character-counter],
    "credit-transfer-calculator" => %w[gpa-calculator college-cost-comparison-calculator final-grade-calculator],
    "tuition-savings-529-calculator" => %w[college-cost-comparison-calculator student-loan-calculator savings-goal-calculator],

    # ── Alcohol ───────────────────────────────────────────────────────────
    "abv-calculator" => %w[cocktail-abv-calculator ibu-calculator srm-beer-color-calculator],
    "ibu-calculator" => %w[abv-calculator srm-beer-color-calculator yeast-pitch-rate-calculator],
    "srm-beer-color-calculator" => %w[abv-calculator ibu-calculator yeast-pitch-rate-calculator],
    "strike-water-temperature-calculator" => %w[hydrometer-temperature-correction-calculator yeast-pitch-rate-calculator brix-to-gravity-refractometer-converter],
    "hydrometer-temperature-correction-calculator" => %w[brix-to-gravity-refractometer-converter abv-calculator strike-water-temperature-calculator],
    "brix-to-gravity-refractometer-converter" => %w[hydrometer-temperature-correction-calculator abv-calculator yeast-pitch-rate-calculator],
    "yeast-pitch-rate-calculator" => %w[abv-calculator priming-sugar-calculator strike-water-temperature-calculator],
    "priming-sugar-calculator" => %w[keg-force-carbonation-calculator abv-calculator yeast-pitch-rate-calculator],
    "keg-force-carbonation-calculator" => %w[priming-sugar-calculator pressure-converter abv-calculator],
    "distiller-proofing-dilution-calculator" => %w[abv-calculator cocktail-abv-calculator pour-cost-calculator],
    "cocktail-abv-calculator" => %w[abv-calculator bac-calculator alcohol-burnoff-calculator],
    "pour-cost-calculator" => %w[cocktail-abv-calculator profit-margin-calculator markup-margin-calculator],

    # ── Pets ──────────────────────────────────────────────────────────────
    "cat-age-calculator" => %w[dog-age-calculator cat-food-calculator pet-insurance-roi-calculator],
    "cat-food-calculator" => %w[dog-food-calculator cat-age-calculator pet-medication-dosage-calculator],
    "fish-tank-size-calculator" => %w[pool-volume-calculator volume-converter pet-cost-calculator],
    "pet-insurance-roi-calculator" => %w[pet-cost-calculator roi-calculator dog-food-calculator],
    "pet-medication-dosage-calculator" => %w[medication-dosage-calculator cat-food-calculator dog-food-calculator],
    "puppy-weight-predictor" => %w[dog-age-calculator dog-food-calculator cat-age-calculator],
    "horse-feed-calculator" => %w[dog-food-calculator cat-food-calculator weight-converter],

    # ── Gardening ─────────────────────────────────────────────────────────
    "mulch-calculator" => %w[gravel-mulch-calculator topsoil-calculator raised-bed-soil-calculator],
    "topsoil-calculator" => %w[mulch-calculator raised-bed-soil-calculator compost-calculator],
    "raised-bed-soil-calculator" => %w[topsoil-calculator compost-calculator mulch-calculator],
    "compost-calculator" => %w[fertilizer-calculator raised-bed-soil-calculator compost-ratio-calculator],
    "fertilizer-calculator" => %w[compost-calculator grass-seed-calculator plant-spacing-calculator],
    "grass-seed-calculator" => %w[lawn-watering-calculator fertilizer-calculator plant-spacing-calculator],
    "lawn-watering-calculator" => %w[grass-seed-calculator fertilizer-calculator water-intake-calculator],
    "plant-spacing-calculator" => %w[grass-seed-calculator mulch-calculator fertilizer-calculator],
    "growing-degree-days-calculator" => %w[plant-spacing-calculator grass-seed-calculator lawn-watering-calculator],
    "tree-age-calculator" => %w[age-calculator growing-degree-days-calculator dog-age-calculator],
    "greenhouse-heater-calculator" => %w[heat-loss-calculator heating-cost-calculator insulation-calculator],
    "compost-ratio-calculator" => %w[compost-calculator fertilizer-calculator mulch-calculator],

    # ── Geography ─────────────────────────────────────────────────────────
    "coordinate-distance-calculator" => %w[bearing-calculator midpoint-calculator rhumb-line-calculator],
    "latitude-longitude-converter" => %w[coordinate-distance-calculator bearing-calculator degrees-to-kilometers-converter],
    "bearing-calculator" => %w[coordinate-distance-calculator midpoint-calculator rhumb-line-calculator],
    "midpoint-calculator" => %w[coordinate-distance-calculator bearing-calculator destination-point-calculator],
    "map-scale-calculator" => %w[aspect-ratio-calculator length-converter area-calculator],
    "population-density-calculator" => %w[polygon-area-calculator area-calculator cost-of-living-calculator],
    "destination-point-calculator" => %w[bearing-calculator midpoint-calculator coordinate-distance-calculator],
    "antipode-calculator" => %w[coordinate-distance-calculator midpoint-calculator destination-point-calculator],
    "rhumb-line-calculator" => %w[coordinate-distance-calculator bearing-calculator flight-time-calculator],
    "polygon-area-calculator" => %w[area-calculator population-density-calculator map-scale-calculator],
    "hiking-time-calculator" => %w[pace-calculator flight-time-calculator running-pace-zone-calculator],
    "geohash-converter" => %w[coordinate-distance-calculator latitude-longitude-converter bearing-calculator],
    "degrees-to-kilometers-converter" => %w[coordinate-distance-calculator length-converter latitude-longitude-converter],
    "flight-time-calculator" => %w[hiking-time-calculator travel-budget-calculator coordinate-distance-calculator]
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
