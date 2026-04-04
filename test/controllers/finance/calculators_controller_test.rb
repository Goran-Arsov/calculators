require "test_helper"

module Finance
  class CalculatorsControllerTest < ActionDispatch::IntegrationTest
    test "should get mortgage" do
      get finance_mortgage_url
      assert_response :success
      assert_select "h1", /Mortgage Calculator/
    end

    test "should get compound interest" do
      get finance_compound_interest_url
      assert_response :success
      assert_select "h1", /Compound Interest/i
    end

    test "should get loan" do
      get finance_loan_url
      assert_response :success
      assert_select "h1", /Loan Calculator/
    end

    test "should get investment" do
      get finance_investment_url
      assert_response :success
      assert_select "h1", /Investment Calculator/
    end

    test "should get retirement" do
      get finance_retirement_url
      assert_response :success
      assert_select "h1", /Retirement Calculator/
    end

    test "should get debt payoff" do
      get finance_debt_payoff_url
      assert_response :success
      assert_select "h1", /Debt Payoff/i
    end

    test "should get salary" do
      get finance_salary_url
      assert_response :success
      assert_select "h1", /Salary Calculator/
    end

    test "should get savings goal" do
      get finance_savings_goal_url
      assert_response :success
      assert_select "h1", /Savings Goal/i
    end

    test "should get roi" do
      get finance_roi_url
      assert_response :success
      assert_select "h1", /ROI Calculator/
    end

    test "should get profit margin" do
      get finance_profit_margin_url
      assert_response :success
      assert_select "h1", /Profit Margin/
    end

    test "should get inflation" do
      get finance_inflation_url
      assert_response :success
      assert_select "h1", /Inflation Calculator/
    end

    test "should get break even" do
      get finance_break_even_url
      assert_response :success
      assert_select "h1", /Break-Even/i
    end

    test "should get markup margin" do
      get finance_markup_margin_url
      assert_response :success
      assert_select "h1", /Markup/
    end

    test "should get rent vs buy" do
      get finance_rent_vs_buy_url
      assert_response :success
      assert_select "h1", /Rent vs/i
    end

    test "should get dividend yield" do
      get finance_dividend_yield_url
      assert_response :success
      assert_select "h1", /Dividend Yield/
    end

    test "should get dca" do
      get finance_dca_url
      assert_response :success
      assert_select "h1", /DCA|Dollar Cost/i
    end

    test "should get solar savings" do
      get finance_solar_savings_url
      assert_response :success
      assert_select "h1", /Solar/
    end

    test "mortgage page has meta description" do
      get finance_mortgage_url
      assert_select "meta[name='description']"
    end

    test "mortgage page has breadcrumb schema" do
      get finance_mortgage_url
      assert_select "script[type='application/ld+json']"
    end

    test "should get tax_bracket" do
      get finance_tax_bracket_url
      assert_response :success
      assert_select "h1", /Tax Bracket/
    end

    test "tax_bracket page has meta description" do
      get finance_tax_bracket_url
      assert_select "meta[name='description']"
    end

    test "tax_bracket page has breadcrumb schema" do
      get finance_tax_bracket_url
      assert_select "script[type='application/ld+json']"
    end

    test "should get auto_loan" do
      get finance_auto_loan_url
      assert_response :success
      assert_select "h1", /Auto Loan/
    end

    test "auto_loan page has meta description" do
      get finance_auto_loan_url
      assert_select "meta[name='description']"
    end

    test "auto_loan page has breadcrumb schema" do
      get finance_auto_loan_url
      assert_select "script[type='application/ld+json']"
    end

    test "should get credit_card_payoff" do
      get finance_credit_card_payoff_url
      assert_response :success
      assert_select "h1", /Credit Card Payoff/
    end

    test "credit_card_payoff page has meta description" do
      get finance_credit_card_payoff_url
      assert_select "meta[name='description']"
    end

    test "credit_card_payoff page has breadcrumb schema" do
      get finance_credit_card_payoff_url
      assert_select "script[type='application/ld+json']"
    end

    test "should get net_worth" do
      get finance_net_worth_url
      assert_response :success
      assert_select "h1", /Net Worth/
    end

    test "net_worth page has meta description" do
      get finance_net_worth_url
      assert_select "meta[name='description']"
    end

    test "net_worth page has breadcrumb schema" do
      get finance_net_worth_url
      assert_select "script[type='application/ld+json']"
    end

    test "should get home_affordability" do
      get finance_home_affordability_url
      assert_response :success
      assert_select "h1", /Home Affordability/
    end

    test "home_affordability page has meta description" do
      get finance_home_affordability_url
      assert_select "meta[name='description']"
    end

    test "home_affordability page has breadcrumb schema" do
      get finance_home_affordability_url
      assert_select "script[type='application/ld+json']"
    end

    test "should get business_loan" do
      get finance_business_loan_url
      assert_response :success
      assert_select "h1", /Business Loan/
    end

    test "business_loan page has meta description" do
      get finance_business_loan_url
      assert_select "meta[name='description']"
    end

    test "business_loan page has breadcrumb schema" do
      get finance_business_loan_url
      assert_select "script[type='application/ld+json']"
    end

    test "should get currency_converter" do
      get finance_currency_converter_url
      assert_response :success
      assert_select "h1", /Currency/
    end

    test "currency_converter page has meta description" do
      get finance_currency_converter_url
      assert_select "meta[name='description']"
    end

    test "currency_converter page has breadcrumb schema" do
      get finance_currency_converter_url
      assert_select "script[type='application/ld+json']"
    end
  end
end
