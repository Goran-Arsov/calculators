require "test_helper"

class Health::Vo2MaxCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: Cooper test ---

  test "cooper test: typical result" do
    # 2400 meters in 12 minutes
    # VO2max = (2400 - 504.9) / 44.73 = 1895.1 / 44.73 = 42.37
    result = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: 2400, age: 30, gender: "male"
    ).call
    assert result[:valid]
    assert_in_delta 42.4, result[:vo2_max], 0.1
  end

  test "cooper test: excellent runner" do
    # 3200 meters
    # VO2max = (3200 - 504.9) / 44.73 = 2695.1 / 44.73 = 60.26
    result = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: 3200, age: 25, gender: "male"
    ).call
    assert result[:valid]
    assert_in_delta 60.3, result[:vo2_max], 0.1
    assert_equal "superior", result[:fitness_level]
  end

  test "cooper test: poor result" do
    # 1600 meters
    # VO2max = (1600 - 504.9) / 44.73 = 1095.1 / 44.73 = 24.48
    result = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: 1600, age: 30, gender: "male"
    ).call
    assert result[:valid]
    assert_in_delta 24.5, result[:vo2_max], 0.1
    assert_equal "poor", result[:fitness_level]
  end

  # --- Happy path: 1.5-mile run ---

  test "1.5 mile run: typical result" do
    # 12 minutes
    # VO2max = 483 / 12 + 3.5 = 40.25 + 3.5 = 43.75
    result = Health::Vo2MaxCalculator.new(
      test_type: "1_5_mile_run", time_minutes: 12, age: 25, gender: "male"
    ).call
    assert result[:valid]
    assert_in_delta 43.8, result[:vo2_max], 0.1
  end

  test "1.5 mile run: fast time" do
    # 8 minutes
    # VO2max = 483 / 8 + 3.5 = 60.375 + 3.5 = 63.875
    result = Health::Vo2MaxCalculator.new(
      test_type: "1_5_mile_run", time_minutes: 8, age: 20, gender: "male"
    ).call
    assert result[:valid]
    assert_in_delta 63.9, result[:vo2_max], 0.1
    assert_equal "superior", result[:fitness_level]
  end

  test "1.5 mile run: slow time" do
    # 20 minutes
    # VO2max = 483 / 20 + 3.5 = 24.15 + 3.5 = 27.65
    result = Health::Vo2MaxCalculator.new(
      test_type: "1_5_mile_run", time_minutes: 20, age: 40, gender: "male"
    ).call
    assert result[:valid]
    assert_in_delta 27.7, result[:vo2_max], 0.1
    assert_equal "poor", result[:fitness_level]
  end

  # --- Gender differences ---

  test "same vo2 max gives different fitness levels for male and female" do
    # Cooper with 2400m for a 30-year-old => VO2max ~42.4
    male = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: 2400, age: 30, gender: "male"
    ).call
    female = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: 2400, age: 30, gender: "female"
    ).call
    assert male[:valid]
    assert female[:valid]
    assert_equal male[:vo2_max], female[:vo2_max]
    # Female should have a better fitness level at the same VO2 max
  end

  # --- Percentile estimate ---

  test "percentile estimate returned for cooper test" do
    result = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: 2400, age: 30, gender: "male"
    ).call
    assert result[:valid]
    assert_includes (1..100), result[:percentile_estimate]
  end

  # --- Age ranges ---

  test "fitness level for teenager" do
    result = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: 2400, age: 16, gender: "male"
    ).call
    assert result[:valid]
    assert result[:fitness_level].is_a?(String)
  end

  test "fitness level for older adult" do
    result = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: 2000, age: 65, gender: "female"
    ).call
    assert result[:valid]
    assert result[:fitness_level].is_a?(String)
  end

  # --- Validation: invalid test type ---

  test "invalid test type returns error" do
    result = Health::Vo2MaxCalculator.new(
      test_type: "invalid", distance_meters: 2400, age: 30, gender: "male"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Invalid test type"
  end

  # --- Validation: gender ---

  test "invalid gender returns error" do
    result = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: 2400, age: 30, gender: "other"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Gender must be male or female"
  end

  # --- Validation: age ---

  test "age below 13 returns error" do
    result = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: 2400, age: 10, gender: "male"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Age must be between 13 and 150"
  end

  test "age at 13 is accepted" do
    result = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: 2400, age: 13, gender: "male"
    ).call
    assert result[:valid]
  end

  # --- Validation: cooper distance ---

  test "cooper: zero distance returns error" do
    result = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: 0, age: 30, gender: "male"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Distance must be positive"
  end

  test "cooper: negative distance returns error" do
    result = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: -100, age: 30, gender: "male"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Distance must be positive"
  end

  test "cooper: distance over 10000 returns error" do
    result = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: 10001, age: 30, gender: "male"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Distance cannot exceed 10000 meters"
  end

  # --- Validation: 1.5 mile time ---

  test "1.5 mile: zero time returns error" do
    result = Health::Vo2MaxCalculator.new(
      test_type: "1_5_mile_run", time_minutes: 0, age: 30, gender: "male"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Time must be positive"
  end

  test "1.5 mile: negative time returns error" do
    result = Health::Vo2MaxCalculator.new(
      test_type: "1_5_mile_run", time_minutes: -5, age: 30, gender: "male"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Time must be positive"
  end

  test "1.5 mile: time over 60 returns error" do
    result = Health::Vo2MaxCalculator.new(
      test_type: "1_5_mile_run", time_minutes: 61, age: 30, gender: "male"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Time cannot exceed 60 minutes"
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::Vo2MaxCalculator.new(
      test_type: "cooper_12min", distance_meters: 2400, age: 30, gender: "male"
    )
    assert_equal [], calc.errors
  end
end
