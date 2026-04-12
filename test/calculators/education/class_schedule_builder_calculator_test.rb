require "test_helper"

class Education::ClassScheduleBuilderCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "builds schedule with no conflicts" do
    classes = [
      { name: "Calculus", day: "monday", start_time: "09:00", end_time: "10:00", credits: 3, location: "Room 101" },
      { name: "English", day: "monday", start_time: "11:00", end_time: "12:00", credits: 3, location: "Room 202" }
    ]
    calc = Education::ClassScheduleBuilderCalculator.new(classes: classes)
    result = calc.call

    assert result[:valid]
    assert_equal 2, result[:total_classes]
    assert_equal 6, result[:total_credits]
    assert_in_delta 2.0, result[:total_hours_per_week], 0.01
    refute result[:has_conflicts]
    assert_equal 1, result[:gaps].size
  end

  # --- Conflict detection ---

  test "detects overlapping classes" do
    classes = [
      { name: "Calculus", day: "monday", start_time: "09:00", end_time: "10:30", credits: 3 },
      { name: "English", day: "monday", start_time: "10:00", end_time: "11:00", credits: 3 }
    ]
    calc = Education::ClassScheduleBuilderCalculator.new(classes: classes)
    result = calc.call

    assert result[:valid]
    assert result[:has_conflicts]
    assert_equal 1, result[:conflicts].size
    assert_equal 30, result[:conflicts].first[:overlap_minutes]
  end

  test "no conflict across different days" do
    classes = [
      { name: "Calculus", day: "monday", start_time: "09:00", end_time: "10:30", credits: 3 },
      { name: "English", day: "tuesday", start_time: "09:00", end_time: "10:30", credits: 3 }
    ]
    calc = Education::ClassScheduleBuilderCalculator.new(classes: classes)
    result = calc.call

    assert result[:valid]
    refute result[:has_conflicts]
  end

  # --- Gap detection ---

  test "detects gaps between classes" do
    classes = [
      { name: "Calculus", day: "wednesday", start_time: "08:00", end_time: "09:00", credits: 3 },
      { name: "English", day: "wednesday", start_time: "11:00", end_time: "12:00", credits: 3 }
    ]
    calc = Education::ClassScheduleBuilderCalculator.new(classes: classes)
    result = calc.call

    assert result[:valid]
    assert_equal 1, result[:gaps].size
    assert_equal 120, result[:gaps].first[:gap_minutes]
  end

  test "back-to-back classes have no gaps" do
    classes = [
      { name: "Calculus", day: "monday", start_time: "09:00", end_time: "10:00", credits: 3 },
      { name: "English", day: "monday", start_time: "10:00", end_time: "11:00", credits: 3 }
    ]
    calc = Education::ClassScheduleBuilderCalculator.new(classes: classes)
    result = calc.call

    assert result[:valid]
    assert_equal 0, result[:gaps].size
  end

  # --- Daily summaries ---

  test "builds daily summaries" do
    classes = [
      { name: "Calculus", day: "monday", start_time: "09:00", end_time: "10:00", credits: 3 },
      { name: "Physics", day: "monday", start_time: "11:00", end_time: "12:30", credits: 4 },
      { name: "English", day: "wednesday", start_time: "14:00", end_time: "15:00", credits: 3 }
    ]
    calc = Education::ClassScheduleBuilderCalculator.new(classes: classes)
    result = calc.call

    assert result[:valid]
    assert result[:daily_summaries].key?("Monday")
    assert result[:daily_summaries].key?("Wednesday")
    assert_equal 2, result[:daily_summaries]["Monday"][:class_count]
    assert_equal 1, result[:daily_summaries]["Wednesday"][:class_count]
  end

  # --- Earliest/latest times ---

  test "tracks earliest start and latest end" do
    classes = [
      { name: "Early Class", day: "monday", start_time: "07:30", end_time: "08:30", credits: 3 },
      { name: "Late Class", day: "friday", start_time: "16:00", end_time: "17:30", credits: 3 }
    ]
    calc = Education::ClassScheduleBuilderCalculator.new(classes: classes)
    result = calc.call

    assert result[:valid]
    assert_equal "07:30", result[:earliest_start]
    assert_equal "17:30", result[:latest_end]
  end

  # --- Validation ---

  test "empty classes returns error" do
    calc = Education::ClassScheduleBuilderCalculator.new(classes: [])
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "At least one class is required"
  end

  test "missing class name returns error" do
    classes = [ { name: "", day: "monday", start_time: "09:00", end_time: "10:00", credits: 3 } ]
    calc = Education::ClassScheduleBuilderCalculator.new(classes: classes)
    result = calc.call

    refute result[:valid]
    assert calc.errors.any? { |e| e.include?("name is required") }
  end

  test "invalid day returns error" do
    classes = [ { name: "Test", day: "funday", start_time: "09:00", end_time: "10:00", credits: 3 } ]
    calc = Education::ClassScheduleBuilderCalculator.new(classes: classes)
    result = calc.call

    refute result[:valid]
    assert calc.errors.any? { |e| e.include?("invalid day") }
  end

  test "end time before start time returns error" do
    classes = [ { name: "Test", day: "monday", start_time: "10:00", end_time: "09:00", credits: 3 } ]
    calc = Education::ClassScheduleBuilderCalculator.new(classes: classes)
    result = calc.call

    refute result[:valid]
    assert calc.errors.any? { |e| e.include?("end time must be after start time") }
  end

  test "zero credits returns error" do
    classes = [ { name: "Test", day: "monday", start_time: "09:00", end_time: "10:00", credits: 0 } ]
    calc = Education::ClassScheduleBuilderCalculator.new(classes: classes)
    result = calc.call

    refute result[:valid]
    assert calc.errors.any? { |e| e.include?("credits must be positive") }
  end
end
