require "test_helper"

class Everyday::SubscriptionCostCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "single monthly subscription" do
    result = Everyday::SubscriptionCostCalculator.new(
      subscriptions: [{ name: "Netflix", cost: 15.49, frequency: "monthly" }]
    ).call
    assert_equal true, result[:valid]
    assert_equal 15.49, result[:total_monthly]
    assert_in_delta 185.88, result[:total_annual], 0.01
    assert_equal 1, result[:count]
    assert_equal 15.49, result[:average_per_subscription]
    assert_equal "Netflix", result[:most_expensive][:name]
  end

  test "yearly subscription normalized to monthly" do
    result = Everyday::SubscriptionCostCalculator.new(
      subscriptions: [{ name: "Domain", cost: 120, frequency: "yearly" }]
    ).call
    assert_equal true, result[:valid]
    assert_equal 10.0, result[:total_monthly]
    assert_equal 120.0, result[:total_annual]
  end

  test "weekly subscription normalized to monthly" do
    result = Everyday::SubscriptionCostCalculator.new(
      subscriptions: [{ name: "Meal Kit", cost: 50, frequency: "weekly" }]
    ).call
    assert_equal true, result[:valid]
    # 50 * 4.33 = 216.50
    assert_in_delta 216.5, result[:total_monthly], 0.01
  end

  test "mixed frequencies summed correctly" do
    result = Everyday::SubscriptionCostCalculator.new(
      subscriptions: [
        { name: "Netflix", cost: 15, frequency: "monthly" },
        { name: "Domain", cost: 120, frequency: "yearly" },
        { name: "Paper", cost: 5, frequency: "weekly" }
      ]
    ).call
    assert_equal true, result[:valid]
    # 15 + 10 + 21.65 = 46.65
    assert_in_delta 46.65, result[:total_monthly], 0.01
    assert_equal 3, result[:count]
    assert_in_delta 15.55, result[:average_per_subscription], 0.01
  end

  test "most expensive is identified by monthly cost" do
    result = Everyday::SubscriptionCostCalculator.new(
      subscriptions: [
        { name: "Cheap", cost: 5, frequency: "monthly" },
        { name: "Expensive", cost: 50, frequency: "monthly" }
      ]
    ).call
    assert_equal "Expensive", result[:most_expensive][:name]
  end

  test "handles string inputs" do
    result = Everyday::SubscriptionCostCalculator.new(
      subscriptions: [{ name: "Spotify", cost: "10.99", frequency: "Monthly" }]
    ).call
    assert_equal true, result[:valid]
    assert_equal 10.99, result[:total_monthly]
  end

  # --- Validation errors ---

  test "error when no subscriptions provided" do
    result = Everyday::SubscriptionCostCalculator.new(subscriptions: []).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least one subscription is required"
  end

  test "error when subscription cost is zero" do
    result = Everyday::SubscriptionCostCalculator.new(
      subscriptions: [{ name: "Free", cost: 0, frequency: "monthly" }]
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Subscription 1 cost must be positive"
  end

  test "error when frequency is invalid" do
    result = Everyday::SubscriptionCostCalculator.new(
      subscriptions: [{ name: "Bad", cost: 10, frequency: "daily" }]
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Subscription 1 frequency must be weekly, monthly, or yearly"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::SubscriptionCostCalculator.new(
      subscriptions: [{ name: "Test", cost: 10, frequency: "monthly" }]
    )
    assert_equal [], calc.errors
  end
end
