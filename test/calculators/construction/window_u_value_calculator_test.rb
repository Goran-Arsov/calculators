require "test_helper"

class Construction::WindowUValueCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "double Low-E argon with vinyl frame produces valid results" do
    result = Construction::WindowUValueCalculator.new(
      glass_type: "double_low_e_argon", frame_type: "vinyl"
    ).call
    assert_equal true, result[:valid]
    assert result[:whole_window_u] > 0
    assert result[:r_value_metric] > 0
    assert result[:r_value_imperial] > 0
  end

  test "single pane has highest U-value" do
    result_single = Construction::WindowUValueCalculator.new(
      glass_type: "single", frame_type: "vinyl"
    ).call
    result_triple = Construction::WindowUValueCalculator.new(
      glass_type: "triple_low_e_argon", frame_type: "vinyl"
    ).call
    assert result_single[:whole_window_u] > result_triple[:whole_window_u]
  end

  test "aluminum frame has higher U-value than wood" do
    result_alu = Construction::WindowUValueCalculator.new(
      glass_type: "double", frame_type: "aluminum"
    ).call
    result_wood = Construction::WindowUValueCalculator.new(
      glass_type: "double", frame_type: "wood"
    ).call
    assert result_alu[:whole_window_u] > result_wood[:whole_window_u]
  end

  test "R-value is inverse of U-value" do
    result = Construction::WindowUValueCalculator.new(
      glass_type: "double_low_e_argon", frame_type: "vinyl"
    ).call
    expected_r = (1.0 / result[:whole_window_u]).round(2)
    assert_equal expected_r, result[:r_value_metric]
  end

  test "imperial U-value is metric divided by 5.678" do
    result = Construction::WindowUValueCalculator.new(
      glass_type: "double_low_e_argon", frame_type: "vinyl"
    ).call
    expected_u_imperial = (result[:whole_window_u] / 5.678).round(3)
    assert_equal expected_u_imperial, result[:u_imperial]
  end

  test "SHGC varies by glass type" do
    result_single = Construction::WindowUValueCalculator.new(
      glass_type: "single", frame_type: "vinyl"
    ).call
    result_low_e = Construction::WindowUValueCalculator.new(
      glass_type: "double_low_e_argon", frame_type: "vinyl"
    ).call
    assert result_single[:shgc] > result_low_e[:shgc]
  end

  test "triple Low-E argon qualifies for Energy Star" do
    result = Construction::WindowUValueCalculator.new(
      glass_type: "triple_low_e_argon", frame_type: "vinyl"
    ).call
    assert_equal true, result[:energy_star_qualified]
  end

  test "single pane does not qualify for Energy Star" do
    result = Construction::WindowUValueCalculator.new(
      glass_type: "single", frame_type: "aluminum"
    ).call
    assert_equal false, result[:energy_star_qualified]
  end

  test "all glass types produce valid results" do
    %w[single double double_argon double_low_e double_low_e_argon triple triple_argon triple_low_e_argon].each do |glass|
      result = Construction::WindowUValueCalculator.new(
        glass_type: glass, frame_type: "vinyl"
      ).call
      assert_equal true, result[:valid], "Glass type #{glass} should produce valid results"
    end
  end

  test "all frame types produce valid results" do
    %w[aluminum aluminum_break vinyl wood fiberglass].each do |frame|
      result = Construction::WindowUValueCalculator.new(
        glass_type: "double", frame_type: frame
      ).call
      assert_equal true, result[:valid], "Frame type #{frame} should produce valid results"
    end
  end

  # --- Validation errors ---

  test "error when glass type is invalid" do
    result = Construction::WindowUValueCalculator.new(
      glass_type: "quadruple", frame_type: "vinyl"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Invalid glass type"
  end

  test "error when frame type is invalid" do
    result = Construction::WindowUValueCalculator.new(
      glass_type: "double", frame_type: "cardboard"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Invalid frame type"
  end

  test "error when frame percentage is too low" do
    result = Construction::WindowUValueCalculator.new(
      glass_type: "double", frame_type: "vinyl", frame_percentage: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Frame percentage must be between 1 and 50"
  end

  test "error when frame percentage is too high" do
    result = Construction::WindowUValueCalculator.new(
      glass_type: "double", frame_type: "vinyl", frame_percentage: 60
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Frame percentage must be between 1 and 50"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::WindowUValueCalculator.new(
      glass_type: "double", frame_type: "vinyl"
    )
    assert_equal [], calc.errors
  end
end
