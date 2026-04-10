# frozen_string_literal: true

class CalculatorRegistry
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
    byte-converter favicon-generator
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

  FINANCE_CALCULATORS = [
    { name: "Mortgage Calculator", slug: "mortgage-calculator", path: :finance_mortgage_path, description: "Calculate your monthly mortgage payment, total interest, and total cost of your home loan.", icon_path: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-4 0h4" },
    { name: "Compound Interest Calculator", slug: "compound-interest-calculator", path: :finance_compound_interest_path, description: "See how your money grows over time with the power of compound interest.", icon_path: "M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" },
    { name: "Loan Calculator", slug: "loan-calculator", path: :finance_loan_path, description: "Calculate monthly payments, total interest, and payoff date for any loan.", icon_path: "M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" },
    { name: "Investment Calculator", slug: "investment-calculator", path: :finance_investment_path, description: "Project the future value of your investments with regular contributions.", icon_path: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Retirement Calculator", slug: "retirement-calculator", path: :finance_retirement_path, description: "Plan your retirement savings and estimate your monthly retirement income.", icon_path: "M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" },
    { name: "Pension Calculator", slug: "pension-calculator", path: :finance_pension_path, description: "Project your pension pot and monthly retirement income with inflation adjustments in today's money.", icon_path: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Debt Payoff Calculator", slug: "debt-payoff-calculator", path: :finance_debt_payoff_path, description: "Find out when you'll be debt-free and how much interest you'll pay.", icon_path: "M9 14l6-6m-5.5.5h.01m4.99 5h.01M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16l3.5-2 3.5 2 3.5-2 3.5 2z" },
    { name: "Salary Calculator", slug: "salary-calculator", path: :finance_salary_path, description: "Convert between hourly, daily, weekly, biweekly, monthly, and annual salary.", icon_path: "M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" },
    { name: "Savings Goal Calculator", slug: "savings-goal-calculator", path: :finance_savings_goal_path, description: "Calculate how much you need to save monthly to reach your financial goal.", icon_path: "M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" },
    { name: "ROI Calculator", slug: "roi-calculator", path: :finance_roi_path, description: "Calculate return on investment as a percentage from cost and gain.", icon_path: "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" },
    { name: "Profit Margin Calculator", slug: "profit-margin-calculator", path: :finance_profit_margin_path, description: "Calculate gross and net profit margin from revenue and costs.", icon_path: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Inflation Calculator", slug: "inflation-calculator", path: :finance_inflation_path, description: "Calculate how inflation erodes purchasing power over time.", icon_path: "M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" },
    { name: "Break-Even Calculator", slug: "break-even-calculator", path: :finance_break_even_path, description: "Calculate the break-even point in units and revenue for your business.", icon_path: "M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "Markup vs Margin Calculator", slug: "markup-margin-calculator", path: :finance_markup_margin_path, description: "Convert between markup percentage and profit margin percentage.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "Rent vs Buy Calculator", slug: "rent-vs-buy-calculator", path: :finance_rent_vs_buy_path, description: "Compare the total cost of renting versus buying a home over time.", icon_path: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-4 0h4" },
    { name: "Dividend Yield Calculator", slug: "dividend-yield-calculator", path: :finance_dividend_yield_path, description: "Calculate dividend yield, annual income, and yield on cost for stocks.", icon_path: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "DCA Calculator", slug: "dca-calculator", path: :finance_dca_path, description: "See how dollar cost averaging builds wealth with regular investments over time.", icon_path: "M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" },
    { name: "Solar Savings Calculator", slug: "solar-savings-calculator", path: :finance_solar_savings_path, description: "Estimate how much money solar panels can save on your electricity bills.", icon_path: "M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" },
    { name: "Tax Bracket Calculator", slug: "tax-bracket-calculator", path: :finance_tax_bracket_path, description: "Calculate your federal income tax based on your filing status and taxable income.", icon_path: "M9 14l6-6m-5.5.5h.01m4.99 5h.01M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16l3.5-2 3.5 2 3.5-2 3.5 2z" },
    { name: "Auto Loan Calculator", slug: "auto-loan-calculator", path: :finance_auto_loan_path, description: "Calculate your monthly car payment, total interest, and total cost of an auto loan.", icon_path: "M9 17a2 2 0 11-4 0 2 2 0 014 0zM19 17a2 2 0 11-4 0 2 2 0 014 0z" },
    { name: "Credit Card Payoff Calculator", slug: "credit-card-payoff-calculator", path: :finance_credit_card_payoff_path, description: "Calculate how long it takes to pay off credit card debt and how much interest you'll pay.", icon_path: "M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" },
    { name: "Net Worth Calculator", slug: "net-worth-calculator", path: :finance_net_worth_path, description: "Calculate your total net worth by adding up assets and subtracting liabilities.", icon_path: "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" },
    { name: "Home Affordability Calculator", slug: "home-affordability-calculator", path: :finance_home_affordability_path, description: "Find out how much house you can afford based on your income, debts, and down payment.", icon_path: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-4 0h4" },
    { name: "Business Loan Calculator", slug: "business-loan-calculator", path: :finance_business_loan_path, description: "Calculate monthly payments, total interest, and total cost for a business loan.", icon_path: "M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" },
    { name: "Currency Converter", slug: "currency-converter", path: :finance_currency_converter_path, description: "Convert between major world currencies using approximate exchange rates.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "Paycheck Calculator", slug: "paycheck-calculator", path: :finance_paycheck_path, description: "Calculate your take-home pay after federal tax, state tax, FICA, and deductions.", icon_path: "M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" },
    { name: "401(k) Calculator", slug: "401k-calculator", path: :finance_four_oh_one_k_path, description: "Project your 401(k) retirement savings with employer match and compound growth.", icon_path: "M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" },
    { name: "Amortization Calculator", slug: "amortization-calculator", path: :finance_amortization_path, description: "Generate a full month-by-month amortization schedule for any loan.", icon_path: "M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "Stock Profit Calculator", slug: "stock-profit-calculator", path: :finance_stock_profit_path, description: "Calculate stock trading profit, ROI, and capital gains from buy and sell prices.", icon_path: "M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" },
    { name: "CD Calculator", slug: "cd-calculator", path: :finance_cd_path, description: "Calculate certificate of deposit maturity value and interest earned.", icon_path: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Savings Interest Calculator", slug: "savings-interest-calculator", path: :finance_savings_interest_path, description: "See how your savings grow with interest and regular monthly deposits.", icon_path: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "House Flip Calculator", slug: "house-flip-calculator", path: :finance_house_flip_path, description: "Estimate house flipping profit, ROI, and the 70% rule for real estate investors.", icon_path: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-4 0h4" },
    { name: "Student Loan Calculator", slug: "student-loan-calculator", path: :finance_student_loan_path, description: "Calculate student loan payments under standard, graduated, extended, and income-driven plans.", icon_path: "M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" },
    { name: "Estate Tax Calculator", slug: "estate-tax-calculator", path: :finance_estate_tax_path, description: "Estimate federal estate tax based on estate value, exemptions, and filing status.", icon_path: "M9 14l6-6m-5.5.5h.01m4.99 5h.01M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16l3.5-2 3.5 2 3.5-2 3.5 2z" },
    { name: "Crypto Profit Calculator", slug: "crypto-profit-calculator", path: :finance_crypto_profit_path, description: "Calculate cryptocurrency trading profit, ROI, and capital gains.", icon_path: "M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" },
    { name: "Invoice Generator (Simple)", slug: "invoice-generator", path: :finance_invoice_generator_path, description: "Create professional invoices with line items, tax, discount, and download as PDF.", icon_path: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" },
    { name: "Invoice Generator (Detailed)", slug: "detailed-invoice-generator", path: :finance_detailed_invoice_generator_path, description: "Create detailed invoices with per-item tax, unit codes, and individual discounts. Download as PDF.", icon_path: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" },
    { name: "FIRE Calculator", slug: "fire-calculator", path: :finance_fire_path, description: "Calculate your FIRE number, years to financial independence, and monthly savings needed to retire early.", icon_path: "M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z" },
    { name: "Rent Affordability Calculator", slug: "rent-affordability-calculator", path: :finance_rent_affordability_path, description: "Find out how much rent you can afford using the 30% rule and 50/30/20 budget breakdown.", icon_path: "M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" },
    { name: "Capital Gains Tax Calculator", slug: "capital-gains-tax-calculator", path: :finance_capital_gains_tax_path, description: "Calculate federal capital gains tax with short-term and long-term rates, NIIT, and 2024 brackets.", icon_path: "M9 14l6-6m-5.5.5h.01m4.99 5h.01M19 21l-7-5-7 5V5a2 2 0 012-2h10a2 2 0 012 2v16z" },
    { name: "Down Payment Calculator", slug: "down-payment-calculator", path: :finance_down_payment_path, description: "Calculate your home down payment target, savings gap, and timeline to save enough.", icon_path: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-4 0h4" },
    { name: "Inheritance Tax Calculator", slug: "inheritance-tax-calculator", path: :finance_inheritance_tax_path, description: "Estimate state inheritance tax for the 6 US states that levy it by relationship type.", icon_path: "M9 14l6-6m-5.5.5h.01m4.99 5h.01M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16l3.5-2 3.5 2 3.5-2 3.5 2z" },
    { name: "Side Hustle Calculator", slug: "side-hustle-calculator", path: :finance_side_hustle_path, description: "Calculate your side hustle take-home pay after self-employment tax and income tax.", icon_path: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Emergency Fund Calculator", slug: "emergency-fund-calculator", path: :finance_emergency_fund_path, description: "Calculate how much you need in your emergency fund and track progress toward your goal.", icon_path: "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" },
    { name: "Lease vs Buy Car Calculator", slug: "lease-vs-buy-calculator", path: :finance_lease_vs_buy_path, description: "Compare the total cost of leasing versus buying a car to find the cheaper option.", icon_path: "M9 17a2 2 0 11-4 0 2 2 0 014 0zM19 17a2 2 0 11-4 0 2 2 0 014 0z" }
  ].freeze

  MATH_CALCULATORS = [
    { name: "Scientific Calculator", slug: "scientific-calculator", path: :math_scientific_path, description: "Full scientific calculator with trigonometry, logarithms, exponents, factorials, memory, and degree/radian modes.", icon_path: "M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "Percentage Calculator", slug: "percentage-calculator", path: :math_percentage_path, description: "Calculate percentages, percentage change, and percentage of a number.", icon_path: "M7 20l4-16m2 16l4-16M6 9h14M4 15h14" },
    { name: "Fraction Calculator", slug: "fraction-calculator", path: :math_fraction_path, description: "Add, subtract, multiply, and divide fractions with step-by-step solutions.", icon_path: "M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" },
    { name: "Area Calculator", slug: "area-calculator", path: :math_area_path, description: "Calculate the area of common shapes including rectangles, circles, and triangles.", icon_path: "M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6z" },
    { name: "Circle Calculator", slug: "circumference-calculator", path: :math_circumference_path, description: "Calculate the circumference and area of a circle from radius or diameter.", icon_path: "M12 2a10 10 0 100 20 10 10 0 000-20z" },
    { name: "Exponent Calculator", slug: "exponent-calculator", path: :math_exponent_path, description: "Calculate the result of raising a number to any power.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Pythagorean Theorem Calculator", slug: "pythagorean-theorem-calculator", path: :math_pythagorean_path, description: "Calculate the missing side of a right triangle using a² + b² = c².", icon_path: "M4 5a1 1 0 011-1h14a1 1 0 011 1v14a1 1 0 01-1 1H5a1 1 0 01-1-1V5z" },
    { name: "Quadratic Equation Solver", slug: "quadratic-equation-calculator", path: :math_quadratic_path, description: "Solve ax² + bx + c = 0 and find real or complex roots.", icon_path: "M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "Standard Deviation Calculator", slug: "standard-deviation-calculator", path: :math_standard_deviation_path, description: "Calculate mean, standard deviation, and variance from a set of numbers.", icon_path: "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" },
    { name: "GCD & LCM Calculator", slug: "gcd-lcm-calculator", path: :math_gcd_lcm_path, description: "Find the greatest common divisor and least common multiple of two numbers.", icon_path: "M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" },
    { name: "Sample Size Calculator", slug: "sample-size-calculator", path: :math_sample_size_path, description: "Calculate the required sample size for surveys and experiments.", icon_path: "M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" },
    { name: "Aspect Ratio Calculator", slug: "aspect-ratio-calculator", path: :math_aspect_ratio_path, description: "Calculate aspect ratio, resize dimensions, and convert between formats.", icon_path: "M4 5a1 1 0 011-1h14a1 1 0 011 1v14a1 1 0 01-1 1H5a1 1 0 01-1-1V5z" },
    { name: "Matrix Calculator", slug: "matrix-calculator", path: :math_matrix_path, description: "Add, subtract, multiply matrices and calculate determinants and transposes.", icon_path: "M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zm10 0a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zm10 0a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" },
    { name: "Logarithm Calculator", slug: "logarithm-calculator", path: :math_logarithm_path, description: "Calculate logarithms with any base including natural log and log base 10.", icon_path: "M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "Probability Calculator", slug: "probability-calculator", path: :math_probability_path, description: "Calculate probability, odds, and complementary probability from events and outcomes.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Permutation & Combination Calculator", slug: "permutation-combination-calculator", path: :math_permutation_combination_path, description: "Calculate permutations P(n,r) and combinations C(n,r) with formulas.", icon_path: "M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" },
    { name: "Mean Median Mode Calculator", slug: "mean-median-mode-calculator", path: :math_mean_median_mode_path, description: "Calculate mean, median, mode, range, and standard deviation from a data set.", icon_path: "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" },
    { name: "Base Converter", slug: "base-converter", path: :math_base_converter_path, description: "Convert numbers between binary, octal, decimal, and hexadecimal.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "Significant Figures Calculator", slug: "significant-figures-calculator", path: :math_sig_figs_path, description: "Count significant figures and round numbers to a specified number of sig figs.", icon_path: "M7 20l4-16m2 16l4-16M6 9h14M4 15h14" },
    { name: "Scientific Notation Calculator", slug: "scientific-notation-calculator", path: :math_scientific_notation_path, description: "Convert between standard form and scientific notation.", icon_path: "M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "Integral Calculator", slug: "integral-calculator", path: :math_integral_path, description: "Compute definite integrals numerically using Simpson's rule. Supports polynomials, trig, exp, and log.", icon_path: "M7 4c0 0 0 8 0 12s4 4 4 4M17 20c0 0 0-8 0-12s-4-4-4-4" },
    { name: "Prime Number Checker", slug: "prime-number-checker", path: :everyday_prime_checker_path, description: "Check if a number is prime, find its factors, and see nearest primes.", icon_path: "M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "Random Number Generator", slug: "random-number-generator", path: :everyday_random_number_path, description: "Generate cryptographically secure random numbers with custom range and count.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Roman Numeral Converter", slug: "roman-numeral-converter", path: :everyday_roman_numeral_path, description: "Convert between Arabic numbers and Roman numerals bidirectionally.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" }
  ].freeze

  PHYSICS_CALCULATORS = [
    { name: "Velocity Calculator", slug: "velocity-calculator", path: :physics_velocity_path, description: "Calculate speed, distance, or time using the fundamental velocity equation.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Force Calculator", slug: "force-calculator", path: :physics_force_path, description: "Calculate force, mass, or acceleration using Newton's second law (F = ma).", icon_path: "M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" },
    { name: "Kinetic Energy Calculator", slug: "kinetic-energy-calculator", path: :physics_kinetic_energy_path, description: "Calculate kinetic energy, mass, or velocity using KE = 1/2 mv².", icon_path: "M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z" },
    { name: "Ohm's Law Calculator", slug: "ohms-law-calculator", path: :physics_ohms_law_path, description: "Calculate voltage, current, or resistance using Ohm's law (V = IR).", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Projectile Motion Calculator", slug: "projectile-motion-calculator", path: :physics_projectile_motion_path, description: "Calculate range, max height, and flight time for projectile motion.", icon_path: "M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" },
    { name: "Element Mass Calculator", slug: "element-mass-calculator", path: :physics_element_mass_path, description: "Calculate the mass of any element given its volume using density data for all 118 elements.", icon_path: "M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" },
    { name: "Element Volume Calculator", slug: "element-volume-calculator", path: :physics_element_volume_path, description: "Calculate the volume of any element given its mass using density data for all 118 elements.", icon_path: "M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" },
    { name: "Unit Converter", slug: "unit-converter", path: :physics_unit_converter_path, description: "Convert between common units of length, weight, temperature, speed, and more.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "Electricity Cost Calculator", slug: "electricity-cost-calculator", path: :physics_electricity_cost_path, description: "Calculate your electricity bill from power usage, time, and rate — or solve for any variable.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Wire Gauge Calculator", slug: "wire-gauge-calculator", path: :physics_wire_gauge_path, description: "Look up AWG wire diameter, cross-section area, resistance, and max ampacity.", icon_path: "M4 6h16M4 12h16M4 18h7" },
    { name: "Decibel Calculator", slug: "decibel-calculator", path: :physics_decibel_path, description: "Convert between decibels and power or voltage ratios, and add dB levels.", icon_path: "M15.536 8.464a5 5 0 010 7.072M18.364 5.636a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707A1 1 0 0112 5.586V18.414a1 1 0 01-1.707.707L5.586 15z" },
    { name: "Wavelength & Frequency Calculator", slug: "wavelength-frequency-calculator", path: :physics_wavelength_frequency_path, description: "Calculate wavelength, frequency, period, or energy of electromagnetic waves.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Planet Weight Calculator", slug: "planet-weight-calculator", path: :physics_planet_weight_path, description: "See how much you would weigh on Mars, Jupiter, the Moon, and other planets.", icon_path: "M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Resistor Color Code Calculator", slug: "resistor-color-code-calculator", path: :physics_resistor_color_code_path, description: "Decode resistor color bands to find resistance value and tolerance.", icon_path: "M4 6h16M4 12h16M4 18h7" },
    { name: "Gear Ratio Calculator", slug: "gear-ratio-calculator", path: :physics_gear_ratio_path, description: "Calculate gear ratio, output speed, and torque from driving and driven gear teeth.", icon_path: "M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.066 2.573c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.573 1.066c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.066-2.573c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" },
    { name: "Pressure Converter", slug: "pressure-converter", path: :physics_pressure_converter_path, description: "Convert between Pa, bar, psi, atm, mmHg, Torr, and other pressure units.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "Heat Transfer Calculator", slug: "heat-transfer-calculator", path: :physics_heat_transfer_path, description: "Calculate heat transfer rate through materials using Fourier's Law of conduction.", icon_path: "M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z" },
    { name: "Spring Constant Calculator", slug: "spring-constant-calculator", path: :physics_spring_constant_path, description: "Calculate spring constant from force and displacement or mass and period.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" }
  ].freeze

  HEALTH_CALCULATORS = [
    { name: "BMI Calculator", slug: "bmi-calculator", path: :health_bmi_path, description: "Calculate your Body Mass Index and find out your weight category.", icon_path: "M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" },
    { name: "Calorie Calculator", slug: "calorie-calculator", path: :health_calorie_path, description: "Estimate your daily calorie needs based on your age, weight, height, and activity level.", icon_path: "M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z" },
    { name: "Body Fat Calculator", slug: "body-fat-calculator", path: :health_body_fat_path, description: "Estimate your body fat percentage using the U.S. Navy method.", icon_path: "M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" },
    { name: "Pregnancy Due Date Calculator", slug: "pregnancy-due-date-calculator", path: :health_pregnancy_due_date_path, description: "Calculate your estimated due date based on your last menstrual period.", icon_path: "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" },
    { name: "TDEE Calculator", slug: "tdee-calculator", path: :health_tdee_path, description: "Calculate your Total Daily Energy Expenditure based on activity level.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Macro Calculator", slug: "macro-calculator", path: :health_macro_path, description: "Calculate your daily protein, carbs, and fat targets based on your goals.", icon_path: "M4 6h16M4 12h8m-8 6h16" },
    { name: "Pace Calculator", slug: "pace-calculator", path: :health_pace_path, description: "Calculate running or walking pace, time, or distance.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Water Intake Calculator", slug: "water-intake-calculator", path: :health_water_intake_path, description: "Calculate how much water you should drink daily based on your weight and activity.", icon_path: "M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" },
    { name: "Sleep Calculator", slug: "sleep-calculator", path: :health_sleep_path, description: "Find optimal bedtime or wake-up time based on 90-minute sleep cycles.", icon_path: "M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z" },
    { name: "One Rep Max Calculator", slug: "one-rep-max-calculator", path: :health_one_rep_max_path, description: "Estimate your one-rep max from the weight and reps of a working set.", icon_path: "M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" },
    { name: "Dog Age Calculator", slug: "dog-age-calculator", path: :health_dog_age_path, description: "Convert dog years to human years using the scientifically accurate logarithmic formula.", icon_path: "M14 10h4.764a2 2 0 011.789 2.894l-3.5 7A2 2 0 0115.263 21h-4.017c-.163 0-.326-.02-.485-.06L7 20m7-10V5a2 2 0 00-2-2h-.095c-.5 0-.905.405-.905.905a3.61 3.61 0 01-.608 2.006L7 11v9m7-10h-2M7 20H5a2 2 0 01-2-2v-6a2 2 0 012-2h2.5" },
    { name: "Pregnancy Week Calculator", slug: "pregnancy-week-calculator", path: :health_pregnancy_week_path, description: "Track your pregnancy week by week with baby size, development milestones, and symptoms.", icon_path: "M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" },
    { name: "Dog Food Calculator", slug: "dog-food-calculator", path: :health_dog_food_path, description: "Calculate how much food to feed your dog daily based on weight, age, and activity level.", icon_path: "M14 10h4.764a2 2 0 011.789 2.894l-3.5 7A2 2 0 0115.263 21h-4.017c-.163 0-.326-.02-.485-.06L7 20m7-10V5a2 2 0 00-2-2h-.095c-.5 0-.905.405-.905.905a3.61 3.61 0 01-.608 2.006L7 11v9m7-10h-2M7 20H5a2 2 0 01-2-2v-6a2 2 0 012-2h2.5" },
    { name: "Ideal Weight Calculator", slug: "ideal-weight-calculator", path: :health_ideal_weight_path, description: "Calculate your ideal weight range using Devine, Robinson, Miller, and Hamwi formulas.", icon_path: "M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" },
    { name: "BAC Calculator", slug: "bac-calculator", path: :health_bac_path, description: "Estimate your blood alcohol concentration based on drinks, weight, and time.", icon_path: "M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" },
    { name: "Conception Calculator", slug: "conception-calculator", path: :health_conception_path, description: "Estimate your conception date and fertile window from due date or last period.", icon_path: "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" },
    { name: "Heart Rate Zone Calculator", slug: "heart-rate-zone-calculator", path: :health_heart_rate_zone_path, description: "Calculate your 5 heart rate training zones for optimal cardio workouts.", icon_path: "M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" },
    { name: "Keto Calculator", slug: "keto-calculator", path: :health_keto_path, description: "Calculate your daily macros for a ketogenic diet based on your profile and goals.", icon_path: "M4 6h16M4 12h8m-8 6h16" },
    { name: "Intermittent Fasting Calculator", slug: "intermittent-fasting-calculator", path: :health_intermittent_fasting_path, description: "Plan your intermittent fasting schedule with eating and fasting windows.", icon_path: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Ovulation Calculator", slug: "ovulation-calculator", path: :health_ovulation_path, description: "Predict your ovulation date, fertile window, and next period.", icon_path: "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" },
    { name: "Blood Pressure Calculator", slug: "blood-pressure-calculator", path: :health_blood_pressure_path, description: "Check your blood pressure category and get health recommendations.", icon_path: "M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" },
    { name: "Lean Body Mass Calculator", slug: "lean-body-mass-calculator", path: :health_lean_body_mass_path, description: "Calculate your lean body mass and fat mass from body fat or body measurements.", icon_path: "M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" },
    { name: "FFMI Calculator", slug: "ffmi-calculator", path: :health_ffmi_path, description: "Calculate your Fat-Free Mass Index to evaluate muscular development relative to height.", icon_path: "M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" },
    { name: "VO2 Max Calculator", slug: "vo2-max-calculator", path: :health_vo2_max_path, description: "Estimate your VO2 max using the Cooper 12-minute run or 1.5-mile run test.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Protein Intake Calculator", slug: "protein-intake-calculator", path: :health_protein_intake_path, description: "Calculate your optimal daily protein intake based on weight, activity level, and fitness goal.", icon_path: "M4 6h16M4 12h8m-8 6h16" },
    { name: "Pregnancy Weight Gain Calculator", slug: "pregnancy-weight-calculator", path: :health_pregnancy_weight_path, description: "Calculate recommended pregnancy weight gain based on IOM guidelines and pre-pregnancy BMI.", icon_path: "M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" },
    { name: "Alcohol Burnoff Calculator", slug: "alcohol-burnoff-calculator", path: :health_alcohol_burnoff_path, description: "Estimate your BAC and how long until you are sober using the Widmark formula.", icon_path: "M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" },
    { name: "Biological Age Calculator", slug: "biological-age-calculator", path: :health_biological_age_path, description: "Estimate your biological age based on exercise, sleep, diet, stress, and BMI.", icon_path: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" }
  ].freeze

  CONSTRUCTION_CALCULATORS = [
    { name: "Paint Calculator", slug: "paint-calculator", path: :construction_paint_path, description: "Calculate how many gallons of paint you need for a room or surface.", icon_path: "M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01" },
    { name: "Flooring Calculator", slug: "flooring-calculator", path: :construction_flooring_path, description: "Calculate how much flooring material you need for any room.", icon_path: "M4 5a1 1 0 011-1h14a1 1 0 011 1v14a1 1 0 01-1 1H5a1 1 0 01-1-1V5z" },
    { name: "Concrete Calculator", slug: "concrete-calculator", path: :construction_concrete_path, description: "Calculate cubic yards of concrete needed for slabs, footings, and columns.", icon_path: "M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" },
    { name: "Gravel & Mulch Calculator", slug: "gravel-mulch-calculator", path: :construction_gravel_mulch_path, description: "Calculate cubic yards and tons of gravel, mulch, or soil for landscaping.", icon_path: "M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z" },
    { name: "Fence Calculator", slug: "fence-calculator", path: :construction_fence_path, description: "Calculate the number of posts, rails, and pickets needed for a fence.", icon_path: "M4 6h16M4 12h16M4 18h7" },
    { name: "Roofing Calculator", slug: "roofing-calculator", path: :construction_roofing_path, description: "Calculate shingles, felt, and nails needed for a roofing project.", icon_path: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-4 0h4" },
    { name: "Staircase Calculator", slug: "staircase-calculator", path: :construction_staircase_path, description: "Calculate the number of steps, rise, run, and angle for a staircase.", icon_path: "M4 5a1 1 0 011-1h14a1 1 0 011 1v14a1 1 0 01-1 1H5a1 1 0 01-1-1V5z" },
    { name: "Deck Calculator", slug: "deck-calculator", path: :construction_deck_path, description: "Calculate boards, joists, posts, and screws needed to build a deck.", icon_path: "M4 5a1 1 0 011-1h14a1 1 0 011 1v14a1 1 0 01-1 1H5a1 1 0 01-1-1V5z" },
    { name: "Wallpaper Calculator", slug: "wallpaper-calculator", path: :construction_wallpaper_path, description: "Calculate rolls of wallpaper needed for a room with pattern repeat waste.", icon_path: "M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01" },
    { name: "Tile Calculator", slug: "tile-calculator", path: :construction_tile_path, description: "Calculate tiles, grout, and adhesive needed for a floor or wall project.", icon_path: "M4 5a1 1 0 011-1h14a1 1 0 011 1v14a1 1 0 01-1 1H5a1 1 0 01-1-1V5z" },
    { name: "Lumber Calculator", slug: "lumber-calculator", path: :construction_lumber_path, description: "Calculate board feet and cost for lumber purchases.", icon_path: "M4 6h16M4 12h16M4 18h7" },
    { name: "HVAC BTU Calculator", slug: "hvac-btu-calculator", path: :construction_hvac_btu_path, description: "Calculate the BTU and tonnage needed to heat or cool a room.", icon_path: "M17.657 18.657A8 8 0 016.343 7.343S7 9 9 10c0-2 .5-5 2.986-7C14 5 16.09 5.777 17.656 7.343A7.975 7.975 0 0120 13a7.975 7.975 0 01-2.343 5.657z" },
    { name: "Drywall Calculator", slug: "drywall-calculator", path: :construction_drywall_path, description: "Calculate drywall sheets, joint compound, and tape needed for any room.", icon_path: "M4 5a1 1 0 011-1h14a1 1 0 011 1v14a1 1 0 01-1 1H5a1 1 0 01-1-1V5z" },
    { name: "Insulation Calculator", slug: "insulation-calculator", path: :construction_insulation_path, description: "Calculate insulation R-value, thickness, quantity, and cost by climate zone.", icon_path: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-4 0h4" },
    { name: "Plumbing Pipe Size Calculator", slug: "plumbing-calculator", path: :construction_plumbing_path, description: "Calculate plumbing pipe size based on fixture units per UPC standards.", icon_path: "M5.636 18.364a9 9 0 010-12.728m12.728 0a9 9 0 010 12.728M12 9v3m0 0v3m0-3h3m-3 0H9" },
    { name: "Electrical Load Calculator", slug: "electrical-load-calculator", path: :construction_electrical_load_path, description: "Calculate total electrical load and recommended panel size per NEC standards.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Retaining Wall Calculator", slug: "retaining-wall-calculator", path: :construction_retaining_wall_path, description: "Calculate blocks, cap stones, gravel, and backfill for a retaining wall.", icon_path: "M4 6h16M4 12h16M4 18h7" },
    { name: "Miter Angle Calculator", slug: "miter-angle-calculator", path: :construction_miter_angle_path, description: "Calculate miter and corner angles for any polygon frame, box, or molding project.", icon_path: "M4 5a1 1 0 011-1h14a1 1 0 011 1v14a1 1 0 01-1 1H5a1 1 0 01-1-1V5z" },
    { name: "Wood Moisture Content Calculator", slug: "wood-moisture-calculator", path: :construction_wood_moisture_path, description: "Calculate wood moisture content from wet and oven-dry weights using the standard MC formula.", icon_path: "M12 2c-5.33 4.55-8 8.48-8 11.8 0 4.98 3.8 8.2 8 8.2s8-3.22 8-8.2c0-3.32-2.67-7.25-8-11.8z" },
    { name: "Wood Shrinkage Calculator", slug: "wood-shrinkage-calculator", path: :construction_wood_shrinkage_path, description: "Calculate tangential and radial wood shrinkage by species as it dries from green to target MC.", icon_path: "M7 20l4-16m2 16l4-16M6 9h14M4 15h14" },
    { name: "Wood Species Weight Calculator", slug: "wood-weight-calculator", path: :construction_wood_weight_path, description: "Calculate the weight of any wood board or panel by species, dimensions, and quantity.", icon_path: "M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "Rip Cut Calculator", slug: "rip-cut-calculator", path: :construction_rip_cut_path, description: "Calculate how many strips you can rip from a board accounting for saw blade kerf waste.", icon_path: "M5.636 18.364a9 9 0 010-12.728m12.728 0a9 9 0 010 12.728M12 9v3m0 0v3m0-3h3m-3 0H9" },
    { name: "Cabinet Door Parts Calculator", slug: "cabinet-door-calculator", path: :construction_cabinet_door_path, description: "Calculate stile, rail, and panel dimensions for Shaker-style cabinet doors with tongue-and-groove joinery.", icon_path: "M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" }
  ].freeze

  TEXTILE_CALCULATORS = [
    { name: "Fabric Yardage Calculator", slug: "fabric-yardage-calculator", path: :textile_fabric_yardage_path, description: "Calculate how many yards or meters of fabric you need for a sewing project, with conversions between 45\", 54\", and 60\" widths.", icon_path: "M4 6a2 2 0 012-2h12a2 2 0 012 2v2H4V6zm0 6h16v8a2 2 0 01-2 2H6a2 2 0 01-2-2v-8z" },
    { name: "Seam Allowance Converter", slug: "seam-allowance-converter", path: :textile_seam_allowance_path, description: "Convert seam allowances between imperial and metric and see cut size vs finished size for any pattern piece.", icon_path: "M7 20l4-16m2 16l4-16M6 9h14M4 15h14" },
    { name: "Knitting Gauge Calculator", slug: "knitting-gauge-calculator", path: :textile_knitting_gauge_path, description: "Calculate cast-on stitches from your gauge swatch and target measurement, or convert between pattern gauge and your actual gauge.", icon_path: "M4 6h16M4 12h16M4 18h16" },
    { name: "Crochet Gauge Calculator", slug: "crochet-gauge-calculator", path: :textile_crochet_gauge_path, description: "Calculate starting chain and row count for crochet projects based on your gauge swatch and target measurements.", icon_path: "M12 2a10 10 0 100 20 10 10 0 000-20zm0 4a6 6 0 110 12 6 6 0 010-12z" },
    { name: "Needle & Hook Size Converter", slug: "knitting-needle-hook-size-converter", path: :textile_needle_hook_size_path, description: "Convert knitting needle sizes between US, UK, and metric, and crochet hook sizes between US letter and millimeter.", icon_path: "M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" },
    { name: "Yarn Yardage Calculator", slug: "yarn-yardage-calculator", path: :textile_yarn_yardage_path, description: "Estimate how much yarn you need for knitting or crochet projects by project type, size, and yarn weight.", icon_path: "M12 2a10 10 0 100 20 10 10 0 000-20z" },
    { name: "Quilt Backing Calculator", slug: "quilt-backing-calculator", path: :textile_quilt_backing_path, description: "Calculate quilt backing fabric yardage from quilt top dimensions including the extra overage needed for longarm quilting.", icon_path: "M4 5a1 1 0 011-1h14a1 1 0 011 1v14a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 12h16M12 4v16" },
    { name: "Half-Square Triangle Calculator", slug: "half-square-triangle-calculator", path: :textile_half_square_triangle_path, description: "Calculate the cut square size needed to make half-square triangles of a finished size using 2-at-a-time, 4-at-a-time, or 8-at-a-time methods.", icon_path: "M4 20L20 4M4 20h16L4 4v16z" },
    { name: "Quilt Binding Strips Calculator", slug: "quilt-binding-strips-calculator", path: :textile_binding_strips_path, description: "Calculate the number and length of fabric binding strips needed to bind a quilt of any size with joined diagonal seams.", icon_path: "M4 6h16M4 12h16M4 18h16" },
    { name: "Fabric GSM Calculator", slug: "fabric-gsm-calculator", path: :textile_fabric_gsm_path, description: "Calculate fabric weight in grams per square meter (GSM) from a weighed sample of any size.", icon_path: "M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" },
    { name: "Fabric Shrinkage Calculator", slug: "fabric-shrinkage-calculator", path: :textile_fabric_shrinkage_path, description: "Calculate fabric shrinkage percentage from before and after washing measurements and determine the extra fabric to cut.", icon_path: "M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4" },
    { name: "Cross-Stitch Fabric Calculator", slug: "cross-stitch-fabric-calculator", path: :textile_cross_stitch_fabric_path, description: "Calculate the finished size of a cross-stitch design on any Aida count (11, 14, 16, 18, 22) and the fabric size to buy.", icon_path: "M4 4h16v16H4zM8 8h8v8H8z" }
  ].freeze

  EVERYDAY_CALCULATORS = [
    { name: "Tip Calculator", slug: "tip-calculator", path: :everyday_tip_path, description: "Calculate tip amount and total bill, with options to split between people.", icon_path: "M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" },
    { name: "Discount Calculator", slug: "discount-calculator", path: :everyday_discount_path, description: "Calculate sale price, savings amount, and discount percentage.", icon_path: "M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" },
    { name: "Age Calculator", slug: "age-calculator", path: :everyday_age_path, description: "Calculate exact age in years, months, and days from a birth date.", icon_path: "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" },
    { name: "Date Difference Calculator", slug: "date-difference-calculator", path: :everyday_date_difference_path, description: "Calculate the number of days, weeks, and months between two dates.", icon_path: "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" },
    { name: "Gas Mileage Calculator", slug: "gas-mileage-calculator", path: :everyday_gas_mileage_path, description: "Calculate fuel economy in MPG or L/100km from distance and fuel used.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Fuel Cost Calculator", slug: "fuel-cost-calculator", path: :everyday_fuel_cost_path, description: "Calculate total fuel cost for a trip based on distance, fuel economy, and gas price.", icon_path: "M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" },
    { name: "GPA Calculator", slug: "gpa-calculator", path: :everyday_gpa_path, description: "Calculate your GPA from grades and credit hours.", icon_path: "M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" },
    { name: "Cooking Converter", slug: "cooking-converter", path: :everyday_cooking_converter_path, description: "Convert between cups, tablespoons, teaspoons, milliliters, ounces, and grams.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "Time Zone Converter", slug: "time-zone-converter", path: :everyday_time_zone_converter_path, description: "Convert time between world time zones with offset display.", icon_path: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Shoe Size Converter", slug: "shoe-size-converter", path: :everyday_shoe_size_path, description: "Convert shoe sizes between US, UK, EU, and CM systems.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "Grade Calculator", slug: "grade-calculator", path: :everyday_grade_path, description: "Calculate your weighted average grade and letter grade from assignments.", icon_path: "M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" },
    { name: "Electricity Bill Calculator", slug: "electricity-bill-calculator", path: :everyday_electricity_bill_path, description: "Estimate your monthly electricity bill from appliance wattage and usage.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Moving Cost Calculator", slug: "moving-cost-calculator", path: :everyday_moving_cost_path, description: "Estimate the cost of moving based on distance, home size, and extras.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "Password Strength Calculator", slug: "password-strength-calculator", path: :everyday_password_strength_path, description: "Check password strength, entropy, and estimated crack time.", icon_path: "M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" },
    { name: "Screen Size Calculator", slug: "screen-size-calculator", path: :everyday_screen_size_path, description: "Calculate screen width, height, and PPI from diagonal size and aspect ratio.", icon_path: "M4 5a1 1 0 011-1h14a1 1 0 011 1v14a1 1 0 01-1 1H5a1 1 0 01-1-1V5z" },
    { name: "Bandwidth Calculator", slug: "bandwidth-calculator", path: :everyday_bandwidth_path, description: "Calculate file download time or required speed from file size and bandwidth.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Unit Price Calculator", slug: "unit-price-calculator", path: :everyday_unit_price_path, description: "Compare unit prices of two products to find the better deal.", icon_path: "M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" },
    { name: "Secure Random Generator", slug: "secure-random-generator", path: :everyday_secure_random_path, description: "Generate cryptographically secure random strings with custom length and character options.", icon_path: "M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" },
    { name: "UUID Generator", slug: "uuid-generator", path: :everyday_uuid_generator_path, description: "Generate cryptographically secure UUID v4 identifiers for databases, APIs, and distributed systems.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "Hash Generator", slug: "hash-generator", path: :everyday_hash_generator_path, description: "Generate SHA-256, SHA-384, SHA-512, and MD5 hash digests from any text input.", icon_path: "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" },
    { name: "HMAC Generator", slug: "hmac-generator", path: :everyday_hmac_generator_path, description: "Generate HMAC-SHA256, HMAC-SHA384, and HMAC-SHA512 message authentication codes.", icon_path: "M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" },
    { name: "JWT Decoder", slug: "jwt-decoder", path: :everyday_jwt_decoder_path, description: "Decode and inspect JWT tokens to view header, payload, claims, and expiration status.", icon_path: "M8 11V7a4 4 0 118 0m-4 8v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2z" },
    { name: "Unix Timestamp Converter", slug: "unix-timestamp-converter", path: :everyday_unix_timestamp_path, description: "Convert between Unix epoch timestamps and human-readable dates in both directions.", icon_path: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Cron Expression Parser", slug: "cron-expression-parser", path: :everyday_cron_parser_path, description: "Parse cron expressions to see human-readable schedules and next run times.", icon_path: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Cron Job Generator", slug: "cron-job-generator", path: :everyday_cron_builder_path, description: "Build cron expressions visually by selecting minute, hour, day, month, and weekday fields.", icon_path: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Color Converter", slug: "color-converter", path: :everyday_color_converter_path, description: "Convert colors between HEX, RGB, and HSL formats with WCAG contrast checking.", icon_path: "M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01" },
    { name: "Color Palette Picker", slug: "color-palette-picker", path: :everyday_color_palette_picker_path, description: "Pick any color from a visual gradient palette and get HEX, RGB, and HSL codes.", icon_path: "M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01" },
    { name: "URL Parser", slug: "url-parser", path: :everyday_url_parser_path, description: "Break any URL into its components: scheme, host, port, path, query parameters, and fragment.", icon_path: "M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" },
    { name: "HTTP Header Parser", slug: "http-header-parser", path: :everyday_http_header_parser_path, description: "Parse raw HTTP headers and analyze security header coverage with a letter grade.", icon_path: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" },
    { name: "CIDR/Subnet Calculator", slug: "cidr-subnet-calculator", path: :everyday_subnet_calculator_path, description: "Calculate network address, broadcast, subnet mask, and usable hosts from IP and CIDR prefix.", icon_path: "M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01" },
    { name: "YAML to JSON Converter", slug: "yaml-to-json-converter", path: :everyday_yaml_to_json_path, description: "Convert between YAML and JSON formats bidirectionally with instant preview.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "CSV to JSON Converter", slug: "csv-to-json-converter", path: :everyday_csv_to_json_path, description: "Convert CSV data to JSON with configurable headers and delimiter options.", icon_path: "M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4" },
    { name: "XML to JSON Converter", slug: "xml-to-json-converter", path: :everyday_xml_to_json_path, description: "Convert XML documents to JSON with attribute and nested element support.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "SQL Formatter", slug: "sql-formatter", path: :everyday_sql_formatter_path, description: "Format and indent SQL queries with keyword uppercasing and clause alignment.", icon_path: "M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4" },
    { name: "HTML Entity Encoder/Decoder", slug: "html-entity-encoder-decoder", path: :everyday_html_entity_encoder_path, description: "Encode text to HTML entities or decode entities back to plain text.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "Code Minifier/Beautifier", slug: "code-minifier-beautifier", path: :everyday_code_minifier_path, description: "Minify or beautify JSON, CSS, HTML, and JavaScript code with size comparison.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "Escape/Unescape Tool", slug: "escape-unescape-tool", path: :everyday_escape_unescape_path, description: "Escape and unescape text for JSON, URL, HTML, backslash, and Unicode formats.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "CSV to Excel Converter", slug: "csv-to-excel-converter", path: :everyday_csv_to_excel_path, description: "Convert CSV data to downloadable Excel .xlsx files entirely in the browser.", icon_path: "M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4" },
    { name: "Excel to CSV Converter", slug: "excel-to-csv-converter", path: :everyday_excel_to_csv_path, description: "Upload an Excel .xlsx file and convert it to CSV format with delimiter options.", icon_path: "M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4" },
    { name: "Markdown to HTML Converter", slug: "markdown-to-html-converter", path: :everyday_markdown_to_html_path, description: "Convert Markdown to clean HTML with live preview. Supports headings, lists, code blocks, tables, and more.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "HTML to Markdown Converter", slug: "html-to-markdown-converter", path: :everyday_html_to_markdown_path, description: "Convert HTML markup to Markdown syntax. Handles headings, formatting, links, tables, and code blocks.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "TXT to PDF Converter", slug: "txt-to-pdf-converter", path: :everyday_txt_to_pdf_path, description: "Convert plain text files to properly formatted, downloadable PDF documents with customizable font size and page layout.", icon_path: "M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "CSV to PDF Converter", slug: "csv-to-pdf-converter", path: :everyday_csv_to_pdf_path, description: "Convert CSV data to a formatted PDF table with headers, alternating row colors, and proper pagination.", icon_path: "M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "Markdown to PDF Converter", slug: "markdown-to-pdf-converter", path: :everyday_markdown_to_pdf_path, description: "Convert Markdown documents to beautifully formatted PDF files with headings, lists, code blocks, and tables.", icon_path: "M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "Excel to PDF Converter", slug: "excel-to-pdf-converter", path: :everyday_excel_to_pdf_path, description: "Convert Excel spreadsheets to formatted PDF tables preserving column structure and data formatting.", icon_path: "M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "DOCX to PDF Converter", slug: "docx-to-pdf-converter", path: :everyday_docx_to_pdf_path, description: "Convert Word documents to PDF format preserving headings, paragraphs, lists, and basic formatting.", icon_path: "M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "Password Generator", slug: "password-generator", path: :everyday_password_generator_path, description: "Generate secure passwords and passphrases with customizable length and character types.", icon_path: "M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" },
    { name: "CSP Header Builder", slug: "csp-header-builder", path: :everyday_csp_builder_path, description: "Build Content-Security-Policy headers visually with per-directive source controls.", icon_path: "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" },
    { name: "chmod Calculator", slug: "chmod-calculator", path: :everyday_chmod_calculator_path, description: "Convert between numeric and symbolic Unix file permissions with a visual toggle grid.", icon_path: "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" },
    { name: "Port Number Reference", slug: "port-number-reference", path: :everyday_port_reference_path, description: "Search common network ports by number or service name with protocol and category info.", icon_path: "M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01" },
    { name: "QR Code Generator", slug: "qr-code-generator", path: :everyday_qr_code_generator_path, description: "Generate QR codes from any text or URL with instant download.", icon_path: "M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z" },
    { name: "Base64 Image Encoder", slug: "base64-image-encoder", path: :everyday_base64_image_encoder_path, description: "Encode images to Base64 data URIs for embedding in CSS and HTML.", icon_path: "M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" },
    { name: "Markdown Table Generator", slug: "markdown-table-generator", path: :everyday_markdown_table_generator_path, description: "Build markdown tables visually with an editable grid and instant output.", icon_path: "M3 10h18M3 14h18M10 3v18M14 3v18" },
    { name: "JSON to CSV Converter", slug: "json-to-csv-converter", path: :everyday_json_to_csv_path, description: "Convert JSON arrays of objects to CSV format with configurable delimiters.", icon_path: "M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4" },
    { name: "Nginx Config Generator", slug: "nginx-config-generator", path: :everyday_nginx_config_generator_path, description: "Generate Nginx server block configurations with SSL, reverse proxy, and caching options.", icon_path: "M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01" },
    { name: "Dockerfile Generator", slug: "dockerfile-generator", path: :everyday_dockerfile_generator_path, description: "Generate Dockerfiles for Ruby, Python, Node.js, Go, and Java with multi-stage build support.", icon_path: "M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01" },
    { name: ".gitignore Generator", slug: "gitignore-generator", path: :everyday_gitignore_generator_path, description: "Generate .gitignore files by selecting languages, frameworks, editors, and operating systems.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "Env Variable Validator", slug: "env-variable-validator", path: :everyday_env_validator_path, description: "Validate .env files for syntax errors, duplicate keys, and exposed secrets.", icon_path: "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Regex Builder", slug: "regex-builder", path: :everyday_regex_builder_path, description: "Build and test regular expressions with live match highlighting and capture groups.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "CORS Header Checker", slug: "cors-header-checker", path: :everyday_cors_checker_path, description: "Analyze CORS response headers and test cross-origin request scenarios.", icon_path: "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" },
    { name: "SSL Certificate Decoder", slug: "ssl-certificate-decoder", path: :everyday_ssl_cert_decoder_path, description: "Decode PEM certificates to view subject, issuer, expiry, SANs, and fingerprints.", icon_path: "M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" },
    { name: "IP Address Lookup", slug: "ip-address-lookup", path: :everyday_ip_lookup_path, description: "Analyze IP addresses for class, private/public status, and optional geolocation lookup.", icon_path: "M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" },
    { name: "DNS Lookup", slug: "dns-lookup", path: :everyday_dns_lookup_path, description: "Query DNS records (A, AAAA, MX, TXT, CNAME, NS, SOA) via DNS-over-HTTPS.", icon_path: "M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" },
    { name: "MAC Address Lookup", slug: "mac-address-lookup", path: :everyday_mac_lookup_path, description: "Identify network device manufacturers from MAC address OUI prefixes.", icon_path: "M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2m-2-4h.01M17 16h.01" },
    { name: "ODT to DOCX Converter", slug: "odt-to-docx-converter", path: :everyday_odt_to_docx_path, description: "Convert OpenDocument .odt files to Microsoft Word .docx format entirely in the browser.", icon_path: "M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "ODT to PDF Converter", slug: "odt-to-pdf-converter", path: :everyday_odt_to_pdf_path, description: "Convert OpenDocument .odt files to PDF format with headings and paragraphs entirely in the browser.", icon_path: "M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "DOCX to ODT Converter", slug: "docx-to-odt-converter", path: :everyday_docx_to_odt_path, description: "Convert Microsoft Word .docx files to OpenDocument .odt format for LibreOffice and OpenOffice.", icon_path: "M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "Alarm Timer", slug: "alarm-timer", path: :everyday_alarm_timer_path, description: "Set a countdown alarm with sound alert and screen flash when time expires.", icon_path: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Alarm Clock", slug: "alarm-clock", path: :everyday_alarm_clock_path, description: "Set an alarm for a specific time and day with sound alert and screen flash.", icon_path: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Stopwatch", slug: "stopwatch", path: :everyday_stopwatch_path, description: "Precision stopwatch with millisecond accuracy, lap time recording, and split time tracking.", icon_path: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Pomodoro Timer", slug: "pomodoro-timer", path: :everyday_pomodoro_timer_path, description: "Focus timer with customizable work and break intervals, auto-transitions, and sound alerts.", icon_path: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Text to Speech", slug: "text-to-speech", path: :everyday_text_to_speech_path, description: "Read any text aloud with adjustable voice, speed, pitch, and volume using browser speech synthesis.", icon_path: "M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" },
    { name: "Temperature Converter", slug: "temperature-converter", path: :everyday_temperature_converter_path, description: "Convert temperatures between Celsius, Fahrenheit, and Kelvin scales instantly with formulas shown.", icon_path: "M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707" },
    { name: "Length Converter", slug: "length-converter", path: :everyday_length_converter_path, description: "Convert length between mm, cm, m, km, inches, feet, yards, and miles instantly.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "Weight Converter", slug: "weight-converter", path: :everyday_weight_converter_path, description: "Convert weight between mg, g, kg, tonnes, ounces, pounds, and stone instantly.", icon_path: "M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" },
    { name: "Speed Converter", slug: "speed-converter", path: :everyday_speed_converter_path, description: "Convert speed between m/s, km/h, mph, knots, and ft/s instantly.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Byte/Data Size Converter", slug: "byte-converter", path: :everyday_byte_converter_path, description: "Convert data sizes between bytes, KB, MB, GB, TB, PB with binary and decimal values.", icon_path: "M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4" },
    { name: "Cup Converter", slug: "cup-converter", path: :everyday_cup_converter_path, description: "Convert cups to mL, liters, fluid ounces, tablespoons, and teaspoons instantly.", icon_path: "M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" },
    { name: "Teaspoon Converter", slug: "teaspoon-converter", path: :everyday_teaspoon_converter_path, description: "Convert teaspoons to mL, cups, tablespoons, fluid ounces, and liters instantly.", icon_path: "M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" },
    { name: "Tablespoon Converter", slug: "tablespoon-converter", path: :everyday_tablespoon_converter_path, description: "Convert tablespoons to mL, cups, teaspoons, fluid ounces, and liters instantly.", icon_path: "M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" },
    { name: "Volume Converter", slug: "volume-converter", path: :everyday_volume_converter_path, description: "Convert volume between cubic feet, cubic meters, cubic yards, liters, and gallons.", icon_path: "M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" },
    { name: "CSS Box Shadow Generator", slug: "css-box-shadow-generator", path: :everyday_css_box_shadow_path, description: "Generate CSS box-shadow code visually with live preview, multiple shadows, and inset support.", icon_path: "M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" },
    { name: "CSS Flexbox Generator", slug: "css-flexbox-generator", path: :everyday_css_flexbox_path, description: "Build CSS Flexbox layouts visually with live preview of flex-direction, justify-content, align-items, and gap.", icon_path: "M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6z" },
    { name: "PX to REM Converter", slug: "px-to-rem-converter", path: :everyday_px_to_rem_path, description: "Convert pixels to REM, EM, PT, and percentage with customizable base font size and quick reference table.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "Meta Tag Generator", slug: "meta-tag-generator", path: :everyday_meta_tag_generator_path, description: "Generate HTML meta tags for SEO, Open Graph, and Twitter Card with character count indicators.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "Favicon Generator", slug: "favicon-generator", path: :everyday_favicon_generator_path, description: "Create favicons from text initials with custom colors and shape. Download all sizes as PNG.", icon_path: "M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" },
    { name: "Schema Markup Generator", slug: "schema-markup-generator", path: :everyday_schema_generator_path, description: "Generate valid JSON-LD schema markup for articles, products, FAQs, local businesses, events, and recipes.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "Keyword Density Checker", slug: "keyword-density-checker", path: :everyday_keyword_density_path, description: "Analyze keyword density, word frequency, bigrams, and trigrams to optimize content for SEO.", icon_path: "M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" },
    { name: "Prime Number Checker", slug: "prime-number-checker", path: :everyday_prime_checker_path, description: "Check if a number is prime, find its factorization, nearest primes, and prime index.", icon_path: "M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" },
    { name: "Random Number Generator", slug: "random-number-generator", path: :everyday_random_number_path, description: "Generate random numbers within any range with unique mode, sorting, and statistics.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Image Resizer", slug: "image-resizer", path: :everyday_image_resizer_path, description: "Resize images in your browser with aspect ratio lock, quality control, and format conversion to PNG, JPEG, or WebP.", icon_path: "M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" },
    { name: "Morse Code Translator", slug: "morse-code-translator", path: :everyday_morse_code_path, description: "Translate text to Morse code and Morse code to text with audio playback of dots and dashes.", icon_path: "M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" },
    { name: "Roman Numeral Converter", slug: "roman-numeral-converter", path: :everyday_roman_numeral_path, description: "Convert numbers to Roman numerals and Roman numerals to numbers for values 1-3999.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "Fake Data Generator", slug: "fake-data-generator", path: :everyday_fake_data_generator_path, description: "Generate realistic fake data for testing with 16 field types. Export as JSON or CSV.", icon_path: "M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4" },
    { name: "Barcode Generator", slug: "barcode-generator", path: :everyday_barcode_generator_path, description: "Generate barcodes in Code 128, EAN-13, and Code 39 formats with SVG and PNG download.", icon_path: "M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z" },
    { name: "HTTP Status Code Reference", slug: "http-status-code-reference", path: :everyday_http_status_reference_path, description: "Complete HTTP status code reference with search and category filtering across all 1xx-5xx codes.", icon_path: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" },
    { name: "Open Graph Preview", slug: "open-graph-preview", path: :everyday_og_preview_path, description: "Preview how your page looks when shared on Facebook and Twitter with live OG tag editing.", icon_path: "M15 12a3 3 0 11-6 0 3 3 0 016 0z M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" },
    { name: "cURL to Code Converter", slug: "curl-to-code-converter", path: :everyday_curl_to_code_path, description: "Convert cURL commands to Python, JavaScript, Ruby, and PHP code instantly.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "JSON to YAML Converter", slug: "json-to-yaml-converter", path: :everyday_json_to_yaml_path, description: "Convert JSON data to clean, readable YAML format with size comparison and key count analysis.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "JSON to TypeScript Generator", slug: "json-to-typescript-generator", path: :everyday_json_to_typescript_path, description: "Generate TypeScript interface definitions from JSON data with automatic type inference and nested object support.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "HTML Formatter/Beautifier", slug: "html-formatter-beautifier", path: :everyday_html_formatter_path, description: "Format, beautify, and minify HTML code with proper indentation, tag counting, and size analysis.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "CSS Formatter/Beautifier", slug: "css-formatter-beautifier", path: :everyday_css_formatter_path, description: "Format, beautify, and minify CSS stylesheets with rule counting, selector analysis, and size comparison.", icon_path: "M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01" },
    { name: "JavaScript Formatter/Beautifier", slug: "javascript-formatter-beautifier", path: :everyday_js_formatter_path, description: "Format, beautify, and minify JavaScript code with function counting, line analysis, and size comparison.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "HTML to JSX Converter", slug: "html-to-jsx-converter", path: :everyday_html_to_jsx_path, description: "Convert HTML to JSX for React. Automatically converts class to className, for to htmlFor, self-closes void elements, and transforms inline styles.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "robots.txt Generator", slug: "robots-txt-generator", path: :everyday_robots_txt_path, description: "Generate and test robots.txt files online. Create crawler rules, add sitemaps, and test if URLs are allowed or blocked.", icon_path: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" },
    { name: "SVG to PNG Converter", slug: "svg-to-png-converter", path: :everyday_svg_to_png_path, description: "Convert SVG to PNG images online using the browser Canvas API. Adjust scale and download the result.", icon_path: "M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" },
    { name: "Base64 Encoder/Decoder", slug: "base64-encoder-decoder", path: :everyday_base64_encoder_path, description: "Encode and decode text to Base64 online. Supports standard and URL-safe Base64 encoding with instant results.", icon_path: "M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" },
    { name: "URL Encoder/Decoder", slug: "url-encoder-decoder", path: :everyday_url_encoder_path, description: "Encode and decode URLs online. Convert special characters to percent-encoded format for safe use in web addresses.", icon_path: "M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" },
    { name: "Hex/ASCII Converter", slug: "hex-ascii-converter", path: :everyday_hex_ascii_path, description: "Convert between hexadecimal and ASCII text. View hex, binary, and decimal representations with multiple output formats.", icon_path: "M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" },
    { name: "Calorie Tracker", slug: "calorie-tracker", path: :everyday_calorie_tracker_path, description: "Track daily calorie intake by time of day. Log meals, view daily summaries, and browse history.", icon_path: "M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01" },
    { name: "Split Bill Calculator", slug: "split-bill-calculator", path: :everyday_split_bill_path, description: "Split the bill evenly among friends with tip and tax included.", icon_path: "M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" },
    { name: "Wedding Budget Calculator", slug: "wedding-budget-calculator", path: :everyday_wedding_budget_path, description: "Plan your wedding budget with a detailed cost breakdown by category.", icon_path: "M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" },
    { name: "Travel Budget Calculator", slug: "travel-budget-calculator", path: :everyday_travel_budget_path, description: "Plan your trip budget with daily and total cost estimates by category.", icon_path: "M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064" },
    { name: "Pet Cost Calculator", slug: "pet-cost-calculator", path: :everyday_pet_cost_path, description: "Estimate the true cost of owning a dog or cat with lifetime expense breakdowns.", icon_path: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Electricity Usage Calculator", slug: "electricity-usage-calculator", path: :everyday_electricity_usage_path, description: "Calculate electricity usage and cost for each appliance with monthly breakdowns.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Subscription Cost Calculator", slug: "subscription-cost-calculator", path: :everyday_subscription_cost_path, description: "Track all your subscriptions and see the total monthly and annual cost.", icon_path: "M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" },
    { name: "JWT Generator", slug: "jwt-generator", path: :everyday_jwt_generator_tool_path, description: "Generate JSON Web Tokens with custom payloads and HMAC-SHA256 signatures.", icon_path: "M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" },
    { name: "API Response Time Calculator", slug: "api-response-time-calculator", path: :everyday_api_response_time_path, description: "Calculate P50, P90, P95, P99 percentiles from API response time data.", icon_path: "M13 10V3L4 14h7v7l9-11h-7z" },
    { name: "Database Size Estimator", slug: "database-size-estimator", path: :everyday_database_size_path, description: "Estimate PostgreSQL table sizes based on column types and row counts.", icon_path: "M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4" },
    { name: "Text Encryptor", slug: "text-encryptor", path: :everyday_text_encryptor_path, description: "Encrypt and decrypt text using AES-256-GCM with PBKDF2 key derivation.", icon_path: "M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" },
    { name: "Uptime Calculator", slug: "uptime-calculator", path: :everyday_uptime_calculator_path, description: "Calculate uptime percentage, nines classification, and allowed downtime per SLA.", icon_path: "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" },
    { name: "Citation Generator", slug: "citation-generator", path: :everyday_citation_generator_path, description: "Generate citations in APA 7th, MLA 9th, and Chicago formats for books, journals, and websites.", icon_path: "M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" },
    { name: "Plagiarism Calculator", slug: "plagiarism-calculator", path: :everyday_plagiarism_path, description: "Compare two texts for similarity using 3-gram Jaccard analysis.", icon_path: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" },
    { name: "Final Grade Calculator", slug: "final-grade-calculator", path: :everyday_final_grade_path, description: "Calculate the grade you need on your final exam to achieve your desired course grade.", icon_path: "M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" },
    { name: "Student Budget Calculator", slug: "student-budget-calculator", path: :everyday_student_budget_path, description: "Plan your college budget by calculating total costs, financial aid, and funding gaps.", icon_path: "M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" },
    { name: "Study Time Planner", slug: "study-time-calculator", path: :everyday_study_time_path, description: "Plan your weekly study schedule based on course credits and difficulty levels.", icon_path: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" }
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
