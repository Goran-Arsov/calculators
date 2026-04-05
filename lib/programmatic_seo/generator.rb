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
      "age" => {
        category: "everyday", controller: "age-calculator",
        noun: "age", verb: "calculate exact age",
        patterns: %i[in_days in_weeks in_months exact_age birthday_countdown zodiac_sign]
      },
      "date-difference" => {
        category: "everyday", controller: "date-difference-calculator",
        noun: "date difference", verb: "calculate days between dates",
        patterns: %i[in_days_diff in_weeks_diff in_months_diff business_days_diff workdays_between countdown_to_date]
      },
      "gas-mileage" => {
        category: "everyday", controller: "gas-mileage-calculator",
        noun: "gas mileage", verb: "calculate fuel economy",
        patterns: %i[mpg_calc liters_per_100km km_per_liter fuel_efficiency mpg_comparison improve_mpg]
      },
      "gpa" => {
        category: "everyday", controller: "gpa-calculator",
        noun: "GPA", verb: "calculate grade point average",
        patterns: %i[weighted_gpa unweighted_gpa cumulative_gpa semester_gpa college_gpa high_school_gpa]
      },
      "cooking-converter" => {
        category: "everyday", controller: "cooking-converter",
        noun: "cooking measurement", verb: "convert cooking units",
        patterns: %i[cups_to_grams tablespoons_to_ml ounces_to_grams fahrenheit_to_celsius metric_cooking imperial_cooking]
      },
      "moving-cost" => {
        category: "everyday", controller: "moving-cost-calculator",
        noun: "moving cost", verb: "estimate moving expenses",
        patterns: %i[local_move long_distance_move cross_country_move apartment_move house_move by_bedroom_count]
      },
      "bandwidth" => {
        category: "everyday", controller: "bandwidth-calculator",
        noun: "bandwidth", verb: "calculate internet speed needs",
        patterns: %i[download_time upload_speed streaming_bandwidth gaming_bandwidth required_speed data_usage]
      },
      "screen-size" => {
        category: "everyday", controller: "screen-size-calculator",
        noun: "screen size", verb: "calculate display dimensions",
        patterns: %i[by_diagonal tv_size monitor_size viewing_distance ppi_calc resolution_calc]
      },
      "grade" => {
        category: "everyday", controller: "grade-calculator",
        noun: "grade", verb: "calculate weighted grades",
        patterns: %i[final_grade weighted_average final_exam_needed letter_grade pass_fail extra_credit]
      },
      "password-strength" => {
        category: "everyday", controller: "password-strength-calculator",
        noun: "password strength", verb: "check password security",
        patterns: %i[entropy_calc crack_time strong_password passphrase for_business best_practices]
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
      "investment" => {
        category: "finance", controller: "investment-calculator",
        noun: "investment returns", verb: "project investment growth",
        patterns: %i[for_stocks for_bonds for_real_estate monthly_contribution lump_sum for_retirement]
      },
      "retirement" => {
        category: "finance", controller: "retirement-calculator",
        noun: "retirement savings", verb: "plan retirement",
        patterns: %i[early_retirement at_55 at_60 at_65 retirement_income savings_needed]
      },
      "debt-payoff" => {
        category: "finance", controller: "debt-payoff-calculator",
        noun: "debt payoff", verb: "plan debt repayment",
        patterns: %i[snowball_method avalanche_method minimum_payment extra_payment credit_card_debt student_loan_debt]
      },
      "tax-bracket" => {
        category: "finance", controller: "tax-bracket-calculator",
        noun: "tax bracket", verb: "determine tax bracket",
        patterns: %i[federal_tax married_filing single_filer head_of_household self_employed_tax capital_gains_tax]
      },
      "auto-loan" => {
        category: "finance", controller: "auto-loan-calculator",
        noun: "auto loan", verb: "calculate car payments",
        patterns: %i[new_car used_car refinance_auto lease_vs_buy with_trade_in with_down_payment]
      },
      "credit-card-payoff" => {
        category: "finance", controller: "credit-card-payoff-calculator",
        noun: "credit card payoff", verb: "plan credit card repayment",
        patterns: %i[minimum_payment fixed_payment balance_transfer debt_free_date interest_saved payoff_strategy]
      },
      "student-loan" => {
        category: "finance", controller: "student-loan-calculator",
        noun: "student loan", verb: "calculate student loan payments",
        patterns: %i[standard_repayment income_driven refinance_student public_service loan_forgiveness grad_school]
      },
      "net-worth" => {
        category: "finance", controller: "net-worth-calculator",
        noun: "net worth", verb: "calculate net worth",
        patterns: %i[by_age millionaire_target average_net_worth for_retirement financial_independence debt_ratio]
      },
      "paycheck" => {
        category: "finance", controller: "paycheck-calculator",
        noun: "paycheck", verb: "calculate take-home pay",
        patterns: %i[hourly_paycheck salary_paycheck biweekly_paycheck after_tax with_overtime with_bonus]
      },
      "home-affordability" => {
        category: "finance", controller: "home-affordability-calculator",
        noun: "home affordability", verb: "determine housing budget",
        patterns: %i[by_income by_monthly_payment fha_loan va_loan_home first_time_buyer with_student_loans_home]
      },
      "four-oh-one-k" => {
        category: "finance", controller: "four-oh-one-k-calculator",
        noun: "401(k) savings", verb: "project 401(k) growth",
        patterns: %i[employer_match max_contribution catch_up_contribution roth_vs_traditional early_withdrawal retirement_projection]
      },
      "stock-profit" => {
        category: "finance", controller: "stock-profit-calculator",
        noun: "stock profit", verb: "calculate trading profit",
        patterns: %i[capital_gains short_term_gains long_term_gains with_dividends options_profit day_trading]
      },
      "crypto-profit" => {
        category: "finance", controller: "crypto-profit-calculator",
        noun: "crypto profit", verb: "calculate crypto gains",
        patterns: %i[bitcoin_profit ethereum_profit altcoin_profit defi_yield staking_rewards mining_profit]
      },
      "inflation" => {
        category: "finance", controller: "inflation-calculator",
        noun: "inflation impact", verb: "calculate inflation effects",
        patterns: %i[purchasing_power future_value_inflation salary_adjustment retirement_inflation historical_inflation cost_of_living_adj]
      },
      "cd" => {
        category: "finance", controller: "cd-calculator",
        noun: "CD returns", verb: "calculate CD earnings",
        patterns: %i[six_month_cd one_year_cd two_year_cd five_year_cd cd_ladder apy_comparison]
      },
      "savings-interest" => {
        category: "finance", controller: "savings-interest-calculator",
        noun: "savings interest", verb: "calculate savings growth",
        patterns: %i[high_yield_savings money_market_savings compound_daily_savings compound_monthly_savings with_regular_deposits goal_based_savings]
      },
      "house-flip" => {
        category: "finance", controller: "house-flip-calculator",
        noun: "house flip profit", verb: "estimate flip returns",
        patterns: %i[profit_estimate renovation_cost after_repair_value seventy_percent_rule holding_cost flip_roi]
      },
      "dividend-yield" => {
        category: "finance", controller: "dividend-yield-calculator",
        noun: "dividend yield", verb: "calculate dividend income",
        patterns: %i[annual_dividend monthly_dividend yield_on_cost drip_calculator dividend_portfolio high_dividend]
      },
      "dca" => {
        category: "finance", controller: "dca-calculator",
        noun: "DCA returns", verb: "calculate dollar-cost averaging",
        patterns: %i[weekly_dca monthly_dca bitcoin_dca sp500_dca etf_dca long_term_dca]
      },
      "solar-savings" => {
        category: "finance", controller: "solar-savings-calculator",
        noun: "solar savings", verb: "estimate solar panel savings",
        patterns: %i[payback_period monthly_solar_savings annual_solar_savings solar_roi solar_tax_credit panel_cost_estimate]
      },
      "business-loan" => {
        category: "finance", controller: "business-loan-calculator",
        noun: "business loan", verb: "calculate business financing",
        patterns: %i[sba_loan term_loan line_of_credit equipment_loan startup_loan working_capital]
      },
      "rent-vs-buy" => {
        category: "finance", controller: "rent-vs-buy-calculator",
        noun: "rent vs buy", verb: "compare renting and buying",
        patterns: %i[five_year_comparison ten_year_comparison break_even_rent_buy tax_benefit_owning investment_alternative monthly_cost_comparison]
      },
      "amortization" => {
        category: "finance", controller: "amortization-calculator",
        noun: "amortization schedule", verb: "generate amortization tables",
        patterns: %i[monthly_amortization biweekly_amortization with_extra_payments balloon_payment interest_only_amort printable_schedule]
      },
      "markup-margin" => {
        category: "finance", controller: "markup-margin-calculator",
        noun: "markup and margin", verb: "convert markup to margin",
        patterns: %i[wholesale_to_retail food_markup service_markup keystone_pricing cost_plus_pricing target_margin]
      },
      "estate-tax" => {
        category: "finance", controller: "estate-tax-calculator",
        noun: "estate tax", verb: "estimate estate taxes",
        patterns: %i[federal_estate estate_exemption married_estate trust_estate inheritance_tax gift_tax]
      },
      "currency-converter" => {
        category: "finance", controller: "currency-converter-calculator",
        noun: "currency exchange", verb: "convert currencies",
        patterns: %i[usd_to_eur usd_to_gbp usd_to_jpy usd_to_cad usd_to_aud usd_to_inr]
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
      "water-intake" => {
        category: "health", controller: "water-intake-calculator",
        noun: "water intake", verb: "calculate daily water needs",
        patterns: %i[by_weight for_athletes_water during_pregnancy_water in_hot_weather for_children for_elderly]
      },
      "sleep" => {
        category: "health", controller: "sleep-calculator",
        noun: "sleep schedule", verb: "calculate optimal sleep times",
        patterns: %i[bedtime_calc wake_up_calc for_shift_workers for_teenagers_sleep for_babies nap_time]
      },
      "one-rep-max" => {
        category: "health", controller: "one-rep-max-calculator",
        noun: "one rep max", verb: "estimate 1RM strength",
        patterns: %i[bench_press squat_1rm deadlift_1rm overhead_press by_reps epley_formula]
      },
      "ideal-weight" => {
        category: "health", controller: "ideal-weight-calculator",
        noun: "ideal weight", verb: "calculate ideal body weight",
        patterns: %i[by_height for_men_weight for_women_weight by_frame_size for_athletes_weight for_seniors_weight]
      },
      "bac" => {
        category: "health", controller: "bac-calculator",
        noun: "blood alcohol", verb: "estimate blood alcohol content",
        patterns: %i[by_body_weight by_drinks over_time driving_limit sobering_up_time by_gender]
      },
      "heart-rate-zone" => {
        category: "health", controller: "heart-rate-zone-calculator",
        noun: "heart rate zones", verb: "calculate training zones",
        patterns: %i[fat_burning_zone cardio_zone peak_zone for_running_hr for_cycling_hr by_age_hr]
      },
      "keto" => {
        category: "health", controller: "keto-calculator",
        noun: "keto macros", verb: "calculate keto diet macros",
        patterns: %i[standard_keto targeted_keto cyclical_keto keto_weight_loss keto_beginners keto_for_women]
      },
      "intermittent-fasting" => {
        category: "health", controller: "intermittent-fasting-calculator",
        noun: "fasting schedule", verb: "plan intermittent fasting",
        patterns: %i[sixteen_eight five_two omad_fasting fasting_weight_loss fasting_beginners fasting_for_women]
      },
      "pregnancy-due-date" => {
        category: "health", controller: "pregnancy-due-date-calculator",
        noun: "due date", verb: "calculate pregnancy due date",
        patterns: %i[by_lmp by_conception_date by_ivf_transfer by_ultrasound trimester_dates week_by_week]
      },
      "dog-age" => {
        category: "health", controller: "dog-age-calculator",
        noun: "dog age", verb: "convert dog years",
        patterns: %i[by_breed_size small_dog_age medium_dog_age large_dog_age puppy_age senior_dog_age]
      },
      "dog-food" => {
        category: "health", controller: "dog-food-calculator",
        noun: "dog food amount", verb: "calculate dog feeding",
        patterns: %i[by_dog_weight by_breed_food puppy_food senior_dog_food active_dog raw_diet]
      },
      "blood-pressure" => {
        category: "health", controller: "blood-pressure-calculator",
        noun: "blood pressure", verb: "check blood pressure category",
        patterns: %i[by_age_bp normal_range_bp high_bp low_bp pregnancy_bp senior_bp]
      },
      "ovulation" => {
        category: "health", controller: "ovulation-calculator",
        noun: "ovulation date", verb: "predict ovulation",
        patterns: %i[by_cycle_length irregular_cycle fertile_window best_conception_time after_miscarriage with_pcos]
      },
      "lean-body-mass" => {
        category: "health", controller: "lean-body-mass-calculator",
        noun: "lean body mass", verb: "calculate lean mass",
        patterns: %i[for_men_lbm for_women_lbm for_bodybuilding_lbm by_body_fat_lbm boer_formula james_formula]
      },
      "conception" => {
        category: "health", controller: "conception-calculator",
        noun: "conception date", verb: "estimate conception date",
        patterns: %i[by_due_date_conception by_lmp_conception ivf_conception fertile_window_conception gender_calendar after_birth_control]
      },
      "pregnancy-week" => {
        category: "health", controller: "pregnancy-week-calculator",
        noun: "pregnancy week", verb: "track pregnancy progress",
        patterns: %i[first_trimester second_trimester third_trimester baby_size_week symptoms_week development_week]
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
      "gravel-mulch" => {
        category: "construction", controller: "gravel-mulch-calculator",
        noun: "gravel and mulch", verb: "calculate landscaping materials",
        patterns: %i[for_driveway_gravel for_garden_mulch for_walkway for_landscaping by_cubic_yard by_ton]
      },
      "fence" => {
        category: "construction", controller: "fence-calculator",
        noun: "fence materials", verb: "calculate fencing needs",
        patterns: %i[wood_fence chain_link_fence vinyl_fence privacy_fence picket_fence cost_per_linear_foot]
      },
      "staircase" => {
        category: "construction", controller: "staircase-calculator",
        noun: "staircase dimensions", verb: "calculate stair measurements",
        patterns: %i[interior_stairs exterior_stairs deck_stairs spiral_staircase code_compliant rise_and_run]
      },
      "wallpaper" => {
        category: "construction", controller: "wallpaper-calculator",
        noun: "wallpaper", verb: "calculate wallpaper needed",
        patterns: %i[by_room_wallpaper by_roll with_pattern_repeat accent_wall bathroom_wallpaper bedroom_wallpaper]
      },
      "tile" => {
        category: "construction", controller: "tile-calculator",
        noun: "tile", verb: "calculate tiles needed",
        patterns: %i[bathroom_tile kitchen_backsplash shower_tile floor_tile wall_tile mosaic_tile]
      },
      "lumber" => {
        category: "construction", controller: "lumber-calculator",
        noun: "lumber", verb: "calculate lumber needed",
        patterns: %i[board_feet framing_lumber decking_lumber fencing_lumber plywood cost_estimate_lumber]
      },
      "hvac-btu" => {
        category: "construction", controller: "hvac-btu-calculator",
        noun: "HVAC BTU", verb: "calculate heating and cooling needs",
        patterns: %i[by_room_size by_square_footage heating_btu cooling_btu mini_split central_air]
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
      "fraction" => {
        category: "math", controller: "fraction-calculator",
        noun: "fraction", verb: "calculate fractions",
        patterns: %i[add_fractions subtract_fractions multiply_fractions divide_fractions simplify_fraction mixed_number]
      },
      "standard-deviation" => {
        category: "math", controller: "standard-deviation-calculator",
        noun: "standard deviation", verb: "calculate statistical spread",
        patterns: %i[population_sd sample_sd for_data_set with_mean variance_calc for_statistics]
      },
      "probability" => {
        category: "math", controller: "probability-calculator",
        noun: "probability", verb: "calculate probability",
        patterns: %i[single_event multiple_events conditional_prob binomial_prob normal_distribution dice_probability]
      },
      "logarithm" => {
        category: "math", controller: "logarithm-calculator",
        noun: "logarithm", verb: "calculate logarithms",
        patterns: %i[natural_log log_base_10 log_base_2 change_of_base antilog log_equations]
      },
      "pythagorean" => {
        category: "math", controller: "pythagorean-calculator",
        noun: "right triangle", verb: "solve right triangles",
        patterns: %i[find_hypotenuse find_missing_side distance_formula pythagorean_proof three_d_distance real_world_pythagorean]
      },
      "circumference" => {
        category: "math", controller: "circumference-calculator",
        noun: "circle measurements", verb: "calculate circle properties",
        patterns: %i[from_radius from_diameter from_area arc_length sector_area circle_area]
      },

      # ── Physics ──
      "unit-converter" => {
        category: "physics", controller: "unit-converter",
        noun: "units", verb: "convert units",
        patterns: %i[length_conversion weight_conversion temperature_conversion speed_conversion volume_conversion pressure_conversion]
      },
      "electricity-cost" => {
        category: "physics", controller: "electricity-cost-calculator",
        noun: "electricity cost", verb: "calculate electricity costs",
        patterns: %i[per_kwh per_appliance mining_rig ev_charging server_room space_heater]
      },
      "velocity" => {
        category: "physics", controller: "velocity-calculator",
        noun: "velocity", verb: "calculate speed and motion",
        patterns: %i[find_speed find_distance find_time average_velocity final_velocity initial_velocity]
      },
      "force" => {
        category: "physics", controller: "force-calculator",
        noun: "force", verb: "calculate force",
        patterns: %i[find_force find_mass find_acceleration friction_force gravitational_force net_force]
      },
      "ohms-law" => {
        category: "physics", controller: "ohms-law-calculator",
        noun: "electrical values", verb: "calculate electrical properties",
        patterns: %i[find_voltage find_current find_resistance power_calc series_circuit parallel_circuit]
      },
      "kinetic-energy" => {
        category: "physics", controller: "kinetic-energy-calculator",
        noun: "kinetic energy", verb: "calculate energy of motion",
        patterns: %i[from_mass_velocity in_joules potential_to_kinetic work_energy momentum_calc rotational_energy]
      },
      "decibel" => {
        category: "physics", controller: "decibel-calculator",
        noun: "decibel level", verb: "calculate sound levels",
        patterns: %i[sound_level noise_reduction distance_db power_ratio_db voltage_ratio_db db_addition]
      },
      "projectile-motion" => {
        category: "physics", controller: "projectile-motion-calculator",
        noun: "projectile motion", verb: "calculate projectile trajectory",
        patterns: %i[max_height max_range flight_time launch_angle landing_velocity horizontal_distance]
      },
      "heat-transfer" => {
        category: "physics", controller: "heat-transfer-calculator",
        noun: "heat transfer", verb: "calculate thermal energy flow",
        patterns: %i[conduction convection radiation through_wall insulation_r_value heat_loss]
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

      # ── Finance: Investment patterns ──
      for_stocks:           { suffix: "for-stocks",           label: "for Stocks",           context: "for stock market investments" },
      for_bonds:            { suffix: "for-bonds",            label: "for Bonds",            context: "for bond investments" },
      for_real_estate:      { suffix: "for-real-estate",      label: "for Real Estate",      context: "for real estate investments" },
      monthly_contribution: { suffix: "monthly-contribution", label: "Monthly Contribution", context: "with regular monthly contributions" },
      lump_sum:             { suffix: "lump-sum",             label: "Lump Sum",             context: "for a one-time lump sum investment" },
      for_retirement:       { suffix: "for-retirement",       label: "for Retirement",       context: "for retirement planning" },

      # ── Finance: Retirement patterns ──
      early_retirement:     { suffix: "early-retirement",     label: "Early Retirement",     context: "for early retirement planning" },
      at_55:                { suffix: "at-55",                label: "at 55",                context: "for retiring at age 55" },
      at_60:                { suffix: "at-60",                label: "at 60",                context: "for retiring at age 60" },
      at_65:                { suffix: "at-65",                label: "at 65",                context: "for retiring at age 65" },
      retirement_income:    { suffix: "retirement-income",    label: "Retirement Income",    context: "to estimate retirement income needs" },
      savings_needed:       { suffix: "savings-needed",       label: "Savings Needed",       context: "to determine how much savings you need" },

      # ── Finance: Debt payoff patterns ──
      snowball_method:      { suffix: "snowball-method",      label: "Snowball Method",      context: "using the debt snowball method (smallest balance first)" },
      avalanche_method:     { suffix: "avalanche-method",     label: "Avalanche Method",     context: "using the debt avalanche method (highest interest first)" },
      minimum_payment:      { suffix: "minimum-payment",      label: "Minimum Payment",      context: "with minimum payments only" },
      extra_payment:        { suffix: "extra-payment",        label: "Extra Payment",        context: "with extra payments toward principal" },
      credit_card_debt:     { suffix: "credit-card-debt",     label: "Credit Card Debt",     context: "for credit card debt payoff" },
      student_loan_debt:    { suffix: "student-loan-debt",    label: "Student Loan Debt",    context: "for student loan debt payoff" },

      # ── Finance: Tax bracket patterns ──
      federal_tax:          { suffix: "federal-tax",          label: "Federal Tax",          context: "for federal income tax brackets" },
      married_filing:       { suffix: "married-filing",       label: "Married Filing",       context: "for married filing jointly status" },
      single_filer:         { suffix: "single-filer",         label: "Single Filer",         context: "for single filing status" },
      head_of_household:    { suffix: "head-of-household",    label: "Head of Household",    context: "for head of household filing status" },
      self_employed_tax:    { suffix: "self-employed-tax",    label: "Self-Employed Tax",    context: "for self-employment tax calculations" },
      capital_gains_tax:    { suffix: "capital-gains-tax",    label: "Capital Gains Tax",    context: "for capital gains tax rates" },

      # ── Finance: Auto loan patterns ──
      new_car:              { suffix: "new-car",              label: "New Car",              context: "for new car financing" },
      used_car:             { suffix: "used-car",             label: "Used Car",             context: "for used car financing" },
      refinance_auto:       { suffix: "refinance-auto",       label: "Refinance Auto",       context: "for auto loan refinancing" },
      lease_vs_buy:         { suffix: "lease-vs-buy",         label: "Lease vs Buy",         context: "to compare leasing versus buying a car" },
      with_trade_in:        { suffix: "with-trade-in",        label: "with Trade-In",        context: "with a vehicle trade-in" },
      with_down_payment:    { suffix: "with-down-payment",    label: "with Down Payment",    context: "with a down payment" },

      # ── Finance: Credit card payoff patterns ──
      fixed_payment:        { suffix: "fixed-payment",        label: "Fixed Payment",        context: "with a fixed monthly payment amount" },
      balance_transfer:     { suffix: "balance-transfer",     label: "Balance Transfer",     context: "using a balance transfer offer" },
      debt_free_date:       { suffix: "debt-free-date",       label: "Debt-Free Date",       context: "to find your debt-free target date" },
      interest_saved:       { suffix: "interest-saved",       label: "Interest Saved",       context: "to calculate total interest savings" },
      payoff_strategy:      { suffix: "payoff-strategy",      label: "Payoff Strategy",      context: "to compare payoff strategies" },

      # ── Finance: Student loan patterns ──
      standard_repayment:   { suffix: "standard-repayment",   label: "Standard Repayment",   context: "with standard 10-year repayment" },
      income_driven:        { suffix: "income-driven",        label: "Income-Driven",        context: "with income-driven repayment plans" },
      refinance_student:    { suffix: "refinance-student",    label: "Refinance Student",    context: "for student loan refinancing" },
      public_service:       { suffix: "public-service",       label: "Public Service",       context: "for Public Service Loan Forgiveness (PSLF)" },
      loan_forgiveness:     { suffix: "loan-forgiveness",     label: "Loan Forgiveness",     context: "for student loan forgiveness programs" },
      grad_school:          { suffix: "grad-school",          label: "Grad School",          context: "for graduate school student loans" },

      # ── Finance: Net worth patterns ──
      by_age:               { suffix: "by-age",               label: "by Age",               context: "benchmarked by age group" },
      millionaire_target:   { suffix: "millionaire-target",   label: "Millionaire Target",   context: "to reach a million-dollar net worth" },
      average_net_worth:    { suffix: "average-net-worth",    label: "Average Net Worth",    context: "compared to national averages" },
      financial_independence: { suffix: "financial-independence", label: "Financial Independence", context: "for financial independence (FIRE)" },
      debt_ratio:           { suffix: "debt-ratio",           label: "Debt Ratio",           context: "to calculate your debt-to-asset ratio" },

      # ── Finance: Paycheck patterns ──
      hourly_paycheck:      { suffix: "hourly-paycheck",      label: "Hourly Paycheck",      context: "for hourly wage earners" },
      salary_paycheck:      { suffix: "salary-paycheck",      label: "Salary Paycheck",      context: "for salaried employees" },
      biweekly_paycheck:    { suffix: "biweekly-paycheck",    label: "Biweekly Paycheck",    context: "for biweekly pay periods" },
      after_tax:            { suffix: "after-tax",            label: "After Tax",            context: "to calculate after-tax take-home pay" },
      with_overtime:        { suffix: "with-overtime",        label: "with Overtime",        context: "including overtime pay" },
      with_bonus:           { suffix: "with-bonus",           label: "with Bonus",           context: "including bonus payments" },

      # ── Finance: Home affordability patterns ──
      by_income:            { suffix: "by-income",            label: "by Income",            context: "based on annual income" },
      by_monthly_payment:   { suffix: "by-monthly-payment",   label: "by Monthly Payment",   context: "based on desired monthly payment" },
      fha_loan:             { suffix: "fha-loan",             label: "FHA Loan",             context: "for FHA loan qualification" },
      va_loan_home:         { suffix: "va-loan",              label: "VA Loan",              context: "for VA loan eligibility" },
      first_time_buyer:     { suffix: "first-time-buyer",     label: "First-Time Buyer",     context: "for first-time home buyers" },
      with_student_loans_home: { suffix: "with-student-loans", label: "with Student Loans",  context: "factoring in student loan payments" },

      # ── Finance: 401(k) patterns ──
      employer_match:       { suffix: "employer-match",       label: "Employer Match",       context: "with employer matching contributions" },
      max_contribution:     { suffix: "max-contribution",     label: "Max Contribution",     context: "at maximum contribution limits" },
      catch_up_contribution: { suffix: "catch-up-contribution", label: "Catch-Up Contribution", context: "with catch-up contributions for age 50+" },
      roth_vs_traditional:  { suffix: "roth-vs-traditional",  label: "Roth vs Traditional",  context: "comparing Roth and traditional 401(k)" },
      early_withdrawal:     { suffix: "early-withdrawal",     label: "Early Withdrawal",     context: "with early withdrawal penalties" },
      retirement_projection: { suffix: "retirement-projection", label: "Retirement Projection", context: "to project retirement balance at retirement age" },

      # ── Finance: Stock profit patterns ──
      capital_gains:        { suffix: "capital-gains",        label: "Capital Gains",        context: "for capital gains calculations" },
      short_term_gains:     { suffix: "short-term-gains",     label: "Short-Term Gains",     context: "for short-term capital gains (held under 1 year)" },
      long_term_gains:      { suffix: "long-term-gains",      label: "Long-Term Gains",      context: "for long-term capital gains (held over 1 year)" },
      with_dividends:       { suffix: "with-dividends",       label: "with Dividends",       context: "including dividend income" },
      options_profit:       { suffix: "options-profit",       label: "Options Profit",       context: "for stock options profit calculations" },
      day_trading:          { suffix: "day-trading",          label: "Day Trading",          context: "for day trading profit and loss" },

      # ── Finance: Crypto profit patterns ──
      bitcoin_profit:       { suffix: "bitcoin-profit",       label: "Bitcoin Profit",       context: "for Bitcoin investment profit" },
      ethereum_profit:      { suffix: "ethereum-profit",      label: "Ethereum Profit",      context: "for Ethereum investment profit" },
      altcoin_profit:       { suffix: "altcoin-profit",       label: "Altcoin Profit",       context: "for altcoin investment profit" },
      defi_yield:           { suffix: "defi-yield",           label: "DeFi Yield",           context: "for decentralized finance yield farming" },
      staking_rewards:      { suffix: "staking-rewards",      label: "Staking Rewards",      context: "for crypto staking reward calculations" },
      mining_profit:        { suffix: "mining-profit",        label: "Mining Profit",        context: "for cryptocurrency mining profitability" },

      # ── Finance: Inflation patterns ──
      purchasing_power:     { suffix: "purchasing-power",     label: "Purchasing Power",     context: "to calculate purchasing power over time" },
      future_value_inflation: { suffix: "future-value",       label: "Future Value",         context: "to project future value adjusted for inflation" },
      salary_adjustment:    { suffix: "salary-adjustment",    label: "Salary Adjustment",    context: "for inflation-adjusted salary calculations" },
      retirement_inflation: { suffix: "retirement-inflation", label: "Retirement Inflation", context: "to account for inflation in retirement planning" },
      historical_inflation: { suffix: "historical-inflation", label: "Historical Inflation", context: "to compare historical inflation rates" },
      cost_of_living_adj:   { suffix: "cost-of-living-adjustment", label: "Cost of Living Adjustment", context: "for cost-of-living adjustments (COLA)" },

      # ── Finance: CD patterns ──
      six_month_cd:         { suffix: "6-month",              label: "6-Month CD",           context: "for 6-month CD terms" },
      one_year_cd:          { suffix: "1-year",               label: "1-Year CD",            context: "for 1-year CD terms" },
      two_year_cd:          { suffix: "2-year",               label: "2-Year CD",            context: "for 2-year CD terms" },
      five_year_cd:         { suffix: "5-year",               label: "5-Year CD",            context: "for 5-year CD terms" },
      cd_ladder:            { suffix: "cd-ladder",            label: "CD Ladder",            context: "for building a CD ladder strategy" },
      apy_comparison:       { suffix: "apy-comparison",       label: "APY Comparison",       context: "to compare annual percentage yields" },

      # ── Finance: Savings interest patterns ──
      high_yield_savings:   { suffix: "high-yield",           label: "High-Yield Savings",   context: "for high-yield savings accounts" },
      money_market_savings: { suffix: "money-market",         label: "Money Market",         context: "for money market accounts" },
      compound_daily_savings: { suffix: "compound-daily",     label: "Compound Daily",       context: "with daily compounding interest" },
      compound_monthly_savings: { suffix: "compound-monthly", label: "Compound Monthly",     context: "with monthly compounding interest" },
      with_regular_deposits: { suffix: "with-regular-deposits", label: "with Regular Deposits", context: "with regular recurring deposits" },
      goal_based_savings:   { suffix: "goal-based",           label: "Goal-Based Savings",   context: "to reach a specific savings goal" },

      # ── Finance: House flip patterns ──
      profit_estimate:      { suffix: "profit-estimate",      label: "Profit Estimate",      context: "to estimate potential flip profit" },
      renovation_cost:      { suffix: "renovation-cost",      label: "Renovation Cost",      context: "to estimate renovation expenses" },
      after_repair_value:   { suffix: "after-repair-value",   label: "After Repair Value",   context: "to calculate after-repair value (ARV)" },
      seventy_percent_rule: { suffix: "70-percent-rule",      label: "70% Rule",             context: "using the 70% rule for house flipping" },
      holding_cost:         { suffix: "holding-cost",         label: "Holding Cost",         context: "to calculate monthly holding costs" },
      flip_roi:             { suffix: "flip-roi",             label: "Flip ROI",             context: "to calculate return on investment for a flip" },

      # ── Finance: Dividend yield patterns ──
      annual_dividend:      { suffix: "annual-dividend",      label: "Annual Dividend",      context: "for annual dividend income projection" },
      monthly_dividend:     { suffix: "monthly-dividend",     label: "Monthly Dividend",     context: "for monthly dividend income projection" },
      yield_on_cost:        { suffix: "yield-on-cost",        label: "Yield on Cost",        context: "to calculate yield on original cost basis" },
      drip_calculator:      { suffix: "drip",                 label: "DRIP",                 context: "for dividend reinvestment plan (DRIP) growth" },
      dividend_portfolio:   { suffix: "dividend-portfolio",   label: "Dividend Portfolio",   context: "to build a dividend income portfolio" },
      high_dividend:        { suffix: "high-dividend",        label: "High Dividend",        context: "for high-dividend-yield stock analysis" },

      # ── Finance: DCA patterns ──
      weekly_dca:           { suffix: "weekly-dca",           label: "Weekly DCA",           context: "with weekly dollar-cost averaging" },
      monthly_dca:          { suffix: "monthly-dca",          label: "Monthly DCA",          context: "with monthly dollar-cost averaging" },
      bitcoin_dca:          { suffix: "bitcoin-dca",          label: "Bitcoin DCA",          context: "for dollar-cost averaging into Bitcoin" },
      sp500_dca:            { suffix: "sp500-dca",            label: "S&P 500 DCA",          context: "for dollar-cost averaging into the S&P 500" },
      etf_dca:              { suffix: "etf-dca",              label: "ETF DCA",              context: "for dollar-cost averaging into ETFs" },
      long_term_dca:        { suffix: "long-term-dca",        label: "Long-Term DCA",        context: "for long-term dollar-cost averaging results" },

      # ── Finance: Solar savings patterns ──
      payback_period:       { suffix: "payback-period",       label: "Payback Period",       context: "to calculate solar panel payback period" },
      monthly_solar_savings: { suffix: "monthly-savings",     label: "Monthly Savings",      context: "for monthly electricity savings from solar" },
      annual_solar_savings: { suffix: "annual-savings",       label: "Annual Savings",       context: "for annual electricity savings from solar" },
      solar_roi:            { suffix: "solar-roi",            label: "Solar ROI",            context: "for return on investment from solar panels" },
      solar_tax_credit:     { suffix: "solar-tax-credit",     label: "Solar Tax Credit",     context: "including federal solar tax credits" },
      panel_cost_estimate:  { suffix: "panel-cost-estimate",  label: "Panel Cost Estimate",  context: "to estimate solar panel installation costs" },

      # ── Finance: Business loan patterns ──
      sba_loan:             { suffix: "sba-loan",             label: "SBA Loan",             context: "for SBA loan calculations" },
      term_loan:            { suffix: "term-loan",            label: "Term Loan",            context: "for business term loan payments" },
      line_of_credit:       { suffix: "line-of-credit",       label: "Line of Credit",       context: "for business line of credit" },
      equipment_loan:       { suffix: "equipment-loan",       label: "Equipment Loan",       context: "for equipment financing" },
      startup_loan:         { suffix: "startup-loan",         label: "Startup Loan",         context: "for startup business loans" },
      working_capital:      { suffix: "working-capital",      label: "Working Capital",      context: "for working capital loan needs" },

      # ── Finance: Rent vs buy patterns ──
      five_year_comparison: { suffix: "5-year-comparison",    label: "5-Year Comparison",    context: "over a 5-year time horizon" },
      ten_year_comparison:  { suffix: "10-year-comparison",   label: "10-Year Comparison",   context: "over a 10-year time horizon" },
      break_even_rent_buy:  { suffix: "break-even",           label: "Break-Even Point",     context: "to find the break-even point between renting and buying" },
      tax_benefit_owning:   { suffix: "tax-benefit",          label: "Tax Benefit of Owning", context: "including tax benefits of homeownership" },
      investment_alternative: { suffix: "investment-alternative", label: "Investment Alternative", context: "comparing investing the difference instead of buying" },
      monthly_cost_comparison: { suffix: "monthly-cost",      label: "Monthly Cost Comparison", context: "comparing total monthly costs of renting vs buying" },

      # ── Finance: Amortization patterns ──
      monthly_amortization: { suffix: "monthly-amortization", label: "Monthly Amortization", context: "with monthly payment amortization schedule" },
      biweekly_amortization: { suffix: "biweekly-amortization", label: "Biweekly Amortization", context: "with biweekly payment amortization schedule" },
      with_extra_payments:  { suffix: "with-extra-payments",  label: "with Extra Payments",  context: "showing impact of extra payments on amortization" },
      balloon_payment:      { suffix: "balloon-payment",      label: "Balloon Payment",      context: "with a balloon payment at the end of the term" },
      interest_only_amort:  { suffix: "interest-only-amort",  label: "Interest-Only Amortization", context: "for interest-only loan amortization" },
      printable_schedule:   { suffix: "printable-schedule",   label: "Printable Schedule",   context: "to generate a printable amortization schedule" },

      # ── Finance: Markup/margin patterns ──
      wholesale_to_retail:  { suffix: "wholesale-to-retail",  label: "Wholesale to Retail",  context: "for wholesale-to-retail markup calculations" },
      food_markup:          { suffix: "food-markup",          label: "Food Markup",          context: "for food and beverage markup pricing" },
      service_markup:       { suffix: "service-markup",       label: "Service Markup",       context: "for service industry markup calculations" },
      keystone_pricing:     { suffix: "keystone-pricing",     label: "Keystone Pricing",     context: "using keystone (100%) markup pricing" },
      cost_plus_pricing:    { suffix: "cost-plus-pricing",    label: "Cost-Plus Pricing",    context: "using cost-plus pricing strategy" },
      target_margin:        { suffix: "target-margin",        label: "Target Margin",        context: "to calculate price from a target margin" },

      # ── Finance: Estate tax patterns ──
      federal_estate:       { suffix: "federal-estate",       label: "Federal Estate Tax",   context: "for federal estate tax calculations" },
      estate_exemption:     { suffix: "estate-exemption",     label: "Estate Exemption",     context: "to check against estate tax exemption limits" },
      married_estate:       { suffix: "married-estate",       label: "Married Estate",       context: "for married couples' estate tax planning" },
      trust_estate:         { suffix: "trust-estate",         label: "Trust Estate",         context: "for estate taxes with trust structures" },
      inheritance_tax:      { suffix: "inheritance-tax",      label: "Inheritance Tax",      context: "for state inheritance tax calculations" },
      gift_tax:             { suffix: "gift-tax",             label: "Gift Tax",             context: "for gift tax exclusion and liability" },

      # ── Finance: Currency converter patterns ──
      usd_to_eur:           { suffix: "usd-to-eur",           label: "USD to EUR",           context: "for converting US dollars to euros" },
      usd_to_gbp:           { suffix: "usd-to-gbp",           label: "USD to GBP",           context: "for converting US dollars to British pounds" },
      usd_to_jpy:           { suffix: "usd-to-jpy",           label: "USD to JPY",           context: "for converting US dollars to Japanese yen" },
      usd_to_cad:           { suffix: "usd-to-cad",           label: "USD to CAD",           context: "for converting US dollars to Canadian dollars" },
      usd_to_aud:           { suffix: "usd-to-aud",           label: "USD to AUD",           context: "for converting US dollars to Australian dollars" },
      usd_to_inr:           { suffix: "usd-to-inr",           label: "USD to INR",           context: "for converting US dollars to Indian rupees" },

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

      # ── Construction: Gravel/mulch patterns ──
      for_driveway_gravel:  { suffix: "for-driveway",        label: "for Driveway",         context: "for gravel driveway installation" },
      for_garden_mulch:     { suffix: "for-garden",           label: "for Garden",           context: "for garden bed mulching" },
      for_walkway:          { suffix: "for-walkway",          label: "for Walkway",          context: "for walkway and path materials" },
      for_landscaping:      { suffix: "for-landscaping",      label: "for Landscaping",      context: "for general landscaping projects" },
      by_cubic_yard:        { suffix: "by-cubic-yard",        label: "by Cubic Yard",        context: "calculated in cubic yards" },
      by_ton:               { suffix: "by-ton",               label: "by Ton",               context: "calculated in tons" },

      # ── Construction: Fence patterns ──
      wood_fence:           { suffix: "wood-fence",           label: "Wood Fence",           context: "for wood fence materials" },
      chain_link_fence:     { suffix: "chain-link-fence",     label: "Chain Link Fence",     context: "for chain link fence materials" },
      vinyl_fence:          { suffix: "vinyl-fence",          label: "Vinyl Fence",          context: "for vinyl fence materials" },
      privacy_fence:        { suffix: "privacy-fence",        label: "Privacy Fence",        context: "for privacy fence construction" },
      picket_fence:         { suffix: "picket-fence",         label: "Picket Fence",         context: "for picket fence materials" },
      cost_per_linear_foot: { suffix: "cost-per-linear-foot", label: "Cost Per Linear Foot", context: "to estimate cost per linear foot of fencing" },

      # ── Construction: Staircase patterns ──
      interior_stairs:      { suffix: "interior-stairs",      label: "Interior Stairs",      context: "for interior staircase design" },
      exterior_stairs:      { suffix: "exterior-stairs",      label: "Exterior Stairs",      context: "for exterior staircase design" },
      deck_stairs:          { suffix: "deck-stairs",          label: "Deck Stairs",          context: "for deck staircase construction" },
      spiral_staircase:     { suffix: "spiral-staircase",     label: "Spiral Staircase",     context: "for spiral staircase dimensions" },
      code_compliant:       { suffix: "code-compliant",       label: "Code Compliant",       context: "to ensure building code compliance" },
      rise_and_run:         { suffix: "rise-and-run",         label: "Rise and Run",         context: "to calculate stair rise and run dimensions" },

      # ── Construction: Wallpaper patterns ──
      by_room_wallpaper:    { suffix: "by-room",              label: "by Room",              context: "calculated by room dimensions" },
      by_roll:              { suffix: "by-roll",              label: "by Roll",              context: "calculated by number of rolls needed" },
      with_pattern_repeat:  { suffix: "with-pattern-repeat",  label: "with Pattern Repeat",  context: "accounting for pattern repeat waste" },
      accent_wall:          { suffix: "accent-wall",          label: "Accent Wall",          context: "for a single accent wall" },
      bathroom_wallpaper:   { suffix: "bathroom-wallpaper",   label: "Bathroom Wallpaper",   context: "for bathroom wallpaper projects" },
      bedroom_wallpaper:    { suffix: "bedroom-wallpaper",    label: "Bedroom Wallpaper",    context: "for bedroom wallpaper projects" },

      # ── Construction: Tile patterns ──
      bathroom_tile:        { suffix: "bathroom-tile",        label: "Bathroom Tile",        context: "for bathroom tile installation" },
      kitchen_backsplash:   { suffix: "kitchen-backsplash",   label: "Kitchen Backsplash",   context: "for kitchen backsplash tile" },
      shower_tile:          { suffix: "shower-tile",          label: "Shower Tile",          context: "for shower tile installation" },
      floor_tile:           { suffix: "floor-tile",           label: "Floor Tile",           context: "for floor tile installation" },
      wall_tile:            { suffix: "wall-tile",            label: "Wall Tile",            context: "for wall tile installation" },
      mosaic_tile:          { suffix: "mosaic-tile",          label: "Mosaic Tile",          context: "for mosaic tile projects" },

      # ── Construction: Lumber patterns ──
      board_feet:           { suffix: "board-feet",           label: "Board Feet",           context: "calculated in board feet" },
      framing_lumber:       { suffix: "framing-lumber",       label: "Framing Lumber",       context: "for framing lumber estimation" },
      decking_lumber:       { suffix: "decking-lumber",       label: "Decking Lumber",       context: "for decking lumber materials" },
      fencing_lumber:       { suffix: "fencing-lumber",       label: "Fencing Lumber",       context: "for fencing lumber materials" },
      plywood:              { suffix: "plywood",              label: "Plywood",              context: "for plywood sheet calculations" },
      cost_estimate_lumber: { suffix: "cost-estimate",        label: "Cost Estimate",        context: "to estimate total lumber costs" },

      # ── Construction: HVAC BTU patterns ──
      by_room_size:         { suffix: "by-room-size",         label: "by Room Size",         context: "calculated by room dimensions" },
      by_square_footage:    { suffix: "by-square-footage",    label: "by Square Footage",    context: "calculated by total square footage" },
      heating_btu:          { suffix: "heating-btu",          label: "Heating BTU",          context: "for heating BTU requirements" },
      cooling_btu:          { suffix: "cooling-btu",          label: "Cooling BTU",          context: "for cooling BTU requirements" },
      mini_split:           { suffix: "mini-split",           label: "Mini Split",           context: "for ductless mini split sizing" },
      central_air:          { suffix: "central-air",          label: "Central Air",          context: "for central air conditioning sizing" },

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

      # ── Math: Fraction patterns ──
      add_fractions:        { suffix: "add-fractions",        label: "Add Fractions",        context: "for adding fractions with different denominators" },
      subtract_fractions:   { suffix: "subtract-fractions",   label: "Subtract Fractions",   context: "for subtracting fractions" },
      multiply_fractions:   { suffix: "multiply-fractions",   label: "Multiply Fractions",   context: "for multiplying fractions" },
      divide_fractions:     { suffix: "divide-fractions",     label: "Divide Fractions",     context: "for dividing fractions" },
      simplify_fraction:    { suffix: "simplify-fraction",    label: "Simplify Fraction",    context: "to simplify fractions to lowest terms" },
      mixed_number:         { suffix: "mixed-number",         label: "Mixed Number",         context: "for mixed number and improper fraction conversions" },

      # ── Math: Standard deviation patterns ──
      population_sd:        { suffix: "population",           label: "Population",           context: "for population standard deviation" },
      sample_sd:            { suffix: "sample",               label: "Sample",               context: "for sample standard deviation" },
      for_data_set:         { suffix: "for-data-set",         label: "for Data Set",         context: "for a given data set" },
      with_mean:            { suffix: "with-mean",            label: "with Mean",            context: "showing mean alongside standard deviation" },
      variance_calc:        { suffix: "variance",             label: "Variance",             context: "to calculate variance" },
      for_statistics:       { suffix: "for-statistics",       label: "for Statistics",       context: "for statistical analysis" },

      # ── Math: Probability patterns ──
      single_event:         { suffix: "single-event",         label: "Single Event",         context: "for single event probability" },
      multiple_events:      { suffix: "multiple-events",      label: "Multiple Events",      context: "for multiple independent events" },
      conditional_prob:     { suffix: "conditional",          label: "Conditional",          context: "for conditional probability (Bayes' theorem)" },
      binomial_prob:        { suffix: "binomial",             label: "Binomial",             context: "for binomial probability distribution" },
      normal_distribution:  { suffix: "normal-distribution",  label: "Normal Distribution",  context: "for normal (Gaussian) distribution" },
      dice_probability:     { suffix: "dice",                 label: "Dice Probability",     context: "for dice roll probability" },

      # ── Math: Logarithm patterns ──
      natural_log:          { suffix: "natural-log",          label: "Natural Log (ln)",     context: "for natural logarithm (base e)" },
      log_base_10:          { suffix: "log-base-10",          label: "Log Base 10",          context: "for common logarithm (base 10)" },
      log_base_2:           { suffix: "log-base-2",           label: "Log Base 2",           context: "for binary logarithm (base 2)" },
      change_of_base:       { suffix: "change-of-base",       label: "Change of Base",       context: "using the change of base formula" },
      antilog:              { suffix: "antilog",              label: "Antilog",              context: "to calculate antilogarithm (inverse log)" },
      log_equations:        { suffix: "log-equations",        label: "Log Equations",        context: "to solve logarithmic equations" },

      # ── Math: Pythagorean patterns ──
      find_hypotenuse:      { suffix: "find-hypotenuse",      label: "Find Hypotenuse",      context: "to find the hypotenuse of a right triangle" },
      find_missing_side:    { suffix: "find-missing-side",    label: "Find Missing Side",    context: "to find a missing side of a right triangle" },
      distance_formula:     { suffix: "distance-formula",     label: "Distance Formula",     context: "using the distance formula between two points" },
      pythagorean_proof:    { suffix: "proof",                label: "Pythagorean Proof",    context: "to verify if a triangle is a right triangle" },
      three_d_distance:     { suffix: "3d-distance",          label: "3D Distance",          context: "for 3D distance calculations" },
      real_world_pythagorean: { suffix: "real-world",         label: "Real World",           context: "for real-world applications of the Pythagorean theorem" },

      # ── Math: Circumference patterns ──
      from_radius:          { suffix: "from-radius",          label: "from Radius",          context: "calculated from the radius" },
      from_diameter:        { suffix: "from-diameter",        label: "from Diameter",        context: "calculated from the diameter" },
      from_area:            { suffix: "from-area",            label: "from Area",            context: "calculated from the area" },
      arc_length:           { suffix: "arc-length",           label: "Arc Length",           context: "to calculate arc length" },
      sector_area:          { suffix: "sector-area",          label: "Sector Area",          context: "to calculate sector area" },
      circle_area:          { suffix: "circle-area",          label: "Circle Area",          context: "to calculate the area of a circle" },

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
      space_heater:     { suffix: "space-heater",    label: "Space Heater",     context: "for space heater electricity costs" },

      # ── Physics: Velocity patterns ──
      find_speed:           { suffix: "find-speed",           label: "Find Speed",           context: "to calculate speed from distance and time" },
      find_distance:        { suffix: "find-distance",        label: "Find Distance",        context: "to calculate distance from speed and time" },
      find_time:            { suffix: "find-time",            label: "Find Time",            context: "to calculate time from speed and distance" },
      average_velocity:     { suffix: "average-velocity",     label: "Average Velocity",     context: "to calculate average velocity" },
      final_velocity:       { suffix: "final-velocity",       label: "Final Velocity",       context: "to calculate final velocity with acceleration" },
      initial_velocity:     { suffix: "initial-velocity",     label: "Initial Velocity",     context: "to calculate initial velocity" },

      # ── Physics: Force patterns ──
      find_force:           { suffix: "find-force",           label: "Find Force",           context: "to calculate force from mass and acceleration" },
      find_mass:            { suffix: "find-mass",            label: "Find Mass",            context: "to calculate mass from force and acceleration" },
      find_acceleration:    { suffix: "find-acceleration",    label: "Find Acceleration",    context: "to calculate acceleration from force and mass" },
      friction_force:       { suffix: "friction-force",       label: "Friction Force",       context: "to calculate friction force" },
      gravitational_force:  { suffix: "gravitational-force",  label: "Gravitational Force",  context: "to calculate gravitational force between objects" },
      net_force:            { suffix: "net-force",            label: "Net Force",            context: "to calculate net force from multiple forces" },

      # ── Physics: Ohm's law patterns ──
      find_voltage:         { suffix: "find-voltage",         label: "Find Voltage",         context: "to calculate voltage from current and resistance" },
      find_current:         { suffix: "find-current",         label: "Find Current",         context: "to calculate current from voltage and resistance" },
      find_resistance:      { suffix: "find-resistance",      label: "Find Resistance",      context: "to calculate resistance from voltage and current" },
      power_calc:           { suffix: "power",                label: "Power",                context: "to calculate electrical power" },
      series_circuit:       { suffix: "series-circuit",       label: "Series Circuit",       context: "for series circuit calculations" },
      parallel_circuit:     { suffix: "parallel-circuit",     label: "Parallel Circuit",     context: "for parallel circuit calculations" },

      # ── Physics: Kinetic energy patterns ──
      from_mass_velocity:   { suffix: "from-mass-velocity",   label: "from Mass and Velocity", context: "calculated from mass and velocity" },
      in_joules:            { suffix: "in-joules",            label: "in Joules",            context: "expressed in joules" },
      potential_to_kinetic: { suffix: "potential-to-kinetic",  label: "Potential to Kinetic", context: "for potential-to-kinetic energy conversion" },
      work_energy:          { suffix: "work-energy",          label: "Work-Energy Theorem",  context: "using the work-energy theorem" },
      momentum_calc:        { suffix: "momentum",             label: "Momentum",             context: "to calculate momentum" },
      rotational_energy:    { suffix: "rotational-energy",    label: "Rotational Energy",    context: "for rotational kinetic energy" },

      # ── Physics: Decibel patterns ──
      sound_level:          { suffix: "sound-level",          label: "Sound Level",          context: "to calculate sound pressure level" },
      noise_reduction:      { suffix: "noise-reduction",      label: "Noise Reduction",      context: "to calculate noise reduction" },
      distance_db:          { suffix: "distance",             label: "Distance",             context: "for sound level change over distance" },
      power_ratio_db:       { suffix: "power-ratio",          label: "Power Ratio",          context: "for power ratio in decibels" },
      voltage_ratio_db:     { suffix: "voltage-ratio",        label: "Voltage Ratio",        context: "for voltage ratio in decibels" },
      db_addition:          { suffix: "db-addition",          label: "dB Addition",          context: "for adding decibel values" },

      # ── Physics: Projectile motion patterns ──
      max_height:           { suffix: "max-height",           label: "Max Height",           context: "to calculate maximum projectile height" },
      max_range:            { suffix: "max-range",            label: "Max Range",            context: "to calculate maximum projectile range" },
      flight_time:          { suffix: "flight-time",          label: "Flight Time",          context: "to calculate total flight time" },
      launch_angle:         { suffix: "launch-angle",         label: "Launch Angle",         context: "to find the optimal launch angle" },
      landing_velocity:     { suffix: "landing-velocity",     label: "Landing Velocity",     context: "to calculate velocity at impact" },
      horizontal_distance:  { suffix: "horizontal-distance",  label: "Horizontal Distance",  context: "to calculate horizontal distance traveled" },

      # ── Physics: Heat transfer patterns ──
      conduction:           { suffix: "conduction",           label: "Conduction",           context: "for heat conduction through materials" },
      convection:           { suffix: "convection",           label: "Convection",           context: "for convective heat transfer" },
      radiation:            { suffix: "radiation",            label: "Radiation",            context: "for radiative heat transfer" },
      through_wall:         { suffix: "through-wall",         label: "Through Wall",         context: "for heat transfer through walls" },
      insulation_r_value:   { suffix: "insulation-r-value",   label: "Insulation R-Value",   context: "to calculate insulation R-value effectiveness" },
      heat_loss:            { suffix: "heat-loss",            label: "Heat Loss",            context: "to calculate total heat loss" },

      # ── Health: Water intake patterns ──
      by_weight:            { suffix: "by-weight",            label: "by Weight",            context: "calculated based on body weight" },
      for_athletes_water:   { suffix: "for-athletes",         label: "for Athletes",         context: "for athletes and active individuals" },
      during_pregnancy_water: { suffix: "during-pregnancy",   label: "During Pregnancy",     context: "during pregnancy" },
      in_hot_weather:       { suffix: "in-hot-weather",       label: "in Hot Weather",       context: "in hot weather conditions" },
      for_children:         { suffix: "for-children",         label: "for Children",         context: "for children's hydration needs" },
      for_elderly:          { suffix: "for-elderly",          label: "for Elderly",          context: "for elderly hydration needs" },

      # ── Health: Sleep patterns ──
      bedtime_calc:         { suffix: "bedtime",              label: "Bedtime",              context: "to calculate optimal bedtime" },
      wake_up_calc:         { suffix: "wake-up-time",         label: "Wake-Up Time",         context: "to calculate optimal wake-up time" },
      for_shift_workers:    { suffix: "for-shift-workers",    label: "for Shift Workers",    context: "for shift workers and irregular schedules" },
      for_teenagers_sleep:  { suffix: "for-teenagers",        label: "for Teenagers",        context: "for teenage sleep requirements" },
      for_babies:           { suffix: "for-babies",           label: "for Babies",           context: "for infant sleep schedules" },
      nap_time:             { suffix: "nap-time",             label: "Nap Time",             context: "for optimal nap duration and timing" },

      # ── Health: One rep max patterns ──
      bench_press:          { suffix: "bench-press",          label: "Bench Press",          context: "for bench press 1RM estimation" },
      squat_1rm:            { suffix: "squat",                label: "Squat",                context: "for squat 1RM estimation" },
      deadlift_1rm:         { suffix: "deadlift",             label: "Deadlift",             context: "for deadlift 1RM estimation" },
      overhead_press:       { suffix: "overhead-press",       label: "Overhead Press",       context: "for overhead press 1RM estimation" },
      by_reps:              { suffix: "by-reps",              label: "by Reps",              context: "estimated from submaximal reps" },
      epley_formula:        { suffix: "epley-formula",        label: "Epley Formula",        context: "using the Epley 1RM formula" },

      # ── Health: Ideal weight patterns ──
      by_height:            { suffix: "by-height",            label: "by Height",            context: "calculated based on height" },
      for_men_weight:       { suffix: "for-men",              label: "for Men",              context: "for men's ideal weight ranges" },
      for_women_weight:     { suffix: "for-women",            label: "for Women",            context: "for women's ideal weight ranges" },
      by_frame_size:        { suffix: "by-frame-size",        label: "by Frame Size",        context: "adjusted for body frame size" },
      for_athletes_weight:  { suffix: "for-athletes",         label: "for Athletes",         context: "for athletes' ideal weight targets" },
      for_seniors_weight:   { suffix: "for-seniors",          label: "for Seniors",          context: "for seniors' healthy weight ranges" },

      # ── Health: BAC patterns ──
      by_body_weight:       { suffix: "by-body-weight",       label: "by Body Weight",       context: "based on body weight" },
      by_drinks:            { suffix: "by-drinks",            label: "by Drinks",            context: "based on number of drinks consumed" },
      over_time:            { suffix: "over-time",            label: "Over Time",            context: "showing BAC change over time" },
      driving_limit:        { suffix: "driving-limit",        label: "Driving Limit",        context: "for legal driving limit comparison" },
      sobering_up_time:     { suffix: "sobering-up-time",     label: "Sobering Up Time",     context: "to estimate time to sober up" },
      by_gender:            { suffix: "by-gender",            label: "by Gender",            context: "with gender-specific BAC factors" },

      # ── Health: Heart rate zone patterns ──
      fat_burning_zone:     { suffix: "fat-burning-zone",     label: "Fat Burning Zone",     context: "for fat-burning heart rate zone" },
      cardio_zone:          { suffix: "cardio-zone",          label: "Cardio Zone",          context: "for cardiovascular training zone" },
      peak_zone:            { suffix: "peak-zone",            label: "Peak Zone",            context: "for peak performance heart rate zone" },
      for_running_hr:       { suffix: "for-running",          label: "for Running",          context: "for running heart rate training" },
      for_cycling_hr:       { suffix: "for-cycling",          label: "for Cycling",          context: "for cycling heart rate training" },
      by_age_hr:            { suffix: "by-age",               label: "by Age",               context: "calculated by age" },

      # ── Health: Keto patterns ──
      standard_keto:        { suffix: "standard-keto",        label: "Standard Keto",        context: "for standard ketogenic diet (SKD)" },
      targeted_keto:        { suffix: "targeted-keto",        label: "Targeted Keto",        context: "for targeted ketogenic diet (TKD)" },
      cyclical_keto:        { suffix: "cyclical-keto",        label: "Cyclical Keto",        context: "for cyclical ketogenic diet (CKD)" },
      keto_weight_loss:     { suffix: "keto-weight-loss",     label: "Keto Weight Loss",     context: "for weight loss on keto" },
      keto_beginners:       { suffix: "keto-beginners",       label: "Keto for Beginners",   context: "for keto diet beginners" },
      keto_for_women:       { suffix: "keto-for-women",       label: "Keto for Women",       context: "for women on a ketogenic diet" },

      # ── Health: Intermittent fasting patterns ──
      sixteen_eight:        { suffix: "16-8",                 label: "16:8 Method",          context: "for the 16:8 intermittent fasting method" },
      five_two:             { suffix: "5-2",                  label: "5:2 Method",           context: "for the 5:2 intermittent fasting method" },
      omad_fasting:         { suffix: "omad",                 label: "OMAD",                 context: "for one meal a day (OMAD) fasting" },
      fasting_weight_loss:  { suffix: "fasting-weight-loss",  label: "Fasting Weight Loss",  context: "for weight loss through intermittent fasting" },
      fasting_beginners:    { suffix: "fasting-beginners",    label: "Fasting for Beginners", context: "for intermittent fasting beginners" },
      fasting_for_women:    { suffix: "fasting-for-women",    label: "Fasting for Women",    context: "for women practicing intermittent fasting" },

      # ── Health: Pregnancy due date patterns ──
      by_lmp:               { suffix: "by-lmp",               label: "by LMP",               context: "calculated from last menstrual period" },
      by_conception_date:   { suffix: "by-conception-date",   label: "by Conception Date",   context: "calculated from conception date" },
      by_ivf_transfer:      { suffix: "by-ivf-transfer",      label: "by IVF Transfer",      context: "calculated from IVF transfer date" },
      by_ultrasound:        { suffix: "by-ultrasound",        label: "by Ultrasound",        context: "calculated from ultrasound measurements" },
      trimester_dates:      { suffix: "trimester-dates",      label: "Trimester Dates",      context: "showing trimester start and end dates" },
      week_by_week:         { suffix: "week-by-week",         label: "Week by Week",         context: "with week-by-week pregnancy timeline" },

      # ── Health: Dog age patterns ──
      by_breed_size:        { suffix: "by-breed-size",        label: "by Breed Size",        context: "adjusted for breed size" },
      small_dog_age:        { suffix: "small-dog",            label: "Small Dog",            context: "for small breed dogs" },
      medium_dog_age:       { suffix: "medium-dog",           label: "Medium Dog",           context: "for medium breed dogs" },
      large_dog_age:        { suffix: "large-dog",            label: "Large Dog",            context: "for large breed dogs" },
      puppy_age:            { suffix: "puppy",                label: "Puppy",                context: "for puppies under 2 years" },
      senior_dog_age:       { suffix: "senior-dog",           label: "Senior Dog",           context: "for senior dogs" },

      # ── Health: Dog food patterns ──
      by_dog_weight:        { suffix: "by-dog-weight",        label: "by Dog Weight",        context: "based on dog's body weight" },
      by_breed_food:        { suffix: "by-breed",             label: "by Breed",             context: "recommended for specific breeds" },
      puppy_food:           { suffix: "puppy-food",           label: "Puppy Food",           context: "for puppy feeding schedules" },
      senior_dog_food:      { suffix: "senior-dog-food",      label: "Senior Dog Food",      context: "for senior dog feeding needs" },
      active_dog:           { suffix: "active-dog",           label: "Active Dog",           context: "for highly active dogs" },
      raw_diet:             { suffix: "raw-diet",             label: "Raw Diet",             context: "for raw food diet portions" },

      # ── Health: Blood pressure patterns ──
      by_age_bp:            { suffix: "by-age",               label: "by Age",               context: "blood pressure ranges by age" },
      normal_range_bp:      { suffix: "normal-range",         label: "Normal Range",         context: "for normal blood pressure range" },
      high_bp:              { suffix: "high-blood-pressure",  label: "High Blood Pressure",  context: "for high blood pressure (hypertension) check" },
      low_bp:               { suffix: "low-blood-pressure",   label: "Low Blood Pressure",   context: "for low blood pressure (hypotension) check" },
      pregnancy_bp:         { suffix: "during-pregnancy",     label: "During Pregnancy",     context: "for blood pressure monitoring during pregnancy" },
      senior_bp:            { suffix: "for-seniors",          label: "for Seniors",          context: "for senior blood pressure guidelines" },

      # ── Health: Ovulation patterns ──
      by_cycle_length:      { suffix: "by-cycle-length",      label: "by Cycle Length",      context: "based on menstrual cycle length" },
      irregular_cycle:      { suffix: "irregular-cycle",      label: "Irregular Cycle",      context: "for irregular menstrual cycles" },
      fertile_window:       { suffix: "fertile-window",       label: "Fertile Window",       context: "to identify the fertile window" },
      best_conception_time: { suffix: "best-conception-time", label: "Best Conception Time", context: "to find the best time to conceive" },
      after_miscarriage:    { suffix: "after-miscarriage",    label: "After Miscarriage",    context: "for ovulation tracking after miscarriage" },
      with_pcos:            { suffix: "with-pcos",            label: "with PCOS",            context: "for ovulation prediction with PCOS" },

      # ── Health: Lean body mass patterns ──
      for_men_lbm:          { suffix: "for-men",              label: "for Men",              context: "for men's lean body mass" },
      for_women_lbm:        { suffix: "for-women",            label: "for Women",            context: "for women's lean body mass" },
      for_bodybuilding_lbm: { suffix: "for-bodybuilding",     label: "for Bodybuilding",     context: "for bodybuilding lean mass targets" },
      by_body_fat_lbm:      { suffix: "by-body-fat",          label: "by Body Fat",          context: "calculated from body fat percentage" },
      boer_formula:         { suffix: "boer-formula",         label: "Boer Formula",         context: "using the Boer formula" },
      james_formula:        { suffix: "james-formula",        label: "James Formula",        context: "using the James formula" },

      # ── Health: Conception patterns ──
      by_due_date_conception: { suffix: "by-due-date",        label: "by Due Date",          context: "estimated from due date" },
      by_lmp_conception:    { suffix: "by-lmp",               label: "by LMP",               context: "estimated from last menstrual period" },
      ivf_conception:       { suffix: "ivf",                  label: "IVF",                  context: "for IVF conception date" },
      fertile_window_conception: { suffix: "fertile-window",  label: "Fertile Window",       context: "to identify the fertile window" },
      gender_calendar:      { suffix: "gender-calendar",      label: "Gender Calendar",      context: "using the Chinese gender prediction calendar" },
      after_birth_control:  { suffix: "after-birth-control",  label: "After Birth Control",  context: "after stopping birth control" },

      # ── Health: Pregnancy week patterns ──
      first_trimester:      { suffix: "first-trimester",      label: "First Trimester",      context: "for weeks 1-12 of pregnancy" },
      second_trimester:     { suffix: "second-trimester",     label: "Second Trimester",     context: "for weeks 13-27 of pregnancy" },
      third_trimester:      { suffix: "third-trimester",      label: "Third Trimester",      context: "for weeks 28-40 of pregnancy" },
      baby_size_week:       { suffix: "baby-size",            label: "Baby Size",            context: "to see baby size at each week" },
      symptoms_week:        { suffix: "symptoms",             label: "Symptoms by Week",     context: "for pregnancy symptoms by week" },
      development_week:     { suffix: "development",          label: "Development by Week",  context: "for fetal development milestones by week" },

      # ── Everyday: Age patterns ──
      in_days:              { suffix: "in-days",              label: "in Days",              context: "to calculate age in total days" },
      in_weeks:             { suffix: "in-weeks",             label: "in Weeks",             context: "to calculate age in total weeks" },
      in_months:            { suffix: "in-months",            label: "in Months",            context: "to calculate age in total months" },
      exact_age:            { suffix: "exact-age",            label: "Exact Age",            context: "to calculate exact age in years, months, and days" },
      birthday_countdown:   { suffix: "birthday-countdown",   label: "Birthday Countdown",   context: "to count down days until next birthday" },
      zodiac_sign:          { suffix: "zodiac-sign",          label: "Zodiac Sign",          context: "to determine zodiac sign from birth date" },

      # ── Everyday: Date difference patterns ──
      in_days_diff:         { suffix: "in-days",              label: "in Days",              context: "to calculate the difference in days" },
      in_weeks_diff:        { suffix: "in-weeks",             label: "in Weeks",             context: "to calculate the difference in weeks" },
      in_months_diff:       { suffix: "in-months",            label: "in Months",            context: "to calculate the difference in months" },
      business_days_diff:   { suffix: "business-days",        label: "Business Days",        context: "counting only business days" },
      workdays_between:     { suffix: "workdays-between",     label: "Workdays Between",     context: "to count workdays between two dates" },
      countdown_to_date:    { suffix: "countdown-to-date",    label: "Countdown to Date",    context: "to count down to a specific date" },

      # ── Everyday: Gas mileage patterns ──
      mpg_calc:             { suffix: "mpg",                  label: "MPG",                  context: "in miles per gallon" },
      liters_per_100km:     { suffix: "liters-per-100km",     label: "Liters per 100km",     context: "in liters per 100 kilometers" },
      km_per_liter:         { suffix: "km-per-liter",         label: "km per Liter",         context: "in kilometers per liter" },
      fuel_efficiency:      { suffix: "fuel-efficiency",      label: "Fuel Efficiency",      context: "to measure overall fuel efficiency" },
      mpg_comparison:       { suffix: "mpg-comparison",       label: "MPG Comparison",       context: "to compare fuel economy between vehicles" },
      improve_mpg:          { suffix: "improve-mpg",          label: "Improve MPG",          context: "for tips and calculations to improve MPG" },

      # ── Everyday: GPA patterns ──
      weighted_gpa:         { suffix: "weighted",             label: "Weighted GPA",         context: "for weighted GPA with honors and AP classes" },
      unweighted_gpa:       { suffix: "unweighted",           label: "Unweighted GPA",       context: "for unweighted GPA on a 4.0 scale" },
      cumulative_gpa:       { suffix: "cumulative",           label: "Cumulative GPA",       context: "for cumulative GPA across all semesters" },
      semester_gpa:         { suffix: "semester",             label: "Semester GPA",         context: "for a single semester GPA" },
      college_gpa:          { suffix: "college",              label: "College GPA",          context: "for college-level GPA" },
      high_school_gpa:      { suffix: "high-school",          label: "High School GPA",      context: "for high school GPA" },

      # ── Everyday: Cooking converter patterns ──
      cups_to_grams:        { suffix: "cups-to-grams",        label: "Cups to Grams",        context: "to convert cups to grams" },
      tablespoons_to_ml:    { suffix: "tablespoons-to-ml",    label: "Tablespoons to mL",    context: "to convert tablespoons to milliliters" },
      ounces_to_grams:      { suffix: "ounces-to-grams",      label: "Ounces to Grams",      context: "to convert ounces to grams" },
      fahrenheit_to_celsius: { suffix: "fahrenheit-to-celsius", label: "Fahrenheit to Celsius", context: "to convert Fahrenheit to Celsius" },
      metric_cooking:       { suffix: "metric",               label: "Metric Cooking",       context: "for metric cooking unit conversions" },
      imperial_cooking:     { suffix: "imperial",             label: "Imperial Cooking",     context: "for imperial cooking unit conversions" },

      # ── Everyday: Moving cost patterns ──
      local_move:           { suffix: "local-move",           label: "Local Move",           context: "for local moves within the same city" },
      long_distance_move:   { suffix: "long-distance-move",   label: "Long Distance Move",   context: "for long distance moves" },
      cross_country_move:   { suffix: "cross-country-move",   label: "Cross Country Move",   context: "for cross-country moves" },
      apartment_move:       { suffix: "apartment-move",       label: "Apartment Move",       context: "for apartment moves" },
      house_move:           { suffix: "house-move",           label: "House Move",           context: "for house moves" },
      by_bedroom_count:     { suffix: "by-bedroom-count",     label: "by Bedroom Count",     context: "estimated by number of bedrooms" },

      # ── Everyday: Bandwidth patterns ──
      download_time:        { suffix: "download-time",        label: "Download Time",        context: "to estimate file download time" },
      upload_speed:         { suffix: "upload-speed",         label: "Upload Speed",         context: "to calculate required upload speed" },
      streaming_bandwidth:  { suffix: "streaming",            label: "Streaming",            context: "for video streaming bandwidth needs" },
      gaming_bandwidth:     { suffix: "gaming",               label: "Gaming",               context: "for online gaming bandwidth needs" },
      required_speed:       { suffix: "required-speed",       label: "Required Speed",       context: "to determine required internet speed" },
      data_usage:           { suffix: "data-usage",           label: "Data Usage",           context: "to estimate monthly data usage" },

      # ── Everyday: Screen size patterns ──
      by_diagonal:          { suffix: "by-diagonal",          label: "by Diagonal",          context: "calculated from diagonal screen size" },
      tv_size:              { suffix: "tv-size",              label: "TV Size",              context: "for TV screen size selection" },
      monitor_size:         { suffix: "monitor-size",         label: "Monitor Size",         context: "for computer monitor sizing" },
      viewing_distance:     { suffix: "viewing-distance",     label: "Viewing Distance",     context: "for optimal viewing distance" },
      ppi_calc:             { suffix: "ppi",                  label: "PPI",                  context: "to calculate pixels per inch" },
      resolution_calc:      { suffix: "resolution",           label: "Resolution",           context: "to calculate screen resolution" },

      # ── Everyday: Grade patterns ──
      final_grade:          { suffix: "final-grade",          label: "Final Grade",          context: "to calculate final course grade" },
      weighted_average:     { suffix: "weighted-average",     label: "Weighted Average",     context: "for weighted average grade calculation" },
      final_exam_needed:    { suffix: "final-exam-needed",    label: "Final Exam Needed",    context: "to find the grade needed on the final exam" },
      letter_grade:         { suffix: "letter-grade",         label: "Letter Grade",         context: "to convert percentage to letter grade" },
      pass_fail:            { suffix: "pass-fail",            label: "Pass/Fail",            context: "for pass/fail grade determination" },
      extra_credit:         { suffix: "extra-credit",         label: "Extra Credit",         context: "to calculate the impact of extra credit" },

      # ── Everyday: Password strength patterns ──
      entropy_calc:         { suffix: "entropy",              label: "Entropy",              context: "to calculate password entropy in bits" },
      crack_time:           { suffix: "crack-time",           label: "Crack Time",           context: "to estimate time to crack a password" },
      strong_password:      { suffix: "strong-password",      label: "Strong Password",      context: "to check if a password is strong enough" },
      passphrase:           { suffix: "passphrase",           label: "Passphrase",           context: "for passphrase strength evaluation" },
      for_business:         { suffix: "for-business",         label: "for Business",         context: "for business password policy compliance" },
      best_practices:       { suffix: "best-practices",       label: "Best Practices",       context: "for password security best practices" }
    }.freeze
  end
end
