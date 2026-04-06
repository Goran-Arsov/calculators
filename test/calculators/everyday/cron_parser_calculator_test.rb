require "test_helper"

class Everyday::CronParserCalculatorTest < ActiveSupport::TestCase
  test "parses every-minute expression" do
    result = Everyday::CronParserCalculator.new(expression: "* * * * *").call
    assert result[:valid]
    assert_equal "Every minute", result[:description]
  end

  test "parses every-5-minutes expression" do
    result = Everyday::CronParserCalculator.new(expression: "*/5 * * * *").call
    assert result[:valid]
    assert_equal "Every 5 minutes", result[:description]
  end

  test "parses specific time daily" do
    result = Everyday::CronParserCalculator.new(expression: "30 14 * * *").call
    assert result[:valid]
    assert_includes result[:description], "2:30 PM"
  end

  test "parses weekly schedule" do
    result = Everyday::CronParserCalculator.new(expression: "0 9 * * 1").call
    assert result[:valid]
    assert_includes result[:description], "Monday"
    assert_includes result[:description], "9:00 AM"
  end

  test "parses monthly schedule" do
    result = Everyday::CronParserCalculator.new(expression: "0 0 1 * *").call
    assert result[:valid]
    assert_includes result[:description], "12:00 AM"
    assert_includes result[:description], "day 1"
  end

  test "parses specific month" do
    result = Everyday::CronParserCalculator.new(expression: "0 0 1 6 *").call
    assert result[:valid]
    assert_includes result[:description], "June"
  end

  test "returns next 5 run times" do
    result = Everyday::CronParserCalculator.new(expression: "* * * * *").call
    assert result[:valid]
    assert_equal 5, result[:next_runs].length
  end

  test "next run times are in chronological order" do
    result = Everyday::CronParserCalculator.new(expression: "0 * * * *").call
    assert result[:valid]
    times = result[:next_runs]
    times.each_cons(2) do |a, b|
      assert a < b, "Run times should be in chronological order"
    end
  end

  test "returns field breakdown" do
    result = Everyday::CronParserCalculator.new(expression: "*/15 9-17 * * 1-5").call
    assert result[:valid]
    assert result[:fields].key?("minute")
    assert result[:fields].key?("hour")
    assert result[:fields].key?("day_of_month")
    assert result[:fields].key?("month")
    assert result[:fields].key?("day_of_week")
  end

  test "parses ranges correctly" do
    result = Everyday::CronParserCalculator.new(expression: "0 9-17 * * *").call
    assert result[:valid]
    assert_equal (9..17).to_a, result[:fields]["hour"][:values]
  end

  test "parses lists correctly" do
    result = Everyday::CronParserCalculator.new(expression: "0 0 * * 1,3,5").call
    assert result[:valid]
    assert_equal [1, 3, 5], result[:fields]["day_of_week"][:values]
  end

  test "parses range with step" do
    result = Everyday::CronParserCalculator.new(expression: "0-30/10 * * * *").call
    assert result[:valid]
    assert_equal [0, 10, 20, 30], result[:fields]["minute"][:values]
  end

  test "returns individual field values" do
    result = Everyday::CronParserCalculator.new(expression: "30 14 1 6 1").call
    assert result[:valid]
    assert_equal "30", result[:minute]
    assert_equal "14", result[:hour]
    assert_equal "1", result[:day_of_month]
    assert_equal "6", result[:month]
    assert_equal "1", result[:day_of_week]
  end

  test "returns error for empty expression" do
    result = Everyday::CronParserCalculator.new(expression: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Expression cannot be empty"
  end

  test "returns error for wrong number of fields" do
    result = Everyday::CronParserCalculator.new(expression: "* * *").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Expected 5 fields") }
  end

  test "returns error for out of range value" do
    result = Everyday::CronParserCalculator.new(expression: "60 * * * *").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("out of bounds") }
  end

  test "returns error for invalid syntax" do
    result = Everyday::CronParserCalculator.new(expression: "abc * * * *").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid syntax") }
  end

  test "returns error for out of range in range expression" do
    result = Everyday::CronParserCalculator.new(expression: "0-70 * * * *").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("out of bounds") }
  end

  test "handles midnight correctly" do
    result = Everyday::CronParserCalculator.new(expression: "0 0 * * *").call
    assert result[:valid]
    assert_includes result[:description], "12:00 AM"
  end

  test "handles noon correctly" do
    result = Everyday::CronParserCalculator.new(expression: "0 12 * * *").call
    assert result[:valid]
    assert_includes result[:description], "12:00 PM"
  end

  test "accepts from_time parameter for next runs" do
    fixed_time = Time.new(2026, 1, 1, 0, 0, 0)
    result = Everyday::CronParserCalculator.new(expression: "0 * * * *", from_time: fixed_time).call
    assert result[:valid]
    assert_equal 5, result[:next_runs].length
    # First run should be at 1:00 AM on Jan 1
    assert_includes result[:next_runs][0], "2026-01-01 01:00"
  end
end
