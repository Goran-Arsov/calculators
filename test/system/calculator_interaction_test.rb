require "application_system_test_case"

class CalculatorInteractionTest < ApplicationSystemTestCase
  test "homepage loads and displays categories" do
    visit root_path
    assert_selector "h1"
    assert_text "Finance"
    assert_text "Math"
    assert_text "Health"
  end

  test "category page lists calculators" do
    visit category_path("finance")
    assert_selector "h1", text: /Finance/i
    assert_link "Mortgage Calculator"
  end

  test "dark mode toggle works" do
    visit root_path
    find("[aria-label='Toggle dark mode']").click
    assert_selector "html.dark"
  end

  test "navigation links are accessible" do
    visit root_path
    assert_link "Finance"
    assert_link "Math"
    assert_link "Physics"
    assert_link "Health"
    assert_link "Construction"
    assert_link "Everyday"
    assert_link "Blog"
  end
end
