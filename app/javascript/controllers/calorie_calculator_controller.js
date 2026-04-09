import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["age", "sex", "weight", "height", "activityLevel", "unitSystem",
                     "bmr", "tdee", "mildLoss", "weightLoss", "mildGain", "weightGain",
                     "weightLabel", "heightLabel"]

  connect() {
    prefillFromUrl(this, { age: "age", sex: "sex", weight: "weight", height: "height", activity: "activityLevel", unit: "unitSystem" })
    this.updateLabels()
  }

  updateLabels() {
    const unit = this.unitSystemTarget.value
    this.weightLabelTarget.textContent = unit === "imperial" ? "Weight (lbs)" : "Weight (kg)"
    this.heightLabelTarget.textContent = unit === "imperial" ? "Height (inches)" : "Height (cm)"
    this.calculate()
  }

  calculate() {
    const age = parseInt(this.ageTarget.value) || 0
    const sex = this.sexTarget.value
    const weight = parseFloat(this.weightTarget.value) || 0
    const height = parseFloat(this.heightTarget.value) || 0
    const activity = this.activityLevelTarget.value
    const unit = this.unitSystemTarget.value

    if (age <= 0 || weight <= 0 || height <= 0) {
      this.clearResults()
      return
    }

    const weightKg = unit === "imperial" ? weight * 0.453592 : weight
    const heightCm = unit === "imperial" ? height * 2.54 : height

    // Mifflin-St Jeor
    let bmr
    if (sex === "male") {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5
    } else {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161
    }

    const multipliers = { sedentary: 1.2, light: 1.375, moderate: 1.55, active: 1.725, very_active: 1.9 }
    const tdee = bmr * (multipliers[activity] || 1.2)

    this.bmrTarget.textContent = Math.round(bmr).toLocaleString()
    this.tdeeTarget.textContent = Math.round(tdee).toLocaleString()
    this.mildLossTarget.textContent = Math.round(tdee - 250).toLocaleString()
    this.weightLossTarget.textContent = Math.round(tdee - 500).toLocaleString()
    this.mildGainTarget.textContent = Math.round(tdee + 250).toLocaleString()
    this.weightGainTarget.textContent = Math.round(tdee + 500).toLocaleString()
  }

  clearResults() {
    const targets = ["bmr", "tdee", "mildLoss", "weightLoss", "mildGain", "weightGain"]
    targets.forEach(t => this[`${t}Target`].textContent = "0")
  }

  copy() {
    const text = `BMR: ${this.bmrTarget.textContent} cal\nTDEE: ${this.tdeeTarget.textContent} cal\nWeight Loss: ${this.weightLossTarget.textContent} cal\nWeight Gain: ${this.weightGainTarget.textContent} cal`
    navigator.clipboard.writeText(text)
  }
}
