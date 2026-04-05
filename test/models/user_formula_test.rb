require "test_helper"

class UserFormulaTest < ActiveSupport::TestCase
  def valid_formula
    UserFormula.new(
      title: "Simple Interest",
      description: "Calculate simple interest on a principal amount",
      formula_json: { inputs: [{ name: "principal", type: "number" }], formula: "principal * rate * time" }.to_json,
      category: "finance",
      author_name: "Test User",
      status: "pending"
    )
  end

  test "valid formula saves" do
    f = valid_formula
    assert f.valid?
  end

  test "requires title" do
    f = valid_formula
    f.title = nil
    assert_not f.valid?
  end

  test "requires category from allowed list" do
    f = valid_formula
    f.category = "invalid"
    assert_not f.valid?
  end

  test "auto-generates slug from title" do
    f = valid_formula
    f.save!
    assert_equal "simple-interest", f.slug
  end

  test "approved scope" do
    f = valid_formula
    f.status = "approved"
    f.save!
    assert_includes UserFormula.approved, f
    assert_not_includes UserFormula.pending, f
  end

  test "slug uniqueness" do
    f1 = valid_formula
    f1.save!
    f2 = valid_formula
    f2.slug = f1.slug
    assert_not f2.valid?
  end
end
