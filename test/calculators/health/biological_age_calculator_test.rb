require "test_helper"

class Health::BiologicalAgeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: optimal lifestyle ---

  test "optimal lifestyle produces younger biological age" do
    # exercise >5: -3, sleep 7-9: -1, diet 5: -3, stress 1: -2, no smoke: 0, bmi 22: -1
    # total = -10
    result = Health::BiologicalAgeCalculator.new(
      chronological_age: 40, exercise_hours_per_week: 6,
      sleep_hours_per_night: 8, diet_quality: 5,
      stress_level: 1, is_smoker: false, bmi: 22
    ).call
    assert result[:valid]
    assert_equal 30, result[:biological_age]
    assert_equal(-10, result[:age_difference])
  end

  # --- Happy path: poor lifestyle ---

  test "poor lifestyle produces older biological age" do
    # exercise <1: +1, sleep <6: +2, diet 1: +3, stress 5: +4, smoker: +5, bmi 32: +3
    # total = +18
    result = Health::BiologicalAgeCalculator.new(
      chronological_age: 40, exercise_hours_per_week: 0.5,
      sleep_hours_per_night: 4, diet_quality: 1,
      stress_level: 5, is_smoker: true, bmi: 32
    ).call
    assert result[:valid]
    assert_equal 58, result[:biological_age]
    assert_equal 18, result[:age_difference]
  end

  # --- Factor breakdown tests ---

  test "exercise adjustment: >5 hours" do
    result = build_result(exercise_hours_per_week: 6)
    assert_equal(-3, result[:factor_breakdown][:exercise])
  end

  test "exercise adjustment: 3-5 hours" do
    result = build_result(exercise_hours_per_week: 4)
    assert_equal(-2, result[:factor_breakdown][:exercise])
  end

  test "exercise adjustment: 1-3 hours" do
    result = build_result(exercise_hours_per_week: 2)
    assert_equal(-1, result[:factor_breakdown][:exercise])
  end

  test "exercise adjustment: <1 hour" do
    result = build_result(exercise_hours_per_week: 0.5)
    assert_equal 1, result[:factor_breakdown][:exercise]
  end

  test "sleep adjustment: 7-9 hours" do
    result = build_result(sleep_hours_per_night: 8)
    assert_equal(-1, result[:factor_breakdown][:sleep])
  end

  test "sleep adjustment: 6-7 hours" do
    result = build_result(sleep_hours_per_night: 6.5)
    assert_equal 0, result[:factor_breakdown][:sleep]
  end

  test "sleep adjustment: <6 hours" do
    result = build_result(sleep_hours_per_night: 5)
    assert_equal 2, result[:factor_breakdown][:sleep]
  end

  test "sleep adjustment: >9 hours" do
    result = build_result(sleep_hours_per_night: 10)
    assert_equal 2, result[:factor_breakdown][:sleep]
  end

  test "diet adjustment: quality 5" do
    result = build_result(diet_quality: 5)
    assert_equal(-3, result[:factor_breakdown][:diet])
  end

  test "diet adjustment: quality 4" do
    result = build_result(diet_quality: 4)
    assert_equal(-1, result[:factor_breakdown][:diet])
  end

  test "diet adjustment: quality 3" do
    result = build_result(diet_quality: 3)
    assert_equal 0, result[:factor_breakdown][:diet]
  end

  test "diet adjustment: quality 2" do
    result = build_result(diet_quality: 2)
    assert_equal 1, result[:factor_breakdown][:diet]
  end

  test "diet adjustment: quality 1" do
    result = build_result(diet_quality: 1)
    assert_equal 3, result[:factor_breakdown][:diet]
  end

  test "stress adjustment: level 1" do
    result = build_result(stress_level: 1)
    assert_equal(-2, result[:factor_breakdown][:stress])
  end

  test "stress adjustment: level 2" do
    result = build_result(stress_level: 2)
    assert_equal(-1, result[:factor_breakdown][:stress])
  end

  test "stress adjustment: level 3" do
    result = build_result(stress_level: 3)
    assert_equal 0, result[:factor_breakdown][:stress]
  end

  test "stress adjustment: level 4" do
    result = build_result(stress_level: 4)
    assert_equal 2, result[:factor_breakdown][:stress]
  end

  test "stress adjustment: level 5" do
    result = build_result(stress_level: 5)
    assert_equal 4, result[:factor_breakdown][:stress]
  end

  test "smoking adjustment: smoker" do
    result = build_result(is_smoker: true)
    assert_equal 5, result[:factor_breakdown][:smoking]
  end

  test "smoking adjustment: non-smoker" do
    result = build_result(is_smoker: false)
    assert_equal 0, result[:factor_breakdown][:smoking]
  end

  test "bmi adjustment: normal range 18.5-24.9" do
    result = build_result(bmi: 22)
    assert_equal(-1, result[:factor_breakdown][:bmi])
  end

  test "bmi adjustment: overweight 25-29.9" do
    result = build_result(bmi: 27)
    assert_equal 1, result[:factor_breakdown][:bmi]
  end

  test "bmi adjustment: obese 30+" do
    result = build_result(bmi: 35)
    assert_equal 3, result[:factor_breakdown][:bmi]
  end

  test "bmi adjustment: underweight <18.5" do
    result = build_result(bmi: 17)
    assert_equal 1, result[:factor_breakdown][:bmi]
  end

  # --- Recommendations ---

  test "smoker gets quit smoking recommendation" do
    result = build_result(is_smoker: true)
    assert result[:top_recommendations].any? { |r| r.include?("smoking") }
  end

  test "high stress gets stress recommendation" do
    result = build_result(stress_level: 5)
    assert result[:top_recommendations].any? { |r| r.include?("stress") }
  end

  test "recommendations limited to 3" do
    result = Health::BiologicalAgeCalculator.new(
      chronological_age: 40, exercise_hours_per_week: 0.5,
      sleep_hours_per_night: 4, diet_quality: 1,
      stress_level: 5, is_smoker: true, bmi: 32
    ).call
    assert result[:top_recommendations].length <= 3
  end

  test "optimal lifestyle has no recommendations" do
    result = Health::BiologicalAgeCalculator.new(
      chronological_age: 40, exercise_hours_per_week: 6,
      sleep_hours_per_night: 8, diet_quality: 5,
      stress_level: 1, is_smoker: false, bmi: 22
    ).call
    assert_equal [], result[:top_recommendations]
  end

  # --- Validation ---

  test "age below 1 returns error" do
    result = Health::BiologicalAgeCalculator.new(
      chronological_age: 0, exercise_hours_per_week: 3,
      sleep_hours_per_night: 8, diet_quality: 3,
      stress_level: 3, is_smoker: false, bmi: 22
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Age must be between 1 and 120"
  end

  test "age above 120 returns error" do
    result = Health::BiologicalAgeCalculator.new(
      chronological_age: 121, exercise_hours_per_week: 3,
      sleep_hours_per_night: 8, diet_quality: 3,
      stress_level: 3, is_smoker: false, bmi: 22
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Age must be between 1 and 120"
  end

  test "negative exercise hours returns error" do
    result = Health::BiologicalAgeCalculator.new(
      chronological_age: 40, exercise_hours_per_week: -1,
      sleep_hours_per_night: 8, diet_quality: 3,
      stress_level: 3, is_smoker: false, bmi: 22
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Exercise hours must be zero or positive"
  end

  test "sleep hours over 24 returns error" do
    result = Health::BiologicalAgeCalculator.new(
      chronological_age: 40, exercise_hours_per_week: 3,
      sleep_hours_per_night: 25, diet_quality: 3,
      stress_level: 3, is_smoker: false, bmi: 22
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Sleep hours must be between 0 and 24"
  end

  test "diet quality 0 returns error" do
    result = Health::BiologicalAgeCalculator.new(
      chronological_age: 40, exercise_hours_per_week: 3,
      sleep_hours_per_night: 8, diet_quality: 0,
      stress_level: 3, is_smoker: false, bmi: 22
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Diet quality must be between 1 and 5"
  end

  test "diet quality 6 returns error" do
    result = Health::BiologicalAgeCalculator.new(
      chronological_age: 40, exercise_hours_per_week: 3,
      sleep_hours_per_night: 8, diet_quality: 6,
      stress_level: 3, is_smoker: false, bmi: 22
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Diet quality must be between 1 and 5"
  end

  test "stress level 0 returns error" do
    result = Health::BiologicalAgeCalculator.new(
      chronological_age: 40, exercise_hours_per_week: 3,
      sleep_hours_per_night: 8, diet_quality: 3,
      stress_level: 0, is_smoker: false, bmi: 22
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Stress level must be between 1 and 5"
  end

  test "stress level 6 returns error" do
    result = Health::BiologicalAgeCalculator.new(
      chronological_age: 40, exercise_hours_per_week: 3,
      sleep_hours_per_night: 8, diet_quality: 3,
      stress_level: 6, is_smoker: false, bmi: 22
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Stress level must be between 1 and 5"
  end

  test "zero BMI returns error" do
    result = Health::BiologicalAgeCalculator.new(
      chronological_age: 40, exercise_hours_per_week: 3,
      sleep_hours_per_night: 8, diet_quality: 3,
      stress_level: 3, is_smoker: false, bmi: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "BMI must be positive"
  end

  test "BMI over 100 returns error" do
    result = Health::BiologicalAgeCalculator.new(
      chronological_age: 40, exercise_hours_per_week: 3,
      sleep_hours_per_night: 8, diet_quality: 3,
      stress_level: 3, is_smoker: false, bmi: 101
    ).call
    refute result[:valid]
    assert_includes result[:errors], "BMI cannot exceed 100"
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::BiologicalAgeCalculator.new(
      chronological_age: 40, exercise_hours_per_week: 3,
      sleep_hours_per_night: 8, diet_quality: 3,
      stress_level: 3, is_smoker: false, bmi: 22
    )
    assert_equal [], calc.errors
  end

  private

  def build_result(overrides = {})
    defaults = {
      chronological_age: 40,
      exercise_hours_per_week: 3,
      sleep_hours_per_night: 8,
      diet_quality: 3,
      stress_level: 3,
      is_smoker: false,
      bmi: 22
    }
    Health::BiologicalAgeCalculator.new(**defaults.merge(overrides)).call
  end
end
