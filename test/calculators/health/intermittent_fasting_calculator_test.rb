require "test_helper"

class Health::IntermittentFastingCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: 16:8 starting at 20:00 ---

  test "happy path 16:8 at 20:00" do
    result = Health::IntermittentFastingCalculator.new(method: "16_8", start_time: "20:00").call
    assert result[:valid]
    assert_equal "16:8 (Leangains)", result[:method_name]
    assert_equal 16, result[:fasting_hours]
    assert_equal 8, result[:eating_hours]
    assert_equal "8:00 PM", result[:fasting_start]
    assert_equal "12:00 PM", result[:fasting_end]
    assert_equal "12:00 PM", result[:eating_start]
    assert_equal "8:00 PM", result[:eating_end]
  end

  # --- 18:6 method ---

  test "18:6 starting at 21:00" do
    result = Health::IntermittentFastingCalculator.new(method: "18_6", start_time: "21:00").call
    assert result[:valid]
    assert_equal "18:6", result[:method_name]
    assert_equal 18, result[:fasting_hours]
    assert_equal 6, result[:eating_hours]
    assert_equal "9:00 PM", result[:fasting_start]
    assert_equal "3:00 PM", result[:fasting_end]
    assert_equal "3:00 PM", result[:eating_start]
    assert_equal "9:00 PM", result[:eating_end]
  end

  # --- 20:4 method ---

  test "20:4 warrior diet" do
    result = Health::IntermittentFastingCalculator.new(method: "20_4", start_time: "19:00").call
    assert result[:valid]
    assert_equal "20:4 (Warrior Diet)", result[:method_name]
    assert_equal 20, result[:fasting_hours]
    assert_equal 4, result[:eating_hours]
    assert_equal "7:00 PM", result[:fasting_start]
    assert_equal "3:00 PM", result[:fasting_end]
  end

  # --- 14:10 beginner method ---

  test "14:10 beginner method" do
    result = Health::IntermittentFastingCalculator.new(method: "14_10", start_time: "20:00").call
    assert result[:valid]
    assert_equal "14:10", result[:method_name]
    assert_equal 14, result[:fasting_hours]
    assert_equal 10, result[:eating_hours]
    assert_equal "10:00 AM", result[:eating_start]
  end

  # --- OMAD ---

  test "omad one meal a day" do
    result = Health::IntermittentFastingCalculator.new(method: "omad", start_time: "19:00").call
    assert result[:valid]
    assert_equal "OMAD (One Meal a Day)", result[:method_name]
    assert_equal 23, result[:fasting_hours]
    assert_equal 1, result[:eating_hours]
    assert_equal "6:00 PM", result[:eating_start]
  end

  # --- Schedule generation ---

  test "schedule is generated with multiple events" do
    result = Health::IntermittentFastingCalculator.new(method: "16_8", start_time: "20:00").call
    assert result[:valid]
    assert result[:schedule].length >= 4
    # First event should be "Begin fasting"
    assert_equal "Begin fasting", result[:schedule].first[:event]
    # Last event should be "Eating window closes"
    assert_equal "Eating window closes", result[:schedule].last[:event]
  end

  # --- Midnight wrapping ---

  test "times wrap around midnight correctly" do
    result = Health::IntermittentFastingCalculator.new(method: "16_8", start_time: "20:00").call
    assert result[:valid]
    # Fasting start: 8 PM, Fasting end: 12 PM next day
    assert_equal "8:00 PM", result[:fasting_start]
    assert_equal "12:00 PM", result[:fasting_end]
  end

  # --- Non-even minutes ---

  test "start time with non-zero minutes" do
    result = Health::IntermittentFastingCalculator.new(method: "16_8", start_time: "20:30").call
    assert result[:valid]
    assert_equal "8:30 PM", result[:fasting_start]
    assert_equal "12:30 PM", result[:fasting_end]
    assert_equal "8:30 PM", result[:eating_end]
  end

  # --- Validation ---

  test "invalid method returns error" do
    result = Health::IntermittentFastingCalculator.new(method: "12_12", start_time: "20:00").call
    refute result[:valid]
    assert_includes result[:errors], "Fasting method is required"
  end

  test "nil start time returns error" do
    result = Health::IntermittentFastingCalculator.new(method: "16_8", start_time: nil).call
    refute result[:valid]
    assert_includes result[:errors], "Start time is required and must be in HH:MM format"
  end

  test "empty start time returns error" do
    result = Health::IntermittentFastingCalculator.new(method: "16_8", start_time: "").call
    refute result[:valid]
    assert_includes result[:errors], "Start time is required and must be in HH:MM format"
  end

  test "invalid start time format returns error" do
    result = Health::IntermittentFastingCalculator.new(method: "16_8", start_time: "25:00").call
    refute result[:valid]
    assert_includes result[:errors], "Start time is required and must be in HH:MM format"
  end

  test "both invalid method and start time returns multiple errors" do
    result = Health::IntermittentFastingCalculator.new(method: "invalid", start_time: "").call
    refute result[:valid]
    assert result[:errors].length >= 2
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::IntermittentFastingCalculator.new(method: "16_8", start_time: "20:00")
    assert_equal [], calc.errors
  end
end
