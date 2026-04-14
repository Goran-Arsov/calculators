import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"
import { LB_TO_KG } from "utils/units"

export default class extends Controller {
  static targets = ["drinks", "weight", "gender", "hours",
                     "unitSystem", "weightLabel",
                     "peakBac", "currentBac", "hoursUntilSober", "bacLevel"]

  static genderFactor = { male: 0.68, female: 0.55 }
  static alcoholGramsPerDrink = 14.0
  static eliminationRate = 0.015

  connect() {
    prefillFromUrl(this, { drinks: "drinks", weight: "weight", gender: "gender", hours: "hours", unit: "unitSystem" })
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toImperial = this.unitSystemTarget.value === "imperial"
    const n = parseFloat(this.weightTarget.value)
    if (Number.isFinite(n)) {
      this.weightTarget.value = (toImperial ? n / LB_TO_KG : n * LB_TO_KG).toFixed(1)
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const imperial = this.unitSystemTarget.value === "imperial"
    this.weightLabelTarget.textContent = imperial ? "Body Weight (lbs)" : "Body Weight (kg)"
  }

  calculate() {
    const drinks = parseFloat(this.drinksTarget.value) || 0
    const weightRaw = parseFloat(this.weightTarget.value) || 0
    const gender = this.genderTarget.value
    const hours = parseFloat(this.hoursTarget.value) || 0

    if (drinks <= 0 || weightRaw <= 0) {
      this.clearResults()
      return
    }

    const weightKg = this.unitSystemTarget.value === "imperial" ? weightRaw * LB_TO_KG : weightRaw
    const factor = this.constructor.genderFactor[gender] || 0.68
    const alcoholGrams = drinks * this.constructor.alcoholGramsPerDrink
    const weightGrams = weightKg * 1000

    const peakBac = (alcoholGrams / (weightGrams * factor)) * 100
    const currentBac = Math.max(peakBac - (this.constructor.eliminationRate * hours), 0)
    const hoursUntilSober = currentBac > 0 ? (currentBac / this.constructor.eliminationRate) : 0

    let level
    if (currentBac < 0.02) level = "Sober"
    else if (currentBac < 0.06) level = "Mild impairment"
    else if (currentBac < 0.15) level = "Moderate impairment"
    else level = "Severe impairment"

    this.peakBacTarget.textContent = peakBac.toFixed(4) + "%"
    this.currentBacTarget.textContent = currentBac.toFixed(4) + "%"
    this.hoursUntilSoberTarget.textContent = hoursUntilSober.toFixed(1) + " hours"
    this.bacLevelTarget.textContent = level
  }

  clearResults() {
    this.peakBacTarget.textContent = "—"
    this.currentBacTarget.textContent = "—"
    this.hoursUntilSoberTarget.textContent = "—"
    this.bacLevelTarget.textContent = "—"
  }

  copy() {
    const text = [
      `Peak BAC: ${this.peakBacTarget.textContent}`,
      `Current BAC: ${this.currentBacTarget.textContent}`,
      `Hours Until Sober: ${this.hoursUntilSoberTarget.textContent}`,
      `Impairment Level: ${this.bacLevelTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
