require "test_helper"

class Everyday::UptimeCalculatorTest < ActiveSupport::TestCase
  test "calculates 100% uptime with zero downtime" do
    result = Everyday::UptimeCalculator.new(
      total_period_hours: 720,
      downtime_minutes: 0
    ).call

    assert result[:valid]
    assert_equal 100.0, result[:uptime_percent]
    assert_equal "Five 9s (99.999%)", result[:nines_classification]
  end

  test "calculates uptime percentage correctly" do
    # 720 hours = 43200 minutes. 432 minutes down = 99%
    result = Everyday::UptimeCalculator.new(
      total_period_hours: 720,
      downtime_minutes: 432
    ).call

    assert result[:valid]
    assert_equal 99.0, result[:uptime_percent]
    assert_equal "Two 9s (99%)", result[:nines_classification]
  end

  test "classifies five nines" do
    # 43200 * 0.00001 = 0.432 minutes down
    result = Everyday::UptimeCalculator.new(
      total_period_hours: 720,
      downtime_minutes: 0.432
    ).call

    assert result[:valid]
    assert result[:uptime_percent] >= 99.999
    assert_equal "Five 9s (99.999%)", result[:nines_classification]
  end

  test "classifies four nines" do
    # 43200 * 0.0001 = 4.32 minutes down
    result = Everyday::UptimeCalculator.new(
      total_period_hours: 720,
      downtime_minutes: 4.32
    ).call

    assert result[:valid]
    assert result[:uptime_percent] >= 99.99
    assert result[:uptime_percent] < 99.999
    assert_equal "Four 9s (99.99%)", result[:nines_classification]
  end

  test "classifies three nines" do
    # 43200 * 0.001 = 43.2 minutes down
    result = Everyday::UptimeCalculator.new(
      total_period_hours: 720,
      downtime_minutes: 43.2
    ).call

    assert result[:valid]
    assert result[:uptime_percent] >= 99.9
    assert result[:uptime_percent] < 99.99
    assert_equal "Three 9s (99.9%)", result[:nines_classification]
  end

  test "classifies less than two nines" do
    # 50% uptime
    result = Everyday::UptimeCalculator.new(
      total_period_hours: 720,
      downtime_minutes: 21600
    ).call

    assert result[:valid]
    assert_equal 50.0, result[:uptime_percent]
    assert_equal "Less than two 9s", result[:nines_classification]
  end

  test "uses default total_period_hours of 720" do
    result = Everyday::UptimeCalculator.new(
      downtime_minutes: 0
    ).call

    assert result[:valid]
    assert_equal 720.0, result[:total_period_hours]
  end

  test "returns SLA reference table" do
    result = Everyday::UptimeCalculator.new(
      total_period_hours: 720,
      downtime_minutes: 0
    ).call

    assert result[:valid]
    sla = result[:sla_reference]
    assert_equal 5, sla.length

    labels = sla.map { |s| s[:label] }
    assert_includes labels, "99%"
    assert_includes labels, "99.9%"
    assert_includes labels, "99.99%"
    assert_includes labels, "99.999%"
  end

  test "SLA reference has correct downtime for 99%" do
    result = Everyday::UptimeCalculator.new(
      total_period_hours: 720,
      downtime_minutes: 0
    ).call

    sla_99 = result[:sla_reference].find { |s| s[:label] == "99%" }
    # 1% of 43200 = 432 minutes per month
    assert_in_delta 432.0, sla_99[:downtime_per_month_minutes], 0.01
  end

  test "SLA reference has correct downtime for 99.999%" do
    result = Everyday::UptimeCalculator.new(
      total_period_hours: 720,
      downtime_minutes: 0
    ).call

    sla_five = result[:sla_reference].find { |s| s[:label] == "99.999%" }
    # 0.001% of 43200 = 0.432 minutes per month
    assert_in_delta 0.432, sla_five[:downtime_per_month_minutes], 0.001
  end

  test "returns error for zero total hours" do
    result = Everyday::UptimeCalculator.new(
      total_period_hours: 0,
      downtime_minutes: 10
    ).call

    assert_not result[:valid]
    assert_includes result[:errors], "Total period hours must be greater than zero"
  end

  test "returns error for negative downtime" do
    result = Everyday::UptimeCalculator.new(
      total_period_hours: 720,
      downtime_minutes: -5
    ).call

    assert_not result[:valid]
    assert_includes result[:errors], "Downtime minutes cannot be negative"
  end

  test "returns error when downtime exceeds total period" do
    result = Everyday::UptimeCalculator.new(
      total_period_hours: 1,
      downtime_minutes: 120
    ).call

    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Downtime cannot exceed total period") }
  end

  test "handles custom total period" do
    # 168 hours = 1 week = 10080 minutes
    result = Everyday::UptimeCalculator.new(
      total_period_hours: 168,
      downtime_minutes: 100.8
    ).call

    assert result[:valid]
    assert_equal 99.0, result[:uptime_percent]
  end

  test "returns uptime minutes" do
    result = Everyday::UptimeCalculator.new(
      total_period_hours: 720,
      downtime_minutes: 60
    ).call

    assert result[:valid]
    assert_equal 43140.0, result[:uptime_minutes] # 43200 - 60
  end
end
