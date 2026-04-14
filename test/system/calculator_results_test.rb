require "application_system_test_case"

class CalculatorResultsTest < ApplicationSystemTestCase
  # ----------------------------------------------------------------
  # 1. Mortgage Calculator
  # ----------------------------------------------------------------
  test "mortgage calculator computes monthly payment from principal, rate, and years" do
    visit finance_mortgage_path

    fill_in "mortgage-home-price", with: "300000"
    fill_in "mortgage-annual-interest-rate", with: "6.5"
    fill_in "mortgage-loan-term", with: "30"

    # Stimulus reacts on input — wait for the result target to update from its default "$0.00"
    assert_selector "[data-mortgage-calculator-target='monthlyPayment']", text: /[1-9]/, wait: 5
    monthly = find("[data-mortgage-calculator-target='monthlyPayment']").text
    assert_not_equal "$0.00", monthly, "Monthly payment should have been computed"
    assert_match(/\$[\d,]+\.\d{2}/, monthly, "Monthly payment should be formatted as currency")

    total_paid = find("[data-mortgage-calculator-target='totalPaid']").text
    assert_not_equal "$0.00", total_paid

    total_interest = find("[data-mortgage-calculator-target='totalInterest']").text
    assert_not_equal "$0.00", total_interest

    num_payments = find("[data-mortgage-calculator-target='numPayments']").text
    assert_equal "360", num_payments, "30 years * 12 months = 360 payments"
  end

  # ----------------------------------------------------------------
  # 2. BMI Calculator
  # ----------------------------------------------------------------
  test "bmi calculator computes BMI and category from weight and height" do
    visit health_bmi_path

    # Default unit system is metric (kg, cm)
    fill_in "bmi-weight", with: "70"
    fill_in "bmi-height", with: "175"

    assert_selector "[data-bmi-calculator-target='bmi']", text: /[1-9]/, wait: 5
    bmi_value = find("[data-bmi-calculator-target='bmi']").text
    assert_no_match(/\A\u2014\z/, bmi_value, "BMI should not be the default dash")
    # BMI for 70 kg / 1.75 m = ~22.9
    assert_match(/\d+\.\d+/, bmi_value, "BMI should be a decimal number")

    category = find("[data-bmi-calculator-target='category']").text
    assert_not_equal "\u2014", category, "Category should be populated"
    assert_match(/Normal/i, category, "70 kg at 175 cm should be Normal weight")
  end

  # ----------------------------------------------------------------
  # 3. Percentage Calculator
  # ----------------------------------------------------------------
  test "percentage calculator computes X percent of Y" do
    visit math_percentage_path

    # Default mode is "What is X% of Y?"
    fill_in "percentage-value-x", with: "15"
    fill_in "percentage-value-y", with: "200"

    assert_selector "[data-percentage-calculator-target='result']", text: /[1-9]/, wait: 5
    result = find("[data-percentage-calculator-target='result']").text
    assert_not_equal "--", result, "Result should have been computed"
    # 15% of 200 = 30
    assert_match(/30/, result, "15% of 200 should equal 30")
  end

  # ----------------------------------------------------------------
  # 4. Tip Calculator
  # ----------------------------------------------------------------
  test "tip calculator computes tip amount and total from bill and percentage" do
    visit everyday_tip_path

    fill_in "tip-bill-amount", with: "85"
    # Tip percentage field already has a default value of 18
    # Split field already defaults to 1

    assert_selector "[data-tip-calculator-target='resultTip']", text: /[1-9]/, wait: 5
    tip_amount = find("[data-tip-calculator-target='resultTip']").text
    assert_not_equal "$0.00", tip_amount, "Tip amount should have been computed"
    # 18% of $85 = $15.30
    assert_match(/\$15\.30/, tip_amount, "18% tip on $85 should be $15.30")

    total = find("[data-tip-calculator-target='resultTotal']").text
    assert_not_equal "$0.00", total
    # $85 + $15.30 = $100.30
    assert_match(/\$100\.30/, total, "Total should be $100.30")

    per_person = find("[data-tip-calculator-target='resultPerPerson']").text
    assert_not_equal "$0.00", per_person
    assert_match(/\$100\.30/, per_person, "With 1 person, per-person equals total")
  end

  # ----------------------------------------------------------------
  # 5. Loan Calculator
  # ----------------------------------------------------------------
  test "loan calculator computes monthly payment from amount, rate, and term" do
    visit finance_loan_path

    fill_in "loan-loan-amount", with: "25000"
    fill_in "loan-annual-interest-rate", with: "7.5"
    fill_in "loan-loan-term", with: "5"

    assert_selector "[data-loan-calculator-target='monthlyPayment']", text: /[1-9]/, wait: 5
    monthly = find("[data-loan-calculator-target='monthlyPayment']").text
    assert_not_equal "$0.00", monthly, "Monthly payment should have been computed"
    assert_match(/\$[\d,]+\.\d{2}/, monthly, "Monthly payment should be formatted as currency")

    num_payments = find("[data-loan-calculator-target='numPayments']").text
    assert_equal "60", num_payments, "5 years * 12 months = 60 payments"

    total_interest = find("[data-loan-calculator-target='totalInterest']").text
    assert_not_equal "$0.00", total_interest
  end

  # ----------------------------------------------------------------
  # 6. Compound Interest Calculator
  # ----------------------------------------------------------------
  test "compound interest calculator computes future value from principal, rate, and years" do
    visit finance_compound_interest_path

    fill_in "compound-interest-initial-principal", with: "10000"
    fill_in "compound-interest-annual-interest-rate", with: "5"
    fill_in "compound-interest-time-period", with: "10"
    # Default frequency is Monthly (12x/year)

    assert_selector "[data-compound-interest-calculator-target='futureValue']", text: /[1-9]/, wait: 5
    future_value = find("[data-compound-interest-calculator-target='futureValue']").text
    assert_not_equal "$0.00", future_value, "Future value should have been computed"
    assert_match(/\$[\d,]+\.\d{2}/, future_value, "Future value should be formatted as currency")

    total_interest = find("[data-compound-interest-calculator-target='totalInterest']").text
    assert_not_equal "$0.00", total_interest

    principal_display = find("[data-compound-interest-calculator-target='principalDisplay']").text
    assert_match(/\$10,000/, principal_display, "Principal display should show $10,000")
  end

  # ----------------------------------------------------------------
  # 7. Body Fat Calculator
  # ----------------------------------------------------------------
  test "body fat calculator computes body fat percentage for male measurements" do
    visit health_body_fat_path

    # Default sex is Male, default unit system is Metric (cm)
    fill_in "body-fat-waist", with: "85"
    fill_in "body-fat-neck", with: "38"
    fill_in "body-fat-height", with: "175"

    assert_selector "[data-body-fat-calculator-target='bodyFat']", text: /[1-9]/, wait: 5
    body_fat = find("[data-body-fat-calculator-target='bodyFat']").text
    assert_no_match(/\A\u2014\z/, body_fat, "Body fat should not be the default dash")
    assert_match(/\d+(\.\d+)?%?/, body_fat, "Body fat should contain a number")

    category = find("[data-body-fat-calculator-target='category']").text
    assert_no_match(/\A\u2014\z/, category, "Category should be populated")
  end

  # ----------------------------------------------------------------
  # 8. Fraction Calculator
  # ----------------------------------------------------------------
  test "fraction calculator computes sum of two fractions" do
    visit math_fraction_path

    # Default operation is Add (+)
    fill_in "fraction-numerator-1", with: "1"
    fill_in "fraction-denominator-1", with: "2"
    fill_in "fraction-numerator-2", with: "1"
    fill_in "fraction-denominator-2", with: "3"

    assert_selector "[data-fraction-calculator-target='resultFraction']", text: /[1-9]/, wait: 5
    fraction_result = find("[data-fraction-calculator-target='resultFraction']").text
    assert_not_equal "--", fraction_result, "Fraction result should have been computed"
    # 1/2 + 1/3 = 5/6
    assert_match(%r{5/6}, fraction_result, "1/2 + 1/3 should equal 5/6")

    decimal_result = find("[data-fraction-calculator-target='resultDecimal']").text
    assert_not_equal "--", decimal_result, "Decimal result should have been computed"
    assert_match(/0\.833/, decimal_result, "5/6 as decimal should be approximately 0.833")
  end

  # ----------------------------------------------------------------
  # 9. Age Calculator
  # ----------------------------------------------------------------
  test "age calculator computes age from birth date" do
    visit everyday_age_path

    # Set the date input value via JavaScript to avoid browser date-picker formatting issues
    execute_script("document.getElementById('age-birth-date').value = '1990-01-15'")
    execute_script("document.getElementById('age-birth-date').dispatchEvent(new Event('input', { bubbles: true }))")

    assert_selector "[data-age-calculator-target='resultYears']", text: /[1-9]/, wait: 5
    years = find("[data-age-calculator-target='resultYears']").text
    assert_no_match(/\A\u2014\z/, years, "Years should not be the default dash")
    # Born 1990-01-15 means the person is 36 years old (in 2026)
    assert_match(/3[456]/, years, "Person born 1990-01-15 should be in their mid-30s")

    total_days = find("[data-age-calculator-target='resultTotalDays']").text
    assert_no_match(/\A\u2014\z/, total_days, "Total days should not be the default dash")
    assert_match(/[\d,]{5,}/, total_days, "Total days should be a large number (thousands)")

    next_birthday = find("[data-age-calculator-target='resultNextBirthday']").text
    assert_no_match(/\A\u2014\z/, next_birthday, "Next birthday should not be the default dash")
  end

  # ----------------------------------------------------------------
  # 10. Calorie Calculator
  # ----------------------------------------------------------------
  test "calorie calculator computes BMR and TDEE from personal stats" do
    visit health_calorie_path

    # Default unit system is Metric, default sex is Male, default activity is Sedentary
    fill_in "calorie-age", with: "30"
    fill_in "calorie-weight", with: "75"
    fill_in "calorie-height", with: "180"

    assert_selector "[data-calorie-calculator-target='bmr']", text: /[1-9]/, wait: 5
    bmr = find("[data-calorie-calculator-target='bmr']").text
    assert_no_match(/\A\u2014 cal\z/, bmr, "BMR should not be the default dash")
    assert_match(/\d+/, bmr, "BMR should contain a numeric value")

    tdee = find("[data-calorie-calculator-target='tdee']").text
    assert_no_match(/\A\u2014 cal\z/, tdee, "TDEE should not be the default dash")
    assert_match(/\d+/, tdee, "TDEE should contain a numeric value")

    # Weight loss target should also be populated
    weight_loss = find("[data-calorie-calculator-target='weightLoss']").text
    assert_no_match(/\A\u2014 cal\z/, weight_loss, "Weight loss calories should be computed")
  end
end
