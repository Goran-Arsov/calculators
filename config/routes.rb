Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Localized IT tool routes (de, fr, es, pt)
  scope "/:locale", constraints: { locale: /de|fr|es|pt/ } do
    scope :everyday, module: :everyday, as: nil do
      get "base64-encoder-decoder", to: "calculators#base64_encoder"
      get "url-encoder-decoder", to: "calculators#url_encoder"
      get "html-formatter-beautifier", to: "calculators#html_formatter"
      get "css-formatter-beautifier", to: "calculators#css_formatter"
      get "javascript-formatter-beautifier", to: "calculators#js_formatter"
      get "json-validator", to: "calculators#json_validator"
      get "json-to-yaml-converter", to: "calculators#json_to_yaml"
      get "curl-to-code-converter", to: "calculators#curl_to_code"
      get "json-to-typescript-generator", to: "calculators#json_to_typescript"
      get "html-to-jsx-converter", to: "calculators#html_to_jsx"
      get "hex-ascii-converter", to: "calculators#hex_ascii"
      get "http-status-code-reference", to: "calculators#http_status_reference"
      get "robots-txt-generator", to: "calculators#robots_txt"
      get "htaccess-generator", to: "calculators#htaccess_generator"
      get "regex-explainer", to: "calculators#regex_explainer"
      get "open-graph-preview", to: "calculators#og_preview"
      get "svg-to-png-converter", to: "calculators#svg_to_png"
    end
  end

  # Browse all
  get "browse", to: "browse#index", as: :browse

  # IT Tools
  get "information-technology", to: "it_tools#index", as: :it_tools

  # Admin
  get "admin/ratings", to: "admin/ratings#index", as: :admin_ratings

  # API
  namespace :api, defaults: { format: :json } do
    get "ratings/:slug", to: "ratings#show"
    post "ratings/:slug", to: "ratings#create"
  end

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

    # Micro-calculator variants
    get "car-loan-calculator", to: "calculators#car_loan", as: :car_loan
    get "motorcycle-loan-calculator", to: "calculators#motorcycle_loan", as: :motorcycle_loan
    get "boat-loan-calculator", to: "calculators#boat_loan", as: :boat_loan
    get "personal-loan-calculator", to: "calculators#personal_loan", as: :personal_loan
    get "home-equity-loan-calculator", to: "calculators#home_equity_loan", as: :home_equity_loan
    get "rv-loan-calculator", to: "calculators#rv_loan", as: :rv_loan
    get "fha-mortgage-calculator", to: "calculators#fha_mortgage", as: :fha_mortgage
    get "va-mortgage-calculator", to: "calculators#va_mortgage", as: :va_mortgage
    get "refinance-calculator", to: "calculators#refinance", as: :refinance
    get "jumbo-mortgage-calculator", to: "calculators#jumbo_mortgage", as: :jumbo_mortgage
    get "savings-growth-calculator", to: "calculators#savings_growth", as: :savings_growth
    get "money-market-calculator", to: "calculators#money_market", as: :money_market
    get "hourly-paycheck-calculator", to: "calculators#hourly_paycheck", as: :hourly_paycheck
    get "freelance-tax-calculator", to: "calculators#freelance_tax", as: :freelance_tax
    get "salary-converter", to: "calculators#salary_converter", as: :salary_converter
    get "cost-of-living-calculator", to: "calculators#cost_of_living", as: :cost_of_living
    get "hourly-to-project-calculator", to: "calculators#hourly_to_project", as: :hourly_to_project
    get "cost-per-click-calculator", to: "calculators#cost_per_click", as: :cost_per_click
    get "cost-per-lead-calculator", to: "calculators#cost_per_lead", as: :cost_per_lead
    get "cost-per-acquisition-calculator", to: "calculators#cost_per_acquisition", as: :cost_per_acquisition
    get "revenue-per-employee-calculator", to: "calculators#revenue_per_employee", as: :revenue_per_employee
    get "earnings-per-share-calculator", to: "calculators#earnings_per_share", as: :earnings_per_share
    get "savings-per-month-calculator", to: "calculators#savings_per_month", as: :savings_per_month
    get "overtime-calculator", to: "calculators#overtime", as: :overtime
    get "hourly-to-salary-calculator", to: "calculators#hourly_to_salary", as: :hourly_to_salary
    get "invoice-generator", to: "calculators#invoice_generator", as: :invoice_generator
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

    # Micro-calculator variants
    get "percentage-increase-calculator", to: "calculators#percentage_increase", as: :percentage_increase
    get "percentage-decrease-calculator", to: "calculators#percentage_decrease", as: :percentage_decrease
    get "percentage-off-calculator", to: "calculators#percentage_off", as: :percentage_off
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
    get "bmi-calculator-women", to: "calculators#bmi_women", as: :bmi_women
    get "bmi-calculator-men", to: "calculators#bmi_men", as: :bmi_men
    get "bmi-calculator-kids", to: "calculators#bmi_kids", as: :bmi_kids
    get "calorie-deficit-calculator", to: "calculators#calorie_deficit", as: :calorie_deficit
    get "weight-loss-calorie-calculator", to: "calculators#weight_loss_calories", as: :weight_loss_calories
    get "pregnancy-calorie-calculator", to: "calculators#pregnancy_calories", as: :pregnancy_calories
    get "bulking-calorie-calculator", to: "calculators#bulking_calories", as: :bulking_calories
    get "calories-per-serving-calculator", to: "calculators#calories_per_serving", as: :calories_per_serving
    get "protein-per-meal-calculator", to: "calculators#protein_per_meal", as: :protein_per_meal
    get "calories-per-100g-calculator", to: "calculators#calories_per_100g", as: :calories_per_100g
    get "steps-per-mile-calculator", to: "calculators#steps_per_mile", as: :steps_per_mile
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
    get "sqft-cost-calculator", to: "calculators#sqft_cost", as: :sqft_cost
    get "price-per-sqm-calculator", to: "calculators#price_per_sqm", as: :price_per_sqm
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

    # Micro-calculator variants
    get "restaurant-tip-calculator", to: "calculators#restaurant_tip", as: :restaurant_tip
    get "delivery-tip-calculator", to: "calculators#delivery_tip", as: :delivery_tip
    get "hair-salon-tip-calculator", to: "calculators#hair_salon_tip", as: :hair_salon_tip
    get "bar-tip-calculator", to: "calculators#bar_tip", as: :bar_tip
    get "sale-price-calculator", to: "calculators#sale_price", as: :sale_price
    get "coupon-calculator", to: "calculators#coupon", as: :coupon
    get "clearance-calculator", to: "calculators#clearance", as: :clearance
    get "cost-per-km-calculator", to: "calculators#cost_per_km", as: :cost_per_km
    get "kwh-to-cost-calculator", to: "calculators#kwh_to_cost", as: :kwh_to_cost
    get "rent-per-sqm-calculator", to: "calculators#rent_per_sqm", as: :rent_per_sqm
    get "price-per-weight-calculator", to: "calculators#price_per_weight", as: :price_per_weight
    get "fuel-cost-trip-calculator", to: "calculators#fuel_cost_trip", as: :fuel_cost_trip
    get "data-usage-cost-calculator", to: "calculators#data_usage_cost", as: :data_usage_cost
    get "cost-per-person-calculator", to: "calculators#cost_per_person", as: :cost_per_person
    get "cost-per-day-calculator", to: "calculators#cost_per_day", as: :cost_per_day
    get "cost-per-hour-calculator", to: "calculators#cost_per_hour", as: :cost_per_hour
    get "cost-per-serving-calculator", to: "calculators#cost_per_serving", as: :cost_per_serving
    get "cost-per-wear-calculator", to: "calculators#cost_per_wear", as: :cost_per_wear
    get "cost-per-page-calculator", to: "calculators#cost_per_page", as: :cost_per_page
    get "price-per-liter-calculator", to: "calculators#price_per_liter", as: :price_per_liter
    get "words-per-minute-calculator", to: "calculators#words_per_minute", as: :words_per_minute
    get "cost-per-mile-calculator", to: "calculators#cost_per_mile", as: :cost_per_mile
    get "work-hours-calculator", to: "calculators#work_hours", as: :work_hours
    get "shift-duration-calculator", to: "calculators#shift_duration", as: :shift_duration
    get "days-until-calculator", to: "calculators#days_until", as: :days_until
    get "business-days-calculator", to: "calculators#business_days", as: :business_days
    get "time-card-calculator", to: "calculators#time_card", as: :time_card
    get "work-break-calculator", to: "calculators#work_break", as: :work_break
    get "word-counter", to: "calculators#word_counter", as: :word_counter
    get "character-counter", to: "calculators#character_counter", as: :character_counter
    get "case-converter", to: "calculators#case_converter", as: :case_converter
    get "remove-duplicates", to: "calculators#remove_duplicates", as: :remove_duplicates
    get "json-formatter", to: "calculators#json_formatter", as: :json_formatter
    get "lorem-ipsum-generator", to: "calculators#lorem_ipsum", as: :lorem_ipsum
    get "text-diff-checker", to: "calculators#text_diff", as: :text_diff
    get "string-encoder-decoder", to: "calculators#string_encoder", as: :string_encoder
    get "regex-tester", to: "calculators#regex_tester", as: :regex_tester
    get "markdown-preview", to: "calculators#markdown_preview", as: :markdown_preview
    get "secure-random-generator", to: "calculators#secure_random", as: :secure_random
    get "uuid-generator", to: "calculators#uuid_generator", as: :uuid_generator
    get "hash-generator", to: "calculators#hash_generator", as: :hash_generator
    get "hmac-generator", to: "calculators#hmac_generator", as: :hmac_generator
    get "code-minifier-beautifier", to: "calculators#code_minifier", as: :code_minifier
    get "escape-unescape-tool", to: "calculators#escape_unescape", as: :escape_unescape
    get "jwt-decoder", to: "calculators#jwt_decoder", as: :jwt_decoder
    get "sql-formatter", to: "calculators#sql_formatter", as: :sql_formatter
    get "cron-expression-parser", to: "calculators#cron_parser", as: :cron_parser
    get "yaml-to-json-converter", to: "calculators#yaml_to_json", as: :yaml_to_json
    get "csv-to-json-converter", to: "calculators#csv_to_json", as: :csv_to_json
    get "xml-to-json-converter", to: "calculators#xml_to_json", as: :xml_to_json
    get "url-parser", to: "calculators#url_parser", as: :url_parser
    get "http-header-parser", to: "calculators#http_header_parser", as: :http_header_parser
    get "cidr-subnet-calculator", to: "calculators#subnet_calculator", as: :subnet_calculator
    get "unix-timestamp-converter", to: "calculators#unix_timestamp", as: :unix_timestamp
    get "color-converter", to: "calculators#color_converter", as: :color_converter
    get "html-entity-encoder-decoder", to: "calculators#html_entity_encoder", as: :html_entity_encoder
    get "csv-to-excel-converter", to: "calculators#csv_to_excel", as: :csv_to_excel
    get "excel-to-csv-converter", to: "calculators#excel_to_csv", as: :excel_to_csv
    get "markdown-to-html-converter", to: "calculators#markdown_to_html", as: :markdown_to_html
    get "html-to-markdown-converter", to: "calculators#html_to_markdown", as: :html_to_markdown
    get "txt-to-pdf-converter", to: "calculators#txt_to_pdf", as: :txt_to_pdf
    get "csv-to-pdf-converter", to: "calculators#csv_to_pdf", as: :csv_to_pdf
    get "markdown-to-pdf-converter", to: "calculators#markdown_to_pdf", as: :markdown_to_pdf
    get "excel-to-pdf-converter", to: "calculators#excel_to_pdf", as: :excel_to_pdf
    get "docx-to-pdf-converter", to: "calculators#docx_to_pdf", as: :docx_to_pdf
    get "cron-job-generator", to: "calculators#cron_builder", as: :cron_builder
    get "color-palette-picker", to: "calculators#color_palette_picker", as: :color_palette_picker
    get "password-generator", to: "calculators#password_generator", as: :password_generator
    get "csp-header-builder", to: "calculators#csp_builder", as: :csp_builder
    get "chmod-calculator", to: "calculators#chmod_calculator", as: :chmod_calculator
    get "port-number-reference", to: "calculators#port_reference", as: :port_reference
    get "qr-code-generator", to: "calculators#qr_code_generator", as: :qr_code_generator
    get "base64-image-encoder", to: "calculators#base64_image_encoder", as: :base64_image_encoder
    get "markdown-table-generator", to: "calculators#markdown_table_generator", as: :markdown_table_generator
    get "json-to-csv-converter", to: "calculators#json_to_csv", as: :json_to_csv
    get "nginx-config-generator", to: "calculators#nginx_config_generator", as: :nginx_config_generator
    get "dockerfile-generator", to: "calculators#dockerfile_generator", as: :dockerfile_generator
    get "gitignore-generator", to: "calculators#gitignore_generator", as: :gitignore_generator
    get "env-variable-validator", to: "calculators#env_validator", as: :env_validator
    get "regex-builder", to: "calculators#regex_builder", as: :regex_builder
    get "cors-header-checker", to: "calculators#cors_checker", as: :cors_checker
    get "ssl-certificate-decoder", to: "calculators#ssl_cert_decoder", as: :ssl_cert_decoder
    get "ip-address-lookup", to: "calculators#ip_lookup", as: :ip_lookup
    get "dns-lookup", to: "calculators#dns_lookup", as: :dns_lookup
    get "mac-address-lookup", to: "calculators#mac_lookup", as: :mac_lookup
    get "odt-to-docx-converter", to: "calculators#odt_to_docx", as: :odt_to_docx
    get "odt-to-pdf-converter", to: "calculators#odt_to_pdf", as: :odt_to_pdf
    get "docx-to-odt-converter", to: "calculators#docx_to_odt", as: :docx_to_odt
    get "base64-encoder-decoder", to: "calculators#base64_encoder", as: :base64_encoder
    get "url-encoder-decoder", to: "calculators#url_encoder", as: :url_encoder
    get "html-formatter-beautifier", to: "calculators#html_formatter", as: :html_formatter
    get "css-formatter-beautifier", to: "calculators#css_formatter", as: :css_formatter
    get "javascript-formatter-beautifier", to: "calculators#js_formatter", as: :js_formatter
    get "json-validator", to: "calculators#json_validator", as: :json_validator
    get "json-to-yaml-converter", to: "calculators#json_to_yaml", as: :json_to_yaml
    get "curl-to-code-converter", to: "calculators#curl_to_code", as: :curl_to_code
    get "json-to-typescript-generator", to: "calculators#json_to_typescript", as: :json_to_typescript
    get "html-to-jsx-converter", to: "calculators#html_to_jsx", as: :html_to_jsx
    get "hex-ascii-converter", to: "calculators#hex_ascii", as: :hex_ascii
    get "http-status-code-reference", to: "calculators#http_status_reference", as: :http_status_reference
    get "robots-txt-generator", to: "calculators#robots_txt", as: :robots_txt
    get "htaccess-generator", to: "calculators#htaccess_generator", as: :htaccess_generator
    get "regex-explainer", to: "calculators#regex_explainer", as: :regex_explainer
    get "open-graph-preview", to: "calculators#og_preview", as: :og_preview
    get "svg-to-png-converter", to: "calculators#svg_to_png", as: :svg_to_png
    get "alarm-timer", to: "calculators#alarm_timer", as: :alarm_timer
    get "alarm-clock", to: "calculators#alarm_clock", as: :alarm_clock
    get "alarm-clock/active", to: "calculators#alarm_clock_active", as: :alarm_clock_active
    get "stopwatch", to: "calculators#stopwatch", as: :stopwatch
    get "pomodoro-timer", to: "calculators#pomodoro_timer", as: :pomodoro_timer
    get "text-to-speech", to: "calculators#text_to_speech", as: :text_to_speech
    get "temperature-converter", to: "calculators#temperature_converter", as: :temperature_converter
    get "length-converter", to: "calculators#length_converter", as: :length_converter
    get "weight-converter", to: "calculators#weight_converter", as: :weight_converter
    get "speed-converter", to: "calculators#speed_converter", as: :speed_converter
    get "byte-converter", to: "calculators#byte_converter", as: :byte_converter
    get "css-box-shadow-generator", to: "calculators#css_box_shadow", as: :css_box_shadow
    get "css-flexbox-generator", to: "calculators#css_flexbox", as: :css_flexbox
    get "px-to-rem-converter", to: "calculators#px_to_rem", as: :px_to_rem
    get "meta-tag-generator", to: "calculators#meta_tag_generator", as: :meta_tag_generator
    get "favicon-generator", to: "calculators#favicon_generator", as: :favicon_generator
    get "morse-code-translator", to: "calculators#morse_code", as: :morse_code
    get "roman-numeral-converter", to: "calculators#roman_numeral", as: :roman_numeral
    get "fake-data-generator", to: "calculators#fake_data_generator", as: :fake_data_generator
    get "barcode-generator", to: "calculators#barcode_generator", as: :barcode_generator
    get "schema-markup-generator", to: "calculators#schema_generator", as: :schema_generator
    get "keyword-density-checker", to: "calculators#keyword_density", as: :keyword_density
    get "prime-number-checker", to: "calculators#prime_checker", as: :prime_checker
    get "random-number-generator", to: "calculators#random_number", as: :random_number
    get "image-resizer", to: "calculators#image_resizer", as: :image_resizer
  end

  # Blog
  get "blog", to: "blog#index", as: :blog
  get "blog/:slug", to: "blog#show", as: :blog_post

  # Static pages
  get "privacy-policy", to: "pages#privacy_policy", as: :privacy_policy
  get "terms-of-service", to: "pages#terms_of_service", as: :terms_of_service
  get "about", to: "pages#about", as: :about
  get "contact", to: "pages#contact", as: :contact
  post "contact", to: "contact_messages#create"
  get "disclaimer", to: "pages#disclaimer", as: :disclaimer

  # Newsletter
  post "newsletter", to: "newsletter_subscriptions#create", as: :newsletter_subscribe

  # Calculator embeds
  get "embed/:category/:slug", to: "embeds#show", as: :calculator_embed

  # SEO
  get "sitemap.xml", to: "sitemap#show", defaults: { format: :xml }
  get "robots.txt", to: "robots#show", defaults: { format: :text }

  # Calculator suites - guided multi-step workflows
  scope :suites do
    get "home-buying", to: "suites#home_buying", as: :suite_home_buying
    get "fitness", to: "suites#fitness", as: :suite_fitness
    get "business-startup", to: "suites#business_startup", as: :suite_business_startup
  end

  # Comparison pages
  get "finance/15-year-vs-30-year-mortgage", to: "comparisons#mortgage_terms", as: :compare_mortgage_terms
  get "health/bmi-vs-body-fat", to: "comparisons#bmi_vs_body_fat", as: :compare_bmi_vs_body_fat
  get "finance/stocks-vs-crypto", to: "comparisons#stocks_vs_crypto", as: :compare_stocks_vs_crypto
  get "health/keto-vs-standard-macros", to: "comparisons#keto_vs_macros", as: :compare_keto_vs_macros
  get "finance/simple-vs-compound-interest", to: "comparisons#simple_vs_compound", as: :compare_simple_vs_compound

  # Programmatic SEO pages — auto-generated from ProgrammaticSeo::Registry
  ProgrammaticSeo::Registry.all_slugs.each do |slug|
    page = ProgrammaticSeo::Registry.find(slug)
    get slug, to: "programmatic#show", defaults: { programmatic_slug: slug }, as: page[:route_name]
  end

  # Category landing pages (must be last to avoid catching other routes)
  get ":category", to: "categories#show", as: :category,
      constraints: { category: /finance|math|physics|health|construction|everyday/ }

  root "home#index"
end
