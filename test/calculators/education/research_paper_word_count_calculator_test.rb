require "test_helper"

class Education::ResearchPaperWordCountCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: Standard academic formatting ---

  test "standard double-spaced Times New Roman 12pt yields ~250 words per page" do
    calc = Education::ResearchPaperWordCountCalculator.new(
      page_count: 10, font: "times_new_roman", spacing: "double", margins: "1_inch", font_size: 12
    )
    result = calc.call

    assert result[:valid]
    assert_equal 250, result[:words_per_page]
    assert_equal 2_500, result[:estimated_words]
    assert_equal 10.0, result[:content_pages]
  end

  test "single-spaced doubles word count per page" do
    calc = Education::ResearchPaperWordCountCalculator.new(
      page_count: 5, font: "times_new_roman", spacing: "single"
    )
    result = calc.call

    assert result[:valid]
    assert_equal 500, result[:words_per_page]
    assert_equal 2_500, result[:estimated_words]
  end

  # --- Font variations ---

  test "Arial yields fewer words per page than Times New Roman" do
    tnr = Education::ResearchPaperWordCountCalculator.new(
      page_count: 10, font: "times_new_roman", spacing: "double"
    )
    arial = Education::ResearchPaperWordCountCalculator.new(
      page_count: 10, font: "arial", spacing: "double"
    )

    assert arial.call[:words_per_page] < tnr.call[:words_per_page]
  end

  test "Courier yields fewest words per page" do
    courier = Education::ResearchPaperWordCountCalculator.new(
      page_count: 10, font: "courier", spacing: "double"
    )
    result = courier.call

    assert result[:valid]
    assert_equal 210, result[:words_per_page]
  end

  # --- Margin effects ---

  test "wider margins reduce word count" do
    standard = Education::ResearchPaperWordCountCalculator.new(
      page_count: 10, margins: "1_inch"
    )
    wide = Education::ResearchPaperWordCountCalculator.new(
      page_count: 10, margins: "1.5_inch"
    )

    assert wide.call[:estimated_words] < standard.call[:estimated_words]
  end

  test "narrow margins increase word count" do
    standard = Education::ResearchPaperWordCountCalculator.new(
      page_count: 10, margins: "1_inch"
    )
    narrow = Education::ResearchPaperWordCountCalculator.new(
      page_count: 10, margins: "0.75_inch"
    )

    assert narrow.call[:estimated_words] > standard.call[:estimated_words]
  end

  # --- Font size effects ---

  test "smaller font increases word count" do
    size_12 = Education::ResearchPaperWordCountCalculator.new(page_count: 10, font_size: 12)
    size_10 = Education::ResearchPaperWordCountCalculator.new(page_count: 10, font_size: 10)

    assert size_10.call[:estimated_words] > size_12.call[:estimated_words]
  end

  test "larger font decreases word count" do
    size_12 = Education::ResearchPaperWordCountCalculator.new(page_count: 10, font_size: 12)
    size_14 = Education::ResearchPaperWordCountCalculator.new(page_count: 10, font_size: 14)

    assert size_14.call[:estimated_words] < size_12.call[:estimated_words]
  end

  # --- Reference pages ---

  test "excluding reference pages reduces word count" do
    without_refs = Education::ResearchPaperWordCountCalculator.new(page_count: 10)
    with_refs = Education::ResearchPaperWordCountCalculator.new(
      page_count: 10, has_references: true, reference_pages: 2
    )

    assert with_refs.call[:estimated_words] < without_refs.call[:estimated_words]
    assert_equal 8.0, with_refs.call[:content_pages]
  end

  # --- Reading/speaking time ---

  test "calculates reading and speaking times" do
    calc = Education::ResearchPaperWordCountCalculator.new(page_count: 10)
    result = calc.call

    assert result[:valid]
    assert result[:reading_time_minutes] > 0
    assert result[:speaking_time_minutes] > result[:reading_time_minutes]
  end

  # --- Validation ---

  test "zero pages returns error" do
    calc = Education::ResearchPaperWordCountCalculator.new(page_count: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Page count must be positive"
  end

  test "invalid font returns error" do
    calc = Education::ResearchPaperWordCountCalculator.new(page_count: 10, font: "comic_sans")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid font"
  end

  test "invalid spacing returns error" do
    calc = Education::ResearchPaperWordCountCalculator.new(page_count: 10, spacing: "triple")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid spacing"
  end

  test "invalid font size returns error" do
    calc = Education::ResearchPaperWordCountCalculator.new(page_count: 10, font_size: 8)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid font size (must be 10-14)"
  end

  test "reference pages exceeding total returns error" do
    calc = Education::ResearchPaperWordCountCalculator.new(
      page_count: 5, has_references: true, reference_pages: 5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Reference pages cannot exceed total pages"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    calc = Education::ResearchPaperWordCountCalculator.new(page_count: "10", font_size: "12")
    result = calc.call

    assert result[:valid]
    assert_equal 2_500, result[:estimated_words]
  end
end
