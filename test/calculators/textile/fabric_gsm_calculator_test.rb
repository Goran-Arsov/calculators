require "test_helper"

class Textile::FabricGsmCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "10x10 cm sample weighing 2g = 200 gsm" do
    result = Textile::FabricGsmCalculator.new(
      sample_weight_g: 2, sample_length_cm: 10, sample_width_cm: 10
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 10x10 cm = 0.01 m². 2g / 0.01 = 200 gsm
    assert_equal 200.0, result[:gsm]
    assert_equal 0.01, result[:sample_area_m2]
  end

  test "oz per sq yd conversion" do
    result = Textile::FabricGsmCalculator.new(
      sample_weight_g: 2, sample_length_cm: 10, sample_width_cm: 10
    ).call
    # 200 gsm * 0.0294935 ≈ 5.899
    assert_equal 5.899, result[:oz_per_sqyd]
  end

  test "non-square sample works" do
    result = Textile::FabricGsmCalculator.new(
      sample_weight_g: 3, sample_length_cm: 20, sample_width_cm: 15
    ).call
    # 20x15 = 300 cm² = 0.03 m². 3/0.03 = 100 gsm
    assert_equal 100.0, result[:gsm]
  end

  test "string inputs are coerced" do
    result = Textile::FabricGsmCalculator.new(
      sample_weight_g: "2", sample_length_cm: "10", sample_width_cm: "10"
    ).call
    assert_equal true, result[:valid]
    assert_equal 200.0, result[:gsm]
  end

  # --- Classifications ---

  test "classification lightweight under 100 gsm" do
    result = Textile::FabricGsmCalculator.new(
      sample_weight_g: 0.8, sample_length_cm: 10, sample_width_cm: 10
    ).call
    # 80 gsm
    assert_equal 80.0, result[:gsm]
    assert_equal "Lightweight (chiffon, voile, organza, muslin)", result[:classification]
  end

  test "classification medium-light 100-200 gsm" do
    result = Textile::FabricGsmCalculator.new(
      sample_weight_g: 1.5, sample_length_cm: 10, sample_width_cm: 10
    ).call
    # 150 gsm
    assert_equal "Medium-light (poplin, cotton lawn, shirting)", result[:classification]
  end

  test "classification medium 200-300 gsm" do
    result = Textile::FabricGsmCalculator.new(
      sample_weight_g: 2.5, sample_length_cm: 10, sample_width_cm: 10
    ).call
    # 250 gsm
    assert_equal "Medium (quilting cotton, linen, standard t-shirt jersey)", result[:classification]
  end

  test "classification medium-heavy 300-400 gsm" do
    result = Textile::FabricGsmCalculator.new(
      sample_weight_g: 3.5, sample_length_cm: 10, sample_width_cm: 10
    ).call
    # 350 gsm
    assert_equal "Medium-heavy (twill, canvas, denim)", result[:classification]
  end

  test "classification heavy 400-600 gsm" do
    result = Textile::FabricGsmCalculator.new(
      sample_weight_g: 5, sample_length_cm: 10, sample_width_cm: 10
    ).call
    # 500 gsm
    assert_equal "Heavy (upholstery, duck, heavy denim)", result[:classification]
  end

  test "classification very heavy 600+ gsm" do
    result = Textile::FabricGsmCalculator.new(
      sample_weight_g: 7, sample_length_cm: 10, sample_width_cm: 10
    ).call
    # 700 gsm
    assert_equal "Very heavy (canvas tarp, heavy upholstery)", result[:classification]
  end

  # --- Validations ---

  test "error when sample weight is zero" do
    result = Textile::FabricGsmCalculator.new(
      sample_weight_g: 0, sample_length_cm: 10, sample_width_cm: 10
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Sample weight must be greater than zero"
  end

  test "error when sample length is zero" do
    result = Textile::FabricGsmCalculator.new(
      sample_weight_g: 2, sample_length_cm: 0, sample_width_cm: 10
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Sample length must be greater than zero"
  end

  test "error when sample width is zero" do
    result = Textile::FabricGsmCalculator.new(
      sample_weight_g: 2, sample_length_cm: 10, sample_width_cm: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Sample width must be greater than zero"
  end

  test "error when sample weight is negative" do
    result = Textile::FabricGsmCalculator.new(
      sample_weight_g: -1, sample_length_cm: 10, sample_width_cm: 10
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Sample weight must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Textile::FabricGsmCalculator.new(
      sample_weight_g: 2, sample_length_cm: 10, sample_width_cm: 10
    )
    assert_equal [], calc.errors
  end
end
