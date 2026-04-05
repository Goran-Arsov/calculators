import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drinks", "weight", "gender", "hours", "unitSystem",
                     "bac", "status", "hoursUntilSober", "impairment",
                     "weightLabel"]

  static widmarkFactor = { male: 0.68, female: 0.55 }
  static alcoholGramsPerDrink = 14.0
  static metabolismRate = 0.015

  connect() {
    this.updateLabels()
  }

  updateLabels() {
    const unit = this.unitSystemTarget.value
    this.weightLabelTarget.textContent = unit === "imperial" ? "Weight (lbs)" : "Weight (kg)"
    this.calculate()
  }

  calculate() {
    const drinks = parseFloat(this.drinksTarget.value) || 0
    const weight = parseFloat(this.weightTarget.value) || 0
    const gender = this.genderTarget.value
    const hours = parseFloat(this.hoursTarget.value) || 0
    const unit = this.unitSystemTarget.value

    if (drinks <= 0 || weight <= 0) {
      this.clearResults()
      return
    }

    const weightGrams = unit === "imperial" ? weight * 453.592 : weight * 1000
    const widmark = this.constructor.widmarkFactor[gender] || 0.68
    const alcoholGrams = drinks * this.constructor.alcoholGramsPerDrink

    const rawBac = (alcoholGrams / (weightGrams * widmark)) * 100
    const bac = Math.max(rawBac - (this.constructor.metabolismRate * hours), 0)

    let status, impairment
    if (bac < 0.02) {
      status = "Sober"
      impairment = "No significant impairment. You may feel normal."
    } else if (bac < 0.05) {
      status = "Minimal impairment"
      impairment = "Slight relaxation and mild mood elevation. Judgment slightly affected."
    } else if (bac < 0.08) {
      status = "Some impairment"
      impairment = "Reduced coordination and impaired judgment. Do not drive."
    } else if (bac < 0.15) {
      status = "Legally impaired"
      impairment = "Above legal limit in most jurisdictions. Significant impairment of motor control."
    } else if (bac < 0.30) {
      status = "Severely impaired"
      impairment = "Major loss of balance and motor control. Vomiting likely. Blackout risk."
    } else {
      status = "Life-threatening"
      impairment = "Danger of loss of consciousness, coma, or death. Seek emergency help."
    }

    const hoursUntilSober = bac > 0 ? (bac / this.constructor.metabolismRate) : 0

    this.bacTarget.textContent = bac.toFixed(4) + "%"
    this.statusTarget.textContent = status
    this.hoursUntilSoberTarget.textContent = hoursUntilSober.toFixed(1) + " hours"
    this.impairmentTarget.textContent = impairment
  }

  clearResults() {
    this.bacTarget.textContent = "—"
    this.statusTarget.textContent = "—"
    this.hoursUntilSoberTarget.textContent = "—"
    this.impairmentTarget.textContent = "—"
  }

  copy() {
    const text = [
      `BAC: ${this.bacTarget.textContent}`,
      `Status: ${this.statusTarget.textContent}`,
      `Time Until Sober: ${this.hoursUntilSoberTarget.textContent}`,
      `Impairment: ${this.impairmentTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
