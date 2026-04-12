require "test_helper"

class Everyday::SemverBumpCalculatorTest < ActiveSupport::TestCase
  test "patch bump increments patch" do
    result = Everyday::SemverBumpCalculator.new(current_version: "1.2.3", bump_type: "patch").call
    assert_equal true, result[:valid]
    assert_equal "1.2.4", result[:new_version]
  end

  test "minor bump increments minor and resets patch" do
    result = Everyday::SemverBumpCalculator.new(current_version: "1.2.3", bump_type: "minor").call
    assert_equal true, result[:valid]
    assert_equal "1.3.0", result[:new_version]
  end

  test "major bump increments major and resets minor and patch" do
    result = Everyday::SemverBumpCalculator.new(current_version: "1.2.3", bump_type: "major").call
    assert_equal true, result[:valid]
    assert_equal "2.0.0", result[:new_version]
  end

  test "handles v prefix" do
    result = Everyday::SemverBumpCalculator.new(current_version: "v1.2.3", bump_type: "patch").call
    assert_equal true, result[:valid]
    assert_equal "1.2.4", result[:new_version]
  end

  test "appends pre-release identifier" do
    result = Everyday::SemverBumpCalculator.new(current_version: "1.2.3", bump_type: "minor", pre_release: "alpha.1").call
    assert_equal true, result[:valid]
    assert_equal "1.3.0-alpha.1", result[:new_version]
  end

  test "appends build metadata" do
    result = Everyday::SemverBumpCalculator.new(current_version: "1.2.3", bump_type: "patch", build_metadata: "build.123").call
    assert_equal true, result[:valid]
    assert_equal "1.2.4+build.123", result[:new_version]
  end

  test "appends both pre-release and build metadata" do
    result = Everyday::SemverBumpCalculator.new(
      current_version: "1.0.0", bump_type: "major", pre_release: "rc.1", build_metadata: "20240101"
    ).call
    assert_equal true, result[:valid]
    assert_equal "2.0.0-rc.1+20240101", result[:new_version]
  end

  test "strips existing pre-release from current version" do
    result = Everyday::SemverBumpCalculator.new(current_version: "1.2.3-beta", bump_type: "patch").call
    assert_equal true, result[:valid]
    assert_equal "1.2.4", result[:new_version]
  end

  test "handles 0.x versions" do
    result = Everyday::SemverBumpCalculator.new(current_version: "0.1.0", bump_type: "minor").call
    assert_equal true, result[:valid]
    assert_equal "0.2.0", result[:new_version]
  end

  test "error when version is empty" do
    result = Everyday::SemverBumpCalculator.new(current_version: "", bump_type: "patch").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Current version is required"
  end

  test "error when version is invalid format" do
    result = Everyday::SemverBumpCalculator.new(current_version: "not-a-version", bump_type: "patch").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("semver format") }
  end

  test "error when bump type is invalid" do
    result = Everyday::SemverBumpCalculator.new(current_version: "1.0.0", bump_type: "invalid").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid bump type") }
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::SemverBumpCalculator.new(current_version: "1.0.0", bump_type: "patch")
    assert_equal [], calc.errors
  end
end
