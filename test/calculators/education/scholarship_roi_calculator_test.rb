require "test_helper"

class Education::ScholarshipRoiCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates basic scholarship ROI" do
    calc = Education::ScholarshipRoiCalculator.new(
      scholarship_amount: 5_000, hours_spent: 10, num_applications: 5, success_rate: 100.0
    )
    result = calc.call

    assert result[:valid]
    assert_equal 5_000.0, result[:expected_value]
    assert_equal 5_000.0, result[:net_gain]
    assert_in_delta 500.0, result[:hourly_return], 0.01
    assert_equal 2.0, result[:hours_per_application]
    assert result[:worth_it]
  end

  test "success rate reduces expected value" do
    calc = Education::ScholarshipRoiCalculator.new(
      scholarship_amount: 10_000, hours_spent: 20, success_rate: 20.0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 2_000.0, result[:expected_value], 0.01
    assert_in_delta 100.0, result[:hourly_return], 0.01
  end

  test "application costs reduce net gain" do
    calc = Education::ScholarshipRoiCalculator.new(
      scholarship_amount: 1_000, hours_spent: 5, success_rate: 100.0, application_costs: 100
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 900.0, result[:net_gain], 0.01
    assert_in_delta 180.0, result[:hourly_return], 0.01
  end

  # --- Part-time comparison ---

  test "compares to minimum wage correctly" do
    calc = Education::ScholarshipRoiCalculator.new(
      scholarship_amount: 150, hours_spent: 10, success_rate: 100.0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 150.0, result[:part_time_equivalent], 0.01
    assert_in_delta 0.0, result[:scholarship_advantage], 0.01
    assert_equal false, result[:worth_it]
  end

  test "low hourly return is not worth it" do
    calc = Education::ScholarshipRoiCalculator.new(
      scholarship_amount: 100, hours_spent: 10, success_rate: 100.0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 10.0, result[:hourly_return], 0.01
    refute result[:worth_it]
  end

  # --- Validation ---

  test "zero scholarship amount returns error" do
    calc = Education::ScholarshipRoiCalculator.new(
      scholarship_amount: 0, hours_spent: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Scholarship amount must be positive"
  end

  test "zero hours returns error" do
    calc = Education::ScholarshipRoiCalculator.new(
      scholarship_amount: 5_000, hours_spent: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Hours spent must be positive"
  end

  test "success rate over 100 returns error" do
    calc = Education::ScholarshipRoiCalculator.new(
      scholarship_amount: 5_000, hours_spent: 10, success_rate: 150.0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Success rate must be between 0 and 100"
  end

  test "negative application costs returns error" do
    calc = Education::ScholarshipRoiCalculator.new(
      scholarship_amount: 5_000, hours_spent: 10, application_costs: -50
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Application costs cannot be negative"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    calc = Education::ScholarshipRoiCalculator.new(
      scholarship_amount: "5000", hours_spent: "10", success_rate: "50"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 2_500.0, result[:expected_value], 0.01
  end
end
