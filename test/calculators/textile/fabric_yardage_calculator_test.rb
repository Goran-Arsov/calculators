require "test_helper"

class Textile::FabricYardageCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "basic layout: 4 pieces 24x18 on 45in fabric" do
    result = Textile::FabricYardageCalculator.new(
      piece_length_in: 24, piece_width_in: 18, num_pieces: 4, fabric_width_in: 45
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 45/18 = 2 pieces across, ceil(4/2) = 2 rows, 2 * 24 = 48 in
    assert_equal 2, result[:pieces_across]
    assert_equal 2, result[:rows_needed]
    assert_equal 48.0, result[:total_length_in]
  end

  test "single piece fits across wide fabric" do
    result = Textile::FabricYardageCalculator.new(
      piece_length_in: 36, piece_width_in: 20, num_pieces: 1, fabric_width_in: 60
    ).call
    assert_equal true, result[:valid]
    # 60/20 = 3 across, 1 row, 36 in
    assert_equal 3, result[:pieces_across]
    assert_equal 1, result[:rows_needed]
    assert_equal 36.0, result[:total_length_in]
  end

  test "converts inches to yards and meters" do
    result = Textile::FabricYardageCalculator.new(
      piece_length_in: 36, piece_width_in: 45, num_pieces: 1, fabric_width_in: 45
    ).call
    assert_equal true, result[:valid]
    # 1 across, 1 row, 36 in = 1 yard
    assert_equal 1.0, result[:total_yards]
    assert_equal 0.914, result[:total_meters]
  end

  test "rounds up rows needed" do
    result = Textile::FabricYardageCalculator.new(
      piece_length_in: 10, piece_width_in: 15, num_pieces: 5, fabric_width_in: 45
    ).call
    assert_equal true, result[:valid]
    # 45/15 = 3 across, ceil(5/3) = 2 rows, 2*10 = 20 in
    assert_equal 3, result[:pieces_across]
    assert_equal 2, result[:rows_needed]
    assert_equal 20.0, result[:total_length_in]
  end

  test "pattern repeat rounds length up" do
    result = Textile::FabricYardageCalculator.new(
      piece_length_in: 25, piece_width_in: 18, num_pieces: 2, fabric_width_in: 45, repeat_in: 6
    ).call
    assert_equal true, result[:valid]
    # 45/18 = 2 across, ceil(2/2)=1 row, ceil(25/6)=5 so 5*6=30 effective, 1*30=30 in
    assert_equal 30.0, result[:total_length_in]
  end

  test "zero repeat behaves like no repeat" do
    result = Textile::FabricYardageCalculator.new(
      piece_length_in: 24, piece_width_in: 18, num_pieces: 4, fabric_width_in: 45, repeat_in: 0
    ).call
    assert_equal true, result[:valid]
    assert_equal 48.0, result[:total_length_in]
  end

  test "string inputs are coerced" do
    result = Textile::FabricYardageCalculator.new(
      piece_length_in: "24", piece_width_in: "18", num_pieces: "4", fabric_width_in: "45", repeat_in: "0"
    ).call
    assert_equal true, result[:valid]
    assert_equal 2, result[:pieces_across]
  end

  test "narrow fabric with single-fit piece" do
    result = Textile::FabricYardageCalculator.new(
      piece_length_in: 12, piece_width_in: 30, num_pieces: 3, fabric_width_in: 45
    ).call
    # 45/30 = 1 across, 3 rows, 36 in = 1 yard
    assert_equal 1, result[:pieces_across]
    assert_equal 3, result[:rows_needed]
    assert_equal 36.0, result[:total_length_in]
    assert_equal 1.0, result[:total_yards]
  end

  # --- Validation errors ---

  test "error when piece length is zero" do
    result = Textile::FabricYardageCalculator.new(
      piece_length_in: 0, piece_width_in: 18, num_pieces: 4, fabric_width_in: 45
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Piece length must be greater than zero"
  end

  test "error when piece width is zero" do
    result = Textile::FabricYardageCalculator.new(
      piece_length_in: 24, piece_width_in: 0, num_pieces: 4, fabric_width_in: 45
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Piece width must be greater than zero"
  end

  test "error when num_pieces is zero" do
    result = Textile::FabricYardageCalculator.new(
      piece_length_in: 24, piece_width_in: 18, num_pieces: 0, fabric_width_in: 45
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Number of pieces must be at least 1"
  end

  test "error when fabric width is zero" do
    result = Textile::FabricYardageCalculator.new(
      piece_length_in: 24, piece_width_in: 18, num_pieces: 4, fabric_width_in: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Fabric width must be greater than zero"
  end

  test "error when repeat is negative" do
    result = Textile::FabricYardageCalculator.new(
      piece_length_in: 24, piece_width_in: 18, num_pieces: 4, fabric_width_in: 45, repeat_in: -1
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Pattern repeat cannot be negative"
  end

  test "error when piece width exceeds fabric width" do
    result = Textile::FabricYardageCalculator.new(
      piece_length_in: 24, piece_width_in: 50, num_pieces: 4, fabric_width_in: 45
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Piece width exceeds fabric width"
  end

  test "errors accessor returns empty array before call" do
    calc = Textile::FabricYardageCalculator.new(
      piece_length_in: 24, piece_width_in: 18, num_pieces: 4, fabric_width_in: 45
    )
    assert_equal [], calc.errors
  end
end
