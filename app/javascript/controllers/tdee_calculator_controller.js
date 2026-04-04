import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weight", "height", "age", "gender", "activity", "resultBmr", "resultTdee"]

  static activityMultipliers = {
    sedentary: 1.2,
    light: 1.375,
    moderate: 1.55,
    active: 1.725,
    very_active: 1.9
  }

  calculate() {
    const weight = parseFloat(this.weightTarget.value) || 0
    const height = parseFloat(this.heightTarget.value) || 0
    const age = parseFloat(this.ageTarget.value) || 0
    const gender = this.genderTarget.value
    const activity = this.activityTarget.value

    if (weight <= 0 || height <= 0 || age <= 0) {
      this.clearResults()
      return
    }

    let bmr
    if (gender === "male") {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161
    }

    const multiplier = this.constructor.activityMultipliers[activity] || 1.2
    const tdee = bmr * multiplier

    this.resultBmrTarget.textContent = this.fmt(bmr)
    this.resultTdeeTarget.textContent = this.fmt(tdee)
  }

  clearResults() {
    this.resultBmrTarget.textContent = "0"
    this.resultTdeeTarget.textContent = "0"
  }

  fmt(n) {
    return Math.round(n).toLocaleString()
  }
}
