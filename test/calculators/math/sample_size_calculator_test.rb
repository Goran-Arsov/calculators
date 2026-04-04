require "test_helper"

class Math::SampleSizeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "95% confidence, 5% margin of error, 0.5 proportion" do
    result = Math::SampleSizeCalculator.new(confidence_level: 95, margin_of_error: 5).call
    assert result[:valid]
    # n = (1.96^2 * 0.5 * 0.5) / 0.05^2 = 0.9604 / 0.0025 = 384.16 -> 385
    assert_equal 385, result[:sample_size]
    assert_equal 1.96, result[:z_score]
  end

  test "90% confidence, 5% margin of error" do
    result = Math::SampleSizeCalculator.new(confidence_level: 90, margin_of_error: 5).call
    assert result[:valid]
    # n = (1.645^2 * 0.5 * 0.5) / 0.05^2 = 0.67650625 / 0.0025 = 270.6025 -> 271
    assert_equal 271, result[:sample_size]
    assert_equal 1.645, result[:z_score]
  end

  test "99% confidence, 5% margin of error" do
    result = Math::SampleSizeCalculator.new(confidence_level: 99, margin_of_error: 5).call
    assert result[:valid]
    # n = (2.576^2 * 0.5 * 0.5) / 0.05^2 = 1.658944 / 0.0025 = 663.5776 -> 664
    assert_equal 664, result[:sample_size]
    assert_equal 2.576, result[:z_score]
  end

  test "custom population proportion" do
    result = Math::SampleSizeCalculator.new(confidence_level: 95, margin_of_error: 3, population_proportion: 0.3).call
    assert result[:valid]
    # n = (1.96^2 * 0.3 * 0.7) / 0.03^2 = 0.806736 / 0.0009 = 896.373... -> 897
    assert_equal 897, result[:sample_size]
  end

  test "1% margin of error produces larger sample" do
    result = Math::SampleSizeCalculator.new(confidence_level: 95, margin_of_error: 1).call
    assert result[:valid]
    # n = (1.96^2 * 0.25) / 0.01^2 = 0.9604 / 0.0001 = 9604
    assert_equal 9604, result[:sample_size]
  end

  test "returns all input parameters in result" do
    result = Math::SampleSizeCalculator.new(confidence_level: 95, margin_of_error: 5, population_proportion: 0.5).call
    assert result[:valid]
    assert_equal 95, result[:confidence_level]
    assert_equal 5.0, result[:margin_of_error]
    assert_equal 0.5, result[:population_proportion]
  end

  # --- Validation errors ---

  test "error when confidence level is invalid" do
    result = Math::SampleSizeCalculator.new(confidence_level: 80, margin_of_error: 5).call
    refute result[:valid]
    assert_includes result[:errors], "Confidence level must be 90, 95, or 99"
  end

  test "error when margin of error is zero" do
    result = Math::SampleSizeCalculator.new(confidence_level: 95, margin_of_error: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Margin of error must be greater than 0"
  end

  test "error when margin of error is negative" do
    result = Math::SampleSizeCalculator.new(confidence_level: 95, margin_of_error: -5).call
    refute result[:valid]
    assert_includes result[:errors], "Margin of error must be greater than 0"
  end

  test "error when margin of error exceeds 100" do
    result = Math::SampleSizeCalculator.new(confidence_level: 95, margin_of_error: 101).call
    refute result[:valid]
    assert_includes result[:errors], "Margin of error must be less than or equal to 100"
  end

  test "error when population proportion is negative" do
    result = Math::SampleSizeCalculator.new(confidence_level: 95, margin_of_error: 5, population_proportion: -0.1).call
    refute result[:valid]
    assert_includes result[:errors], "Population proportion must be between 0 and 1"
  end

  test "error when population proportion exceeds 1" do
    result = Math::SampleSizeCalculator.new(confidence_level: 95, margin_of_error: 5, population_proportion: 1.5).call
    refute result[:valid]
    assert_includes result[:errors], "Population proportion must be between 0 and 1"
  end

  # --- Edge cases ---

  test "proportion at boundary 0" do
    result = Math::SampleSizeCalculator.new(confidence_level: 95, margin_of_error: 5, population_proportion: 0).call
    assert result[:valid]
    assert_equal 0, result[:sample_size]
  end

  test "proportion at boundary 1" do
    result = Math::SampleSizeCalculator.new(confidence_level: 95, margin_of_error: 5, population_proportion: 1).call
    assert result[:valid]
    assert_equal 0, result[:sample_size]
  end

  test "default population proportion is 0.5" do
    result = Math::SampleSizeCalculator.new(confidence_level: 95, margin_of_error: 5).call
    assert result[:valid]
    assert_equal 0.5, result[:population_proportion]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::SampleSizeCalculator.new(confidence_level: 95, margin_of_error: 5)
    assert_equal [], calc.errors
  end
end
