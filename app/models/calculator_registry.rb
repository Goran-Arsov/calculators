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
