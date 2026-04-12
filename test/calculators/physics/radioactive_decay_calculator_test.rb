require "test_helper"

class Physics::RadioactiveDecayCalculatorTest < ActiveSupport::TestCase
  test "find_remaining: after one half-life, 50% remains" do
    result = Physics::RadioactiveDecayCalculator.new(
      mode: "find_remaining", initial_amount: 1000, half_life: 10, time: 10
    ).call
    assert result[:valid]
    assert_in_delta 500.0, result[:remaining_amount], 0.01
  end

  test "find_remaining: after two half-lives, 25% remains" do
    result = Physics::RadioactiveDecayCalculator.new(
      mode: "find_remaining", initial_amount: 1000, half_life: 10, time: 20
    ).call
    assert result[:valid]
    assert_in_delta 250.0, result[:remaining_amount], 0.01
  end

  test "find_remaining: time = 0 means nothing has decayed" do
    result = Physics::RadioactiveDecayCalculator.new(
      mode: "find_remaining", initial_amount: 1000, half_life: 10, time: 0
    ).call
    assert result[:valid]
    assert_in_delta 1000.0, result[:remaining_amount], 0.01
  end

  test "find_remaining: percent remaining" do
    result = Physics::RadioactiveDecayCalculator.new(
      mode: "find_remaining", initial_amount: 1000, half_life: 10, time: 10
    ).call
    assert result[:valid]
    assert_in_delta 50.0, result[:percent_remaining], 0.01
  end

  test "find_remaining: decay constant = ln(2)/t_half" do
    result = Physics::RadioactiveDecayCalculator.new(
      mode: "find_remaining", initial_amount: 1000, half_life: 10, time: 10
    ).call
    assert result[:valid]
    expected_lambda = Math.log(2) / 10.0
    assert_in_delta expected_lambda, result[:decay_constant], 0.0001
  end

  test "find_time: known remaining amount" do
    result = Physics::RadioactiveDecayCalculator.new(
      mode: "find_time", initial_amount: 1000, remaining_amount: 250, half_life: 10
    ).call
    assert result[:valid]
    # 250 = 1000 * (0.5)^(t/10) => t = 20
    assert_in_delta 20.0, result[:time], 0.01
  end

  test "find_half_life: from initial, remaining, and time" do
    result = Physics::RadioactiveDecayCalculator.new(
      mode: "find_half_life", initial_amount: 1000, remaining_amount: 500, time: 10
    ).call
    assert result[:valid]
    assert_in_delta 10.0, result[:half_life], 0.01
  end

  test "carbon-14 dating: 5730 year half-life" do
    result = Physics::RadioactiveDecayCalculator.new(
      mode: "find_remaining", initial_amount: 100, half_life: 5730, time: 11460
    ).call
    assert result[:valid]
    # After 2 half-lives: 25%
    assert_in_delta 25.0, result[:remaining_amount], 0.01
  end

  test "amount decayed is correct" do
    result = Physics::RadioactiveDecayCalculator.new(
      mode: "find_remaining", initial_amount: 1000, half_life: 10, time: 10
    ).call
    assert result[:valid]
    assert_in_delta 500.0, result[:amount_decayed], 0.01
  end

  test "zero initial amount returns error" do
    result = Physics::RadioactiveDecayCalculator.new(
      mode: "find_remaining", initial_amount: 0, half_life: 10, time: 10
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Initial amount must be a positive number"
  end

  test "remaining >= initial returns error for find_time" do
    result = Physics::RadioactiveDecayCalculator.new(
      mode: "find_time", initial_amount: 100, remaining_amount: 150, half_life: 10
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Remaining amount must be less than initial amount"
  end

  test "invalid mode returns error" do
    result = Physics::RadioactiveDecayCalculator.new(mode: "invalid").call
    refute result[:valid]
  end

  test "string coercion" do
    result = Physics::RadioactiveDecayCalculator.new(
      mode: "find_remaining", initial_amount: "1000", half_life: "10", time: "10"
    ).call
    assert result[:valid]
    assert_in_delta 500.0, result[:remaining_amount], 0.01
  end
end
