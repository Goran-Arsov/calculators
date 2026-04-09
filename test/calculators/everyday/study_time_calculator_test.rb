require "test_helper"

class Everyday::StudyTimeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "single easy course" do
    courses = [{ name: "Intro to Art", credits: 3, difficulty: 1 }]
    result = Everyday::StudyTimeCalculator.new(courses: courses).call
    assert_equal true, result[:valid]
    # in_class = 3, study = 3 * 1 = 3, total = 6
    assert_equal 6.0, result[:weekly_total_hours]
    assert_equal 1, result[:per_course_breakdown].size
    assert_equal 3.0, result[:per_course_breakdown][0][:in_class_hours]
    assert_equal 3.0, result[:per_course_breakdown][0][:study_hours]
  end

  test "single very hard course" do
    courses = [{ name: "Organic Chemistry", credits: 4, difficulty: 5 }]
    result = Everyday::StudyTimeCalculator.new(courses: courses).call
    assert_equal true, result[:valid]
    # in_class = 4, study = 4 * 3 = 12, total = 16
    assert_equal 16.0, result[:weekly_total_hours]
    assert_equal 12.0, result[:per_course_breakdown][0][:study_hours]
  end

  test "multiple courses sum correctly" do
    courses = [
      { name: "English", credits: 3, difficulty: 2 },
      { name: "Math", credits: 4, difficulty: 3 },
      { name: "History", credits: 3, difficulty: 1 }
    ]
    result = Everyday::StudyTimeCalculator.new(courses: courses).call
    assert_equal true, result[:valid]
    # English: 3 + 3*1.5 = 3 + 4.5 = 7.5
    # Math: 4 + 4*2 = 4 + 8 = 12
    # History: 3 + 3*1 = 3 + 3 = 6
    # Total = 25.5
    assert_equal 25.5, result[:weekly_total_hours]
  end

  test "daily average weekdays divides by 5" do
    courses = [{ name: "Test", credits: 5, difficulty: 3 }]
    result = Everyday::StudyTimeCalculator.new(courses: courses).call
    # total = 5 + 5*2 = 15, daily weekdays = 15/5 = 3.0
    assert_equal 3.0, result[:daily_average_weekdays]
  end

  test "daily average all days divides by 7" do
    courses = [{ name: "Test", credits: 7, difficulty: 1 }]
    result = Everyday::StudyTimeCalculator.new(courses: courses).call
    # total = 7 + 7*1 = 14, daily all = 14/7 = 2.0
    assert_equal 2.0, result[:daily_average_all_days]
  end

  test "per course breakdown contains all fields" do
    courses = [{ name: "Biology", credits: 4, difficulty: 4 }]
    result = Everyday::StudyTimeCalculator.new(courses: courses).call
    breakdown = result[:per_course_breakdown][0]
    assert_equal "Biology", breakdown[:name]
    assert_equal 4, breakdown[:credits]
    assert_equal 4, breakdown[:difficulty]
    assert_equal 4.0, breakdown[:in_class_hours]
    assert_equal 10.0, breakdown[:study_hours]  # 4 * 2.5
    assert_equal 14.0, breakdown[:total_hours]
  end

  test "unnamed course gets default name" do
    courses = [{ name: "", credits: 3, difficulty: 3 }]
    result = Everyday::StudyTimeCalculator.new(courses: courses).call
    assert_equal true, result[:valid]
    assert_equal "Unnamed Course", result[:per_course_breakdown][0][:name]
  end

  test "maximum of 8 courses allowed" do
    courses = 8.times.map { |i| { name: "Course #{i + 1}", credits: 3, difficulty: 3 } }
    result = Everyday::StudyTimeCalculator.new(courses: courses).call
    assert_equal true, result[:valid]
    assert_equal 8, result[:per_course_breakdown].size
  end

  # --- Validation errors ---

  test "error with no courses" do
    result = Everyday::StudyTimeCalculator.new(courses: []).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least one course is required"
  end

  test "error with more than 8 courses" do
    courses = 9.times.map { |i| { name: "Course #{i + 1}", credits: 3, difficulty: 3 } }
    result = Everyday::StudyTimeCalculator.new(courses: courses).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Maximum") }
  end

  test "error when credits is zero" do
    courses = [{ name: "Test", credits: 0, difficulty: 3 }]
    result = Everyday::StudyTimeCalculator.new(courses: courses).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("credits must be greater than zero") }
  end

  test "error when difficulty is out of range" do
    courses = [{ name: "Test", credits: 3, difficulty: 6 }]
    result = Everyday::StudyTimeCalculator.new(courses: courses).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("difficulty must be between 1 and 5") }
  end

  test "error when difficulty is zero" do
    courses = [{ name: "Test", credits: 3, difficulty: 0 }]
    result = Everyday::StudyTimeCalculator.new(courses: courses).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("difficulty must be between 1 and 5") }
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::StudyTimeCalculator.new(courses: [{ name: "Test", credits: 3, difficulty: 3 }])
    assert_equal [], calc.errors
  end
end
