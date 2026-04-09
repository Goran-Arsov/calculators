require "test_helper"

class UserFormulasControllerTest < ActionDispatch::IntegrationTest
  test "new renders the submission form" do
    get new_user_formula_path
    assert_response :success
    assert_select "h1", /Submit a Custom Calculator/
    assert_select "form"
  end

  test "creates a user formula with valid params" do
    assert_difference "UserFormula.count", 1 do
      post user_formulas_path, params: { user_formula: {
        title: "Simple Interest Calculator",
        description: "Calculates simple interest given principal, rate, and time.",
        category: "finance",
        author_name: "Test User",
        author_email: "test@example.com",
        formula_json: '{"inputs": [{"name": "principal", "type": "number"}], "formula": "principal * rate * time", "outputs": [{"name": "interest"}]}'
      } }
    end
    assert_redirected_to thank_you_user_formulas_path

    formula = UserFormula.last
    assert_equal "pending", formula.status
    assert_equal "simple-interest-calculator", formula.slug
  end

  test "re-renders form with errors on invalid submission" do
    assert_no_difference "UserFormula.count" do
      post user_formulas_path, params: { user_formula: {
        title: "",
        description: "",
        category: "invalid_category",
        author_name: "",
        author_email: "",
        formula_json: ""
      } }
    end
    assert_response :unprocessable_entity
  end

  test "honeypot field rejects spam without creating a record" do
    assert_no_difference "UserFormula.count" do
      post user_formulas_path, params: {
        website: "http://spam.com",
        user_formula: {
          title: "Spam Calculator",
          description: "Spam description",
          category: "finance",
          author_name: "Spammer",
          author_email: "spam@example.com",
          formula_json: '{"inputs": [], "formula": "1+1", "outputs": []}'
        }
      }
    end
    assert_redirected_to new_user_formula_path
  end

  test "thank_you page renders" do
    get thank_you_user_formulas_path
    assert_response :success
    assert_select "h1", /Submission Received/
  end
end
