require "test_helper"

class Photography::PhotoStorageCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "1000 JPEG photos at 24MP" do
    result = Photography::PhotoStorageCalculator.new(
      num_photos: 1000, megapixels: 24, format: "jpeg"
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 7.2, result[:per_photo_mb], 0.1  # 24 * 0.3
    assert_in_delta 7200, result[:total_mb], 10
  end

  test "1000 RAW photos at 24MP" do
    result = Photography::PhotoStorageCalculator.new(
      num_photos: 1000, megapixels: 24, format: "raw"
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 28.8, result[:per_photo_mb], 0.1  # 24 * 1.2
  end

  test "RAW+JPEG uses both formats" do
    result = Photography::PhotoStorageCalculator.new(
      num_photos: 100, megapixels: 24, format: "raw_jpeg"
    ).call
    assert_equal true, result[:valid]
    # 24 * 1.2 + 24 * 0.3 = 28.8 + 7.2 = 36.0
    assert_in_delta 36.0, result[:per_photo_mb], 0.1
  end

  test "GB and TB are consistent" do
    result = Photography::PhotoStorageCalculator.new(
      num_photos: 10000, megapixels: 24, format: "raw"
    ).call
    assert_equal true, result[:valid]
    assert_in_delta result[:total_gb] / 1024.0, result[:total_tb], 0.001
  end

  test "card counts are calculated correctly" do
    result = Photography::PhotoStorageCalculator.new(
      num_photos: 1000, megapixels: 24, format: "raw"
    ).call
    assert_equal true, result[:valid]
    # 28.8 GB total -> needs 1x32GB card
    assert result[:cards_32gb] > 0
    assert result[:cards_64gb] > 0
    assert result[:cards_128gb] > 0
    assert result[:cards_32gb] >= result[:cards_64gb]
    assert result[:cards_64gb] >= result[:cards_128gb]
  end

  test "format display name is correct" do
    result = Photography::PhotoStorageCalculator.new(
      num_photos: 100, megapixels: 24, format: "heif"
    ).call
    assert_equal true, result[:valid]
    assert_equal "HEIF/HEIC", result[:format_display]
  end

  test "HEIF uses less storage than JPEG" do
    jpeg = Photography::PhotoStorageCalculator.new(
      num_photos: 1000, megapixels: 24, format: "jpeg"
    ).call
    heif = Photography::PhotoStorageCalculator.new(
      num_photos: 1000, megapixels: 24, format: "heif"
    ).call
    assert heif[:total_mb] < jpeg[:total_mb]
  end

  # --- Validation errors ---

  test "error when num_photos is zero" do
    result = Photography::PhotoStorageCalculator.new(
      num_photos: 0, megapixels: 24, format: "jpeg"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Number of photos must be positive"
  end

  test "error when megapixels is zero" do
    result = Photography::PhotoStorageCalculator.new(
      num_photos: 1000, megapixels: 0, format: "jpeg"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Megapixels must be positive"
  end

  test "error when megapixels exceeds 200" do
    result = Photography::PhotoStorageCalculator.new(
      num_photos: 1000, megapixels: 250, format: "jpeg"
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("200") }
  end

  test "error for unknown format" do
    result = Photography::PhotoStorageCalculator.new(
      num_photos: 1000, megapixels: 24, format: "bmp"
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown format") }
  end

  test "errors accessor returns empty array before call" do
    calc = Photography::PhotoStorageCalculator.new(
      num_photos: 1000, megapixels: 24, format: "jpeg"
    )
    assert_equal [], calc.errors
  end
end
