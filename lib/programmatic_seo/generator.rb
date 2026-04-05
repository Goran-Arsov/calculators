module ProgrammaticSeo
  module Generator
    # Which base calculators to expand and which patterns to apply.
    # The key is the base calculator slug (without "-calculator" suffix).
    # Only calculators with a form partial get the embedded form; others get a CTA link.
    EXPANSIONS = {
      # ── Everyday ──
      "fuel-cost" => {
        category: "everyday", controller: "fuel-cost-calculator",
        noun: "fuel cost", verb: "calculate fuel expenses",
        patterns: %i[per_km per_mile per_trip per_gallon per_liter per_month per_year per_day]
      },
      "tip" => {
        category: "everyday", controller: "tip-calculator",
        noun: "tip", verb: "calculate tips",
        patterns: %i[for_restaurant for_delivery for_hotel for_taxi for_buffet for_hairdresser for_movers for_valet]
      },
      "discount" => {
        category: "everyday", controller: "discount-calculator",
        noun: "discount", verb: "calculate discounts",
        patterns: %i[percent_off double_discount bulk_discount seasonal_sale employee_discount student_discount]
      },
      "electricity-bill" => {
        category: "everyday", controller: "electricity-bill-calculator",
        noun: "electricity cost", verb: "estimate electricity bills",
        patterns: %i[per_month per_day per_kwh per_appliance per_room per_year]
      },
      "fuel-cost-trip" => {
        category: "everyday", controller: "fuel-cost-trip-calculator",
        noun: "trip fuel cost", verb: "estimate trip fuel expenses",
        patterns: %i[road_trip cross_country commute round_trip one_way weekend_trip]
      },
      "unit-price" => {
        category: "everyday", controller: "unit-price-calculator",
        noun: "unit price", verb: "compare unit prices",
        patterns: %i[per_ounce per_pound per_liter per_serving grocery_comparison bulk_vs_regular]
      },

      # ── Finance ──
      "mortgage" => {
        category: "finance", controller: "mortgage-calculator",
        noun: "mortgage payment", verb: "calculate mortgage costs",
        patterns: %i[monthly_payment affordability refinance_savings interest_only down_payment amortization_breakdown]
      },
      "loan" => {
        category: "finance", controller: "loan-calculator",
        noun: "loan payment", verb: "calculate loan costs",
        patterns: %i[monthly_payment total_interest payoff_time early_payoff personal_loan debt_consolidation]
      },
      "compound-interest" => {
        category: "finance", controller: "compound-interest-calculator",
        noun: "compound interest", verb: "calculate compound growth",
        patterns: %i[daily weekly monthly quarterly annually continuous]
      },
      "salary" => {
        category: "finance", controller: "salary-calculator",
        noun: "salary", verb: "convert salary",
        patterns: %i[hourly_to_annual annual_to_hourly weekly_to_annual biweekly_to_annual monthly_to_hourly per_day]
      },
      "roi" => {
        category: "finance", controller: "roi-calculator",
        noun: "ROI", verb: "calculate return on investment",
        patterns: %i[real_estate stocks rental_property marketing small_business annualized]
      },
      "savings-goal" => {
        category: "finance", controller: "savings-goal-calculator",
        noun: "savings", verb: "plan savings goals",
        patterns: %i[emergency_fund vacation house_down_payment retirement college wedding]
      },
      "profit-margin" => {
        category: "finance", controller: "profit-margin-calculator",
        noun: "profit margin", verb: "calculate profit margins",
        patterns: %i[gross_margin net_margin operating_margin retail_markup food_cost ecommerce]
      },
      "break-even" => {
        category: "finance", controller: "break-even-calculator",
        noun: "break-even point", verb: "calculate break-even",
        patterns: %i[units revenue startup restaurant ecommerce freelance]
      },

      # ── Health ──
      "bmi" => {
        category: "health", controller: "bmi-calculator",
        noun: "BMI", verb: "calculate body mass index",
        patterns: %i[for_women for_men for_athletes for_seniors healthy_weight_range overweight_check]
      },
      "calorie" => {
        category: "health", controller: "calorie-calculator",
        noun: "calorie needs", verb: "calculate daily calories",
        patterns: %i[for_weight_loss for_muscle_gain for_maintenance for_pregnancy for_breastfeeding for_teenagers]
      },
      "tdee" => {
        category: "health", controller: "tdee-calculator",
        noun: "TDEE", verb: "calculate total daily energy expenditure",
        patterns: %i[for_cutting for_bulking sedentary_lifestyle active_lifestyle for_athletes for_weight_loss]
      },
      "macro" => {
        category: "health", controller: "macro-calculator",
        noun: "macros", verb: "calculate macro targets",
        patterns: %i[for_keto for_low_carb for_high_protein for_bodybuilding for_weight_loss balanced_diet]
      },
      "pace" => {
        category: "health", controller: "pace-calculator",
        noun: "pace", verb: "calculate running pace",
        patterns: %i[per_km per_mile for_5k for_10k for_half_marathon for_marathon]
      },
      "body-fat" => {
        category: "health", controller: "body-fat-calculator",
        noun: "body fat", verb: "estimate body fat percentage",
        patterns: %i[for_men for_women navy_method skinfold_method ideal_body_fat athlete_body_fat]
      },

      # ── Construction ──
      "concrete" => {
        category: "construction", controller: "concrete-calculator",
        noun: "concrete", verb: "calculate concrete needed",
        patterns: %i[for_slab for_footing for_wall for_column for_steps for_patio]
      },
      "paint" => {
        category: "construction", controller: "paint-calculator",
        noun: "paint", verb: "calculate paint needed",
        patterns: %i[for_room for_ceiling for_exterior for_fence for_deck for_trim]
      },
      "flooring" => {
        category: "construction", controller: "flooring-calculator",
        noun: "flooring", verb: "calculate flooring needed",
        patterns: %i[hardwood tile laminate vinyl carpet lvp]
      },
      "roofing" => {
        category: "construction", controller: "roofing-calculator",
        noun: "roofing materials", verb: "calculate roofing needs",
        patterns: %i[shingles metal_roof tile_roof flat_roof roof_replacement cost_per_square]
      },
      "deck" => {
        category: "construction", controller: "deck-calculator",
        noun: "deck materials", verb: "calculate deck materials",
        patterns: %i[composite wood pressure_treated trex cost_per_sqft railing]
      },

      # ── Math ──
      "percentage" => {
        category: "math", controller: "percentage-calculator",
        noun: "percentage", verb: "calculate percentages",
        patterns: %i[increase decrease difference of_a_number change reverse]
      },
      "area" => {
        category: "math", controller: "area-calculator",
        noun: "area", verb: "calculate area",
        patterns: %i[of_rectangle of_circle of_triangle of_trapezoid of_ellipse of_irregular_shape]
      },

      # ── Physics ──
      "unit-converter" => {
        category: "physics", controller: "unit-converter-calculator",
        noun: "units", verb: "convert units",
        patterns: %i[length_conversion weight_conversion temperature_conversion speed_conversion volume_conversion pressure_conversion]
      },
      "electricity-cost" => {
        category: "physics", controller: "electricity-cost-calculator",
        noun: "electricity cost", verb: "calculate electricity costs",
        patterns: %i[per_kwh per_appliance mining_rig ev_charging server_room space_heater]
      }
    }.freeze

    # Expansion pattern definitions — each pattern knows its slug suffix, title modifier, and content seeds
    PATTERNS = {
      # ── Per-unit patterns ──
      per_km:        { suffix: "per-km",        label: "Per Kilometer",     context: "per kilometer driven" },
      per_mile:      { suffix: "per-mile",      label: "Per Mile",          context: "per mile driven" },
      per_trip:      { suffix: "per-trip",       label: "Per Trip",          context: "for each trip" },
      per_gallon:    { suffix: "per-gallon",     label: "Per Gallon",        context: "per gallon of fuel" },
      per_liter:     { suffix: "per-liter",      label: "Per Liter",         context: "per liter of fuel" },
      per_month:     { suffix: "per-month",      label: "Per Month",         context: "on a monthly basis" },
      per_year:      { suffix: "per-year",       label: "Per Year",          context: "on an annual basis" },
      per_day:       { suffix: "per-day",        label: "Per Day",           context: "on a daily basis" },
      per_kwh:       { suffix: "per-kwh",        label: "Per kWh",           context: "per kilowatt-hour" },
      per_appliance: { suffix: "per-appliance",  label: "Per Appliance",     context: "for individual appliances" },
      per_room:      { suffix: "per-room",       label: "Per Room",          context: "for each room" },
      per_ounce:     { suffix: "per-ounce",      label: "Per Ounce",         context: "per ounce" },
      per_pound:     { suffix: "per-pound",      label: "Per Pound",         context: "per pound" },
      per_serving:   { suffix: "per-serving",    label: "Per Serving",       context: "per individual serving" },

      # ── For-audience patterns ──
      for_women:        { suffix: "for-women",       label: "for Women",        context: "with women-specific interpretation" },
      for_men:          { suffix: "for-men",         label: "for Men",          context: "with men-specific interpretation" },
      for_athletes:     { suffix: "for-athletes",    label: "for Athletes",     context: "adjusted for athletic body composition" },
      for_seniors:      { suffix: "for-seniors",     label: "for Seniors",      context: "with age-adjusted guidelines for adults 65+" },
      for_teenagers:    { suffix: "for-teenagers",   label: "for Teenagers",    context: "adjusted for adolescent growth needs" },
      for_pregnancy:    { suffix: "for-pregnancy",   label: "for Pregnancy",    context: "adjusted for pregnancy nutritional needs" },
      for_breastfeeding: { suffix: "for-breastfeeding", label: "for Breastfeeding", context: "adjusted for lactation caloric needs" },
      for_weight_loss:  { suffix: "for-weight-loss", label: "for Weight Loss",  context: "optimized for safe weight loss" },
      for_muscle_gain:  { suffix: "for-muscle-gain", label: "for Muscle Gain",  context: "optimized for muscle building" },
      for_maintenance:  { suffix: "for-maintenance", label: "for Maintenance",  context: "to maintain current weight" },
      for_cutting:      { suffix: "for-cutting",     label: "for Cutting",      context: "during a cutting phase" },
      for_bulking:      { suffix: "for-bulking",     label: "for Bulking",      context: "during a bulking phase" },
      for_keto:         { suffix: "for-keto",        label: "for Keto",         context: "following a ketogenic diet" },
      for_low_carb:     { suffix: "for-low-carb",    label: "for Low Carb",     context: "on a low-carbohydrate diet" },
      for_high_protein: { suffix: "for-high-protein", label: "for High Protein", context: "with high protein targets" },
      for_bodybuilding: { suffix: "for-bodybuilding", label: "for Bodybuilding", context: "tailored to bodybuilding goals" },
      balanced_diet:    { suffix: "balanced-diet",   label: "Balanced Diet",    context: "using balanced macronutrient ratios" },
      for_5k:           { suffix: "for-5k",          label: "for 5K",           context: "targeting a 5K race" },
      for_10k:          { suffix: "for-10k",         label: "for 10K",          context: "targeting a 10K race" },
      for_half_marathon: { suffix: "for-half-marathon", label: "for Half Marathon", context: "targeting a half marathon" },
      for_marathon:     { suffix: "for-marathon",    label: "for Marathon",     context: "targeting a marathon" },
      navy_method:      { suffix: "navy-method",     label: "Navy Method",      context: "using the U.S. Navy body fat formula" },
      skinfold_method:  { suffix: "skinfold-method", label: "Skinfold Method",  context: "using skinfold caliper measurements" },
      ideal_body_fat:   { suffix: "ideal-body-fat",  label: "Ideal Body Fat",   context: "to find your ideal body fat range" },
      athlete_body_fat: { suffix: "athlete-body-fat", label: "Athlete Body Fat", context: "for athletic performance targets" },
      sedentary_lifestyle: { suffix: "sedentary-lifestyle", label: "Sedentary Lifestyle", context: "for a sedentary lifestyle" },
      active_lifestyle: { suffix: "active-lifestyle", label: "Active Lifestyle", context: "for an active lifestyle" },
      healthy_weight_range: { suffix: "healthy-weight-range", label: "Healthy Weight Range", context: "to find your healthy weight range" },
      overweight_check: { suffix: "overweight-check", label: "Overweight Check", context: "for a quick overweight assessment" },

      # ── Purpose/scenario patterns ──
      for_restaurant:   { suffix: "for-restaurant",  label: "for Restaurant",   context: "at sit-down restaurants" },
      for_delivery:     { suffix: "for-delivery",    label: "for Delivery",     context: "for food delivery drivers" },
      for_hotel:        { suffix: "for-hotel",       label: "for Hotel",        context: "for hotel staff and services" },
      for_taxi:         { suffix: "for-taxi",        label: "for Taxi",         context: "for taxi and rideshare drivers" },
      for_buffet:       { suffix: "for-buffet",      label: "for Buffet",       context: "at buffet-style restaurants" },
      for_hairdresser:  { suffix: "for-hairdresser", label: "for Hairdresser",  context: "at hair salons and barbershops" },
      for_movers:       { suffix: "for-movers",      label: "for Movers",       context: "when hiring moving services" },
      for_valet:        { suffix: "for-valet",       label: "for Valet",        context: "for valet parking attendants" },
      road_trip:        { suffix: "road-trip",       label: "Road Trip",        context: "for planning road trips" },
      cross_country:    { suffix: "cross-country",   label: "Cross Country",    context: "for cross-country drives" },
      commute:          { suffix: "commute",         label: "Commute",          context: "for daily commuting" },
      round_trip:       { suffix: "round-trip",      label: "Round Trip",       context: "for round-trip journeys" },
      one_way:          { suffix: "one-way",         label: "One Way",          context: "for one-way trips" },
      weekend_trip:     { suffix: "weekend-trip",    label: "Weekend Trip",     context: "for weekend getaways" },

      # ── Discount patterns ──
      percent_off:      { suffix: "percent-off",     label: "Percent Off",      context: "to find sale prices after percentage discounts" },
      double_discount:  { suffix: "double-discount", label: "Double Discount",  context: "when stacking multiple discounts" },
      bulk_discount:    { suffix: "bulk-discount",   label: "Bulk Discount",    context: "for quantity-based bulk pricing" },
      seasonal_sale:    { suffix: "seasonal-sale",   label: "Seasonal Sale",    context: "during seasonal clearance events" },
      employee_discount: { suffix: "employee-discount", label: "Employee Discount", context: "for employee pricing programs" },
      student_discount: { suffix: "student-discount", label: "Student Discount", context: "with student discount eligibility" },

      # ── Grocery/comparison patterns ──
      grocery_comparison: { suffix: "grocery-comparison", label: "Grocery Comparison", context: "for comparing grocery prices" },
      bulk_vs_regular:  { suffix: "bulk-vs-regular", label: "Bulk vs Regular",  context: "to compare bulk and regular sizes" },

      # ── Finance patterns ──
      monthly_payment:  { suffix: "monthly-payment", label: "Monthly Payment",  context: "to calculate monthly payments" },
      total_interest:   { suffix: "total-interest",  label: "Total Interest",   context: "to see total interest paid" },
      payoff_time:      { suffix: "payoff-time",     label: "Payoff Time",      context: "to estimate payoff timeline" },
      early_payoff:     { suffix: "early-payoff",    label: "Early Payoff",     context: "with extra payments for early payoff" },
      personal_loan:    { suffix: "personal-loan",   label: "Personal Loan",    context: "for personal loan calculations" },
      debt_consolidation: { suffix: "debt-consolidation", label: "Debt Consolidation", context: "for debt consolidation scenarios" },
      affordability:    { suffix: "affordability",   label: "Affordability",    context: "to determine what you can afford" },
      refinance_savings: { suffix: "refinance-savings", label: "Refinance Savings", context: "to estimate refinancing savings" },
      interest_only:    { suffix: "interest-only",   label: "Interest Only",    context: "for interest-only payment scenarios" },
      down_payment:     { suffix: "down-payment",    label: "Down Payment",     context: "to plan your down payment" },
      amortization_breakdown: { suffix: "amortization-breakdown", label: "Amortization Breakdown", context: "to view the full amortization schedule" },
      daily:            { suffix: "daily",           label: "Daily",            context: "with daily compounding" },
      weekly:           { suffix: "weekly",          label: "Weekly",           context: "with weekly compounding" },
      monthly:          { suffix: "monthly",         label: "Monthly",          context: "with monthly compounding" },
      quarterly:        { suffix: "quarterly",       label: "Quarterly",        context: "with quarterly compounding" },
      annually:         { suffix: "annually",        label: "Annually",         context: "with annual compounding" },
      continuous:       { suffix: "continuous",       label: "Continuous",       context: "with continuous compounding" },
      hourly_to_annual: { suffix: "hourly-to-annual", label: "Hourly to Annual", context: "converting hourly wage to annual salary" },
      annual_to_hourly: { suffix: "annual-to-hourly", label: "Annual to Hourly", context: "converting annual salary to hourly rate" },
      weekly_to_annual: { suffix: "weekly-to-annual", label: "Weekly to Annual", context: "converting weekly pay to annual salary" },
      biweekly_to_annual: { suffix: "biweekly-to-annual", label: "Biweekly to Annual", context: "converting biweekly pay to annual salary" },
      monthly_to_hourly: { suffix: "monthly-to-hourly", label: "Monthly to Hourly", context: "converting monthly salary to hourly rate" },
      real_estate:      { suffix: "real-estate",     label: "Real Estate",      context: "for real estate investments" },
      stocks:           { suffix: "stocks",          label: "Stocks",           context: "for stock market investments" },
      rental_property:  { suffix: "rental-property", label: "Rental Property",  context: "for rental property returns" },
      marketing:        { suffix: "marketing",       label: "Marketing",        context: "for marketing campaign ROI" },
      small_business:   { suffix: "small-business",  label: "Small Business",   context: "for small business investments" },
      annualized:       { suffix: "annualized",      label: "Annualized",       context: "as an annualized return rate" },
      emergency_fund:   { suffix: "emergency-fund",  label: "Emergency Fund",   context: "for building an emergency fund" },
      vacation:         { suffix: "vacation",        label: "Vacation",         context: "for saving for a vacation" },
      house_down_payment: { suffix: "house-down-payment", label: "House Down Payment", context: "for saving a house down payment" },
      retirement:       { suffix: "retirement",      label: "Retirement",       context: "for retirement savings" },
      college:          { suffix: "college",         label: "College",          context: "for college tuition savings" },
      wedding:          { suffix: "wedding",         label: "Wedding",          context: "for saving for a wedding" },
      gross_margin:     { suffix: "gross-margin",    label: "Gross Margin",     context: "to calculate gross profit margin" },
      net_margin:       { suffix: "net-margin",      label: "Net Margin",       context: "to calculate net profit margin" },
      operating_margin: { suffix: "operating-margin", label: "Operating Margin", context: "to calculate operating margin" },
      retail_markup:    { suffix: "retail-markup",   label: "Retail Markup",    context: "for retail markup pricing" },
      food_cost:        { suffix: "food-cost",       label: "Food Cost",        context: "for restaurant food cost analysis" },
      ecommerce:        { suffix: "ecommerce",       label: "Ecommerce",        context: "for ecommerce businesses" },
      units:            { suffix: "units",           label: "Units",            context: "in units sold" },
      revenue:          { suffix: "revenue",         label: "Revenue",          context: "in revenue dollars" },
      startup:          { suffix: "startup",         label: "Startup",          context: "for startup businesses" },
      restaurant:       { suffix: "restaurant",      label: "Restaurant",       context: "for restaurant businesses" },
      freelance:        { suffix: "freelance",       label: "Freelance",        context: "for freelance businesses" },

      # ── Construction patterns ──
      for_slab:         { suffix: "for-slab",        label: "for Slab",         context: "for concrete slabs and driveways" },
      for_footing:      { suffix: "for-footing",     label: "for Footing",      context: "for foundation footings" },
      for_wall:         { suffix: "for-wall",        label: "for Wall",         context: "for poured concrete walls" },
      for_column:       { suffix: "for-column",      label: "for Column",       context: "for round and square columns" },
      for_steps:        { suffix: "for-steps",       label: "for Steps",        context: "for concrete stairs and steps" },
      for_patio:        { suffix: "for-patio",       label: "for Patio",        context: "for outdoor patios" },
      for_room:         { suffix: "for-room",        label: "for Room",         context: "for interior rooms" },
      for_ceiling:      { suffix: "for-ceiling",     label: "for Ceiling",      context: "for ceiling surfaces" },
      for_exterior:     { suffix: "for-exterior",    label: "for Exterior",     context: "for exterior surfaces" },
      for_fence:        { suffix: "for-fence",       label: "for Fence",        context: "for fence painting or staining" },
      for_deck:         { suffix: "for-deck",        label: "for Deck",         context: "for deck staining or painting" },
      for_trim:         { suffix: "for-trim",        label: "for Trim",         context: "for trim and molding" },
      hardwood:         { suffix: "hardwood",        label: "Hardwood",         context: "for hardwood flooring" },
      tile:             { suffix: "tile",            label: "Tile",             context: "for tile flooring" },
      laminate:         { suffix: "laminate",        label: "Laminate",         context: "for laminate flooring" },
      vinyl:            { suffix: "vinyl",           label: "Vinyl",            context: "for vinyl flooring" },
      carpet:           { suffix: "carpet",          label: "Carpet",           context: "for carpet flooring" },
      lvp:              { suffix: "lvp",             label: "LVP",              context: "for luxury vinyl plank flooring" },
      shingles:         { suffix: "shingles",        label: "Shingles",         context: "for asphalt shingle roofing" },
      metal_roof:       { suffix: "metal-roof",      label: "Metal Roof",       context: "for metal roofing" },
      tile_roof:        { suffix: "tile-roof",       label: "Tile Roof",        context: "for tile roofing" },
      flat_roof:        { suffix: "flat-roof",       label: "Flat Roof",        context: "for flat roof systems" },
      roof_replacement: { suffix: "roof-replacement", label: "Roof Replacement", context: "for full roof replacement" },
      cost_per_square:  { suffix: "cost-per-square", label: "Cost Per Square",  context: "to estimate cost per roofing square" },
      composite:        { suffix: "composite",       label: "Composite",        context: "for composite decking" },
      wood:             { suffix: "wood",            label: "Wood",             context: "for natural wood decking" },
      pressure_treated: { suffix: "pressure-treated", label: "Pressure Treated", context: "for pressure-treated lumber decking" },
      trex:             { suffix: "trex",            label: "Trex",             context: "for Trex composite decking" },
      cost_per_sqft:    { suffix: "cost-per-sqft",   label: "Cost Per Sq Ft",   context: "to estimate cost per square foot" },
      railing:          { suffix: "railing",         label: "Railing",          context: "for deck railing materials" },

      # ── Math patterns ──
      increase:         { suffix: "increase",        label: "Increase",         context: "to calculate percentage increase" },
      decrease:         { suffix: "decrease",        label: "Decrease",         context: "to calculate percentage decrease" },
      difference:       { suffix: "difference",      label: "Difference",       context: "to find percentage difference between values" },
      of_a_number:      { suffix: "of-a-number",     label: "of a Number",      context: "to find a percentage of any number" },
      change:           { suffix: "change",          label: "Change",           context: "to calculate percentage change" },
      reverse:          { suffix: "reverse",         label: "Reverse",          context: "to reverse-calculate the original value" },
      of_rectangle:     { suffix: "of-rectangle",    label: "of Rectangle",     context: "for rectangles and squares" },
      of_circle:        { suffix: "of-circle",       label: "of Circle",        context: "for circles" },
      of_triangle:      { suffix: "of-triangle",     label: "of Triangle",      context: "for triangles" },
      of_trapezoid:     { suffix: "of-trapezoid",    label: "of Trapezoid",     context: "for trapezoids" },
      of_ellipse:       { suffix: "of-ellipse",      label: "of Ellipse",       context: "for ellipses" },
      of_irregular_shape: { suffix: "of-irregular-shape", label: "of Irregular Shape", context: "for irregular shapes" },

      # ── Physics patterns ──
      length_conversion: { suffix: "length",         label: "Length",           context: "for length and distance units" },
      weight_conversion: { suffix: "weight",         label: "Weight",           context: "for weight and mass units" },
      temperature_conversion: { suffix: "temperature", label: "Temperature",   context: "for temperature units" },
      speed_conversion: { suffix: "speed",           label: "Speed",            context: "for speed and velocity units" },
      volume_conversion: { suffix: "volume",         label: "Volume",           context: "for volume and capacity units" },
      pressure_conversion: { suffix: "pressure",     label: "Pressure",         context: "for pressure units" },
      mining_rig:       { suffix: "mining-rig",      label: "Mining Rig",       context: "for cryptocurrency mining rigs" },
      ev_charging:      { suffix: "ev-charging",     label: "EV Charging",      context: "for electric vehicle charging" },
      server_room:      { suffix: "server-room",     label: "Server Room",      context: "for server room power costs" },
      space_heater:     { suffix: "space-heater",    label: "Space Heater",     context: "for space heater electricity costs" }
    }.freeze
  end
end
