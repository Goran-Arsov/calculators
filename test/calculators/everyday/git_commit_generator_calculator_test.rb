require "test_helper"

class Everyday::GitCommitGeneratorCalculatorTest < ActiveSupport::TestCase
  test "generates simple commit message" do
    result = Everyday::GitCommitGeneratorCalculator.new(commit_type: "feat", description: "add user auth").call
    assert_equal true, result[:valid]
    assert_equal "feat: add user auth", result[:message]
  end

  test "generates message with scope" do
    result = Everyday::GitCommitGeneratorCalculator.new(commit_type: "fix", scope: "auth", description: "resolve token expiry").call
    assert_equal true, result[:valid]
    assert_equal "fix(auth): resolve token expiry", result[:message]
  end

  test "generates message with body" do
    result = Everyday::GitCommitGeneratorCalculator.new(commit_type: "feat", description: "add login", body: "Implements JWT authentication").call
    assert_equal true, result[:valid]
    assert_includes result[:message], "\n\nImplements JWT authentication"
    assert_equal true, result[:has_body]
  end

  test "generates breaking change message" do
    result = Everyday::GitCommitGeneratorCalculator.new(
      commit_type: "feat", description: "change API", breaking_change: true, breaking_description: "remove v1 endpoints"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:message], "feat!: change API"
    assert_includes result[:message], "BREAKING CHANGE: remove v1 endpoints"
    assert_equal true, result[:is_breaking]
  end

  test "generates message with issue reference" do
    result = Everyday::GitCommitGeneratorCalculator.new(commit_type: "fix", description: "fix bug", issue_ref: "#123").call
    assert_equal true, result[:valid]
    assert_includes result[:message], "Refs: #123"
    assert_equal true, result[:has_issue_ref]
  end

  test "returns type description" do
    result = Everyday::GitCommitGeneratorCalculator.new(commit_type: "feat", description: "add feature").call
    assert_equal "A new feature", result[:type_description]
  end

  test "error when type is empty" do
    result = Everyday::GitCommitGeneratorCalculator.new(commit_type: "", description: "something").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Commit type is required"
  end

  test "error when type is invalid" do
    result = Everyday::GitCommitGeneratorCalculator.new(commit_type: "invalid", description: "something").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid commit type") }
  end

  test "error when description is empty" do
    result = Everyday::GitCommitGeneratorCalculator.new(commit_type: "feat", description: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Description is required"
  end

  test "error when description ends with period" do
    result = Everyday::GitCommitGeneratorCalculator.new(commit_type: "feat", description: "add feature.").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Description should not end with a period"
  end

  test "error when description starts with uppercase" do
    result = Everyday::GitCommitGeneratorCalculator.new(commit_type: "feat", description: "Add feature").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Description should start with lowercase"
  end

  test "error when breaking change has no description" do
    result = Everyday::GitCommitGeneratorCalculator.new(commit_type: "feat", description: "something", breaking_change: true, breaking_description: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Breaking change description is required when marking as breaking"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::GitCommitGeneratorCalculator.new(commit_type: "feat", description: "test")
    assert_equal [], calc.errors
  end
end
