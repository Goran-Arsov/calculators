require "test_helper"

class Everyday::CronBuilderCalculatorTest < ActiveSupport::TestCase
  test "builds every-minute expression with defaults" do
    result = Everyday::CronBuilderCalculator.new.call
    assert_equal true, result[:valid]
    assert_equal "* * * * *", result[:expression]
    assert_kind_of String, result[:description]
  end

  test "builds specific minute and hour" do
    result = Everyday::CronBuilderCalculator.new(minute: "30", hour: "9").call
    assert_equal true, result[:valid]
    assert_equal "30 9 * * *", result[:expression]
    assert_includes result[:description], "30"
    assert_includes result[:description], "9"
  end

  test "builds step values" do
    result = Everyday::CronBuilderCalculator.new(minute: "*/5", hour: "*/2").call
    assert_equal true, result[:valid]
    assert_equal "*/5 */2 * * *", result[:expression]
  end

  test "builds with day of month" do
    result = Everyday::CronBuilderCalculator.new(minute: "0", hour: "0", day_of_month: "1").call
    assert_equal true, result[:valid]
    assert_equal "0 0 1 * *", result[:expression]
  end

  test "builds with specific months" do
    result = Everyday::CronBuilderCalculator.new(minute: "0", hour: "0", day_of_month: "1", month: "1,4,7,10").call
    assert_equal true, result[:valid]
    assert_equal "0 0 1 1,4,7,10 *", result[:expression]
  end

  test "builds with day of week" do
    result = Everyday::CronBuilderCalculator.new(minute: "0", hour: "8", day_of_week: "1,2,3,4,5").call
    assert_equal true, result[:valid]
    assert_equal "0 8 * * 1,2,3,4,5", result[:expression]
  end

  test "returns field breakdown" do
    result = Everyday::CronBuilderCalculator.new(minute: "30", hour: "9", day_of_week: "1").call
    assert_equal "30", result[:fields][:minute]
    assert_equal "9", result[:fields][:hour]
    assert_equal "*", result[:fields][:day_of_month]
    assert_equal "*", result[:fields][:month]
    assert_equal "1", result[:fields][:day_of_week]
  end

  test "description mentions day names" do
    result = Everyday::CronBuilderCalculator.new(day_of_week: "1").call
    assert_equal true, result[:valid]
    assert_includes result[:description], "Monday"
  end

  test "description mentions month names" do
    result = Everyday::CronBuilderCalculator.new(month: "6").call
    assert_equal true, result[:valid]
    assert_includes result[:description], "June"
  end

  # --- Validation errors ---

  test "error for invalid minute value" do
    result = Everyday::CronBuilderCalculator.new(minute: "60").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "error for invalid hour value" do
    result = Everyday::CronBuilderCalculator.new(hour: "25").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "error for invalid day of month" do
    result = Everyday::CronBuilderCalculator.new(day_of_month: "32").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "error for invalid month" do
    result = Everyday::CronBuilderCalculator.new(month: "13").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "error for invalid day of week" do
    result = Everyday::CronBuilderCalculator.new(day_of_week: "7").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "error for garbage input" do
    result = Everyday::CronBuilderCalculator.new(minute: "abc").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "accepts range values" do
    result = Everyday::CronBuilderCalculator.new(hour: "9-17").call
    assert_equal true, result[:valid]
    assert_equal "* 9-17 * * *", result[:expression]
  end

  test "accepts comma-separated list" do
    result = Everyday::CronBuilderCalculator.new(minute: "0,15,30,45").call
    assert_equal true, result[:valid]
    assert_equal "0,15,30,45 * * * *", result[:expression]
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::CronBuilderCalculator.new
    assert_equal [], calc.errors
  end
end
