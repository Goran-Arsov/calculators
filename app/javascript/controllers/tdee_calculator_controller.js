import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weight", "height", "age", "gender", "activityLevel", "bmr", "tdee"]

  static activityMultipliers = {
    sedentary: 1.2,
    light: 1.375,
    moderate: 1.55,
    active: 1.725,
    extra: 1.9
  }

  calculate() {
    const weight = parseFloat(this.weightTarget.value) || 0
    const height = parseFloat(this.heightTarget.value) || 0
    const age = parseFloat(this.ageTarget.value) || 0
    const gender = this.genderTarget.value
    const activity = this.activityLevelTarget.value

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

    this.bmrTarget.textContent = `${this.fmt(bmr)} cal`
    this.tdeeTarget.textContent = `${this.fmt(tdee)} cal`
  }

  clearResults() {
    this.bmrTarget.textContent = "— cal"
    this.tdeeTarget.textContent = "— cal"
  }

  fmt(n) {
    return Math.round(n).toLocaleString()
  }

  copy() {
    const text = `BMR: ${this.bmrTarget.textContent}\nTDEE: ${this.tdeeTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
