import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["catAge", "unit", "humanAge", "lifeStage"]

  static FIRST_YEAR = 15
  static SECOND_YEAR_ADDITION = 9
  static SUBSEQUENT_YEAR_ADDITION = 4

  calculate() {
    const rawAge = parseFloat(this.catAgeTarget.value) || 0
    const unit = this.unitTarget.value

    if (rawAge <= 0) {
      this.clearResults()
      return
    }

    const ageInYears = unit === "months" ? rawAge / 12.0 : rawAge

    let humanAge
    if (ageInYears <= 1) {
      humanAge = ageInYears * this.constructor.FIRST_YEAR
    } else if (ageInYears <= 2) {
      humanAge = this.constructor.FIRST_YEAR + (ageInYears - 1) * this.constructor.SECOND_YEAR_ADDITION
    } else {
      humanAge = this.constructor.FIRST_YEAR + this.constructor.SECOND_YEAR_ADDITION + (ageInYears - 2) * this.constructor.SUBSEQUENT_YEAR_ADDITION
    }

    const lifeStage = this.getLifeStage(ageInYears)

    this.humanAgeTarget.textContent = `${humanAge.toFixed(1)} years`
    this.lifeStageTarget.textContent = lifeStage
  }

  getLifeStage(years) {
    if (years < 0.5) return "Kitten"
    if (years < 2) return "Junior"
    if (years < 6) return "Prime"
    if (years < 10) return "Mature"
    if (years < 14) return "Senior"
    return "Geriatric"
  }

  clearResults() {
    this.humanAgeTarget.textContent = "\u2014"
    this.lifeStageTarget.textContent = "\u2014"
  }

  copy() {
    const text = [
      `Human Age: ${this.humanAgeTarget.textContent}`,
      `Life Stage: ${this.lifeStageTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
