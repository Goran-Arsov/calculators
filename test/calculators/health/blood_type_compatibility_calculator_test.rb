require "test_helper"

class Health::BloodTypeCompatibilityCalculatorTest < ActiveSupport::TestCase
  # --- O- universal donor ---

  test "O- can donate to all blood types" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "O-").call
    assert result[:valid]
    assert_equal 8, result[:can_donate_to].length
    assert result[:is_universal_donor]
  end

  test "O- can only receive from O-" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "O-").call
    assert_equal %w[O-], result[:can_receive_from]
  end

  # --- AB+ universal recipient ---

  test "AB+ can receive from all blood types" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "AB+").call
    assert result[:valid]
    assert_equal 8, result[:can_receive_from].length
    assert result[:is_universal_recipient]
  end

  test "AB+ can only donate to AB+" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "AB+").call
    assert_equal %w[AB+], result[:can_donate_to]
  end

  # --- Specific type compatibility ---

  test "A+ can donate to A+ and AB+" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "A+").call
    assert_equal %w[A+ AB+], result[:can_donate_to]
  end

  test "A+ can receive from O- O+ A- A+" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "A+").call
    assert_equal %w[O- O+ A- A+], result[:can_receive_from]
  end

  test "B- can donate to B+ B- AB+ AB-" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "B-").call
    assert_equal %w[B+ B- AB+ AB-], result[:can_donate_to]
  end

  # --- Population frequency ---

  test "O+ has 37.4% population frequency" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "O+").call
    assert_equal 37.4, result[:population_frequency]
  end

  test "AB- has 0.6% population frequency" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "AB-").call
    assert_equal 0.6, result[:population_frequency]
  end

  # --- Antigen info ---

  test "A+ has A antigen and Rh" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "A+").call
    assert_includes result[:antigen_info][:antigens_present], "A"
    assert_includes result[:antigen_info][:antigens_present], "Rh"
    assert_equal "Positive", result[:antigen_info][:rh_factor]
  end

  test "O- has no antigens" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "O-").call
    assert_includes result[:antigen_info][:antigens_present], "None"
    assert_equal "Negative", result[:antigen_info][:rh_factor]
  end

  test "AB+ has A, B, and Rh antigens" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "AB+").call
    assert_includes result[:antigen_info][:antigens_present], "A"
    assert_includes result[:antigen_info][:antigens_present], "B"
  end

  # --- Compatibility matrix ---

  test "compatibility matrix has 64 entries" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "A+").call
    assert_equal 64, result[:compatibility_matrix].length
  end

  # --- Special notes ---

  test "O- has universal donor note" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "O-").call
    assert result[:special_notes].any? { |n| n.include?("Universal") }
  end

  test "AB+ has universal recipient note" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "AB+").call
    assert result[:special_notes].any? { |n| n.include?("Universal") }
  end

  # --- Case insensitive input ---

  test "lowercase input is accepted" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "o-").call
    assert result[:valid]
    assert result[:is_universal_donor]
  end

  # --- Validation ---

  test "invalid blood type returns error" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "C+").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Blood type must be one of") }
  end

  test "empty blood type returns error" do
    result = Health::BloodTypeCompatibilityCalculator.new(blood_type: "").call
    refute result[:valid]
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::BloodTypeCompatibilityCalculator.new(blood_type: "A+")
    assert_equal [], calc.errors
  end
end
