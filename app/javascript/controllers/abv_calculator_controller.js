import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "og", "fg",
    "resultAbvAdvanced", "resultAbvSimple", "resultAbw",
    "resultAttenuation", "resultCalories"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const og = parseFloat(this.ogTarget.value) || 0
    const fg = parseFloat(this.fgTarget.value) || 0

    if (og <= 1.0 || fg <= 0.98 || fg > og || og > 1.2) {
      this.clearResults()
      return
    }

    const abvSimple = (og - fg) * 131.25
    const abvAdvanced = (76.08 * (og - fg) / (1.775 - og)) * (fg / 0.794)
    const abw = abvAdvanced * 0.79336
    const attenuation = ((og - fg) / (og - 1.0)) * 100.0

    const realExtract = (0.1808 * ((og - 1) * 1000.0 / 4.0)) + (0.8192 * ((fg - 1) * 1000.0 / 4.0))
    const calories = ((6.9 * abw) + 4.0 * (realExtract - 0.1)) * fg * 3.55

    this.resultAbvAdvancedTarget.textContent = abvAdvanced.toFixed(2) + "%"
    this.resultAbvSimpleTarget.textContent = abvSimple.toFixed(2) + "%"
    this.resultAbwTarget.textContent = abw.toFixed(2) + "%"
    this.resultAttenuationTarget.textContent = attenuation.toFixed(1) + "%"
    this.resultCaloriesTarget.textContent = Math.round(calories)
  }

  clearResults() {
    this.resultAbvAdvancedTarget.textContent = "0%"
    this.resultAbvSimpleTarget.textContent = "0%"
    this.resultAbwTarget.textContent = "0%"
    this.resultAttenuationTarget.textContent = "0%"
    this.resultCaloriesTarget.textContent = "0"
  }

  copy() {
    const text = `ABV Calculation:\nABV (Advanced): ${this.resultAbvAdvancedTarget.textContent}\nABV (Simple): ${this.resultAbvSimpleTarget.textContent}\nABW: ${this.resultAbwTarget.textContent}\nApparent Attenuation: ${this.resultAttenuationTarget.textContent}\nCalories per 12 oz: ${this.resultCaloriesTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
