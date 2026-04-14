require "application_system_test_case"

class UnitToggleTest < ApplicationSystemTestCase
  test "carpet calculator toggles between imperial and metric" do
    visit construction_carpet_path

    # Wait for Stimulus to connect and populate the result area.
    assert_selector "[data-carpet-calculator-target='resultArea']", text: /sq ft/, wait: 5

    # Trigger the unit switch via Stimulus action.
    page.execute_script(<<~JS)
      const sel = document.querySelector("[data-carpet-calculator-target='unitSystem']")
      sel.value = "metric"
      sel.dispatchEvent(new Event("change", { bubbles: true }))
    JS

    # After toggle: label should be "Length (m)" and result should be in m².
    assert_selector "[data-carpet-calculator-target='lengthLabel']", text: "Length (m)", wait: 5
    assert_selector "[data-carpet-calculator-target='resultArea']", text: /m²/, wait: 5
  end

  test "hvac btu calculator toggles to watts" do
    visit construction_hvac_btu_path

    assert_selector "[data-hvac-btu-calculator-target='unitSystem']", wait: 5
    page.execute_script(<<~JS)
      const sel = document.querySelector("[data-hvac-btu-calculator-target='unitSystem']")
      sel.value = "metric"
      sel.dispatchEvent(new Event("change", { bubbles: true }))
    JS
    # A label or result in the form should include "m²" after metric toggle.
    assert_match(/m²/, page.html, "Metric mode should show m² in hvac_btu page")
  end

  test "puppy weight predictor toggles to kg" do
    visit pets_puppy_weight_predictor_path

    assert_selector "[data-puppy-weight-predictor-calculator-target='unitSystem']", wait: 5
    page.execute_script(<<~JS)
      const sel = document.querySelector("[data-puppy-weight-predictor-calculator-target='unitSystem']")
      sel.value = "metric"
      sel.dispatchEvent(new Event("change", { bubbles: true }))
    JS
    assert_match(/\bkg\b/, page.html, "Metric mode should show kg in puppy weight predictor page")
  end
end
