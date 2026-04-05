require "test_helper"

class Construction::DeckCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "16x12 deck → boards > 0" do
    result = Construction::DeckCalculator.new(length: 16, width: 12).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:total_boards] > 0
    assert result[:num_joists] > 0
    assert result[:num_posts] > 0
    assert result[:screw_boxes] > 0
  end

  test "deck area calculated correctly" do
    result = Construction::DeckCalculator.new(length: 16, width: 12).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 192.0, result[:deck_area]
  end

  test "boards across calculated from width and board width" do
    # 12 ft width / (5.5/12 ft per board) = 12 / 0.4583... = 26.18 → ceil = 27
    result = Construction::DeckCalculator.new(length: 12, width: 12, board_length: 12, board_width: 5.5).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 27, result[:total_boards] # 27 boards across, 1 run (12 ft boards on 12 ft deck)
  end

  test "joists spaced at 16 inches on center" do
    # 16 ft length / (16/12) ft spacing = 12 → ceil(12) + 1 = 13 joists
    result = Construction::DeckCalculator.new(length: 16, width: 12).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 13, result[:num_joists]
  end

  test "posts calculated for two rows" do
    # 16 ft length / 8 ft spacing = 2 → ceil(2) + 1 = 3 per side × 2 = 6
    result = Construction::DeckCalculator.new(length: 16, width: 12).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 6, result[:num_posts]
  end

  test "cost estimate matches price per board times total boards" do
    result = Construction::DeckCalculator.new(length: 16, width: 12, price_per_board: 10).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal result[:total_boards] * 10.0, result[:board_cost]
  end

  test "string inputs are coerced" do
    result = Construction::DeckCalculator.new(length: "16", width: "12", board_length: "12", board_width: "5.5").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:total_boards] > 0
  end

  test "zero price results in zero cost" do
    result = Construction::DeckCalculator.new(length: 16, width: 12, price_per_board: 0).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 0.0, result[:board_cost]
  end

  # --- Validation errors ---

  test "error when length is zero" do
    result = Construction::DeckCalculator.new(length: 0, width: 12).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Deck length must be greater than zero"
  end

  test "error when width is negative" do
    result = Construction::DeckCalculator.new(length: 16, width: -5).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Deck width must be greater than zero"
  end

  test "error when price is negative" do
    result = Construction::DeckCalculator.new(length: 16, width: 12, price_per_board: -1).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Price per board cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::DeckCalculator.new(length: 16, width: 12)
    assert_equal [], calc.errors
  end
end
