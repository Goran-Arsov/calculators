require "test_helper"

class Relationships::BreakupRecoveryCalculatorTest < ActiveSupport::TestCase
  test "default recovery is positive" do
    result = Relationships::BreakupRecoveryCalculator.new(
      months_together: 18, intensity: "serious", who_initiated: "mutual"
    ).call
    assert result[:valid]
    assert result[:recovery_weeks] > 0
  end

  test "longer relationship takes longer to recover" do
    short = Relationships::BreakupRecoveryCalculator.new(
      months_together: 6, intensity: "serious", who_initiated: "mutual"
    ).call
    long = Relationships::BreakupRecoveryCalculator.new(
      months_together: 60, intensity: "serious", who_initiated: "mutual"
    ).call
    assert long[:recovery_weeks] > short[:recovery_weeks]
  end

  test "married is highest intensity multiplier" do
    serious = Relationships::BreakupRecoveryCalculator.new(
      months_together: 24, intensity: "serious", who_initiated: "mutual"
    ).call
    married = Relationships::BreakupRecoveryCalculator.new(
      months_together: 24, intensity: "married", who_initiated: "mutual"
    ).call
    assert married[:recovery_weeks] > serious[:recovery_weeks]
  end

  test "five stages returned" do
    result = Relationships::BreakupRecoveryCalculator.new(
      months_together: 12, intensity: "serious", who_initiated: "mutual"
    ).call
    assert_equal 5, result[:stages].length
  end
end
