import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "calories", "weightGrams",
    "caloriesPer100g", "caloriesPerOz", "caloriesPerGram",
    "energyDensity"
  ]

  calculate() {
    const calories = parseFloat(this.caloriesTarget.value) || 0
    const weight = parseFloat(this.weightGramsTarget.value) || 0

    if (calories <= 0 || weight <= 0) {
      this.clearResults()
      return
    }

    const GRAMS_PER_OZ = 28.3495

    const calPer100g = (calories / weight) * 100
    const calPerOz = (calories / weight) * GRAMS_PER_OZ
    const calPerGram = calories / weight

    let density
    if (calPer100g <= 60) {
      density = "Very Low"
    } else if (calPer100g <= 150) {
      density = "Low"
    } else if (calPer100g <= 400) {
      density = "Medium"
    } else {
      density = "High"
    }

    this.caloriesPer100gTarget.textContent = this.formatNumber(calPer100g, 1)
    this.caloriesPerOzTarget.textContent = this.formatNumber(calPerOz, 1)
    this.caloriesPerGramTarget.textContent = this.formatNumber(calPerGram, 2)
    this.energyDensityTarget.textContent = density
  }

  clearResults() {
    this.caloriesPer100gTarget.textContent = "\u2014"
    this.caloriesPerOzTarget.textContent = "\u2014"
    this.caloriesPerGramTarget.textContent = "\u2014"
    this.energyDensityTarget.textContent = "\u2014"
  }

  copy() {
    const text = [
      `Calories per 100g: ${this.caloriesPer100gTarget.textContent}`,
      `Calories per oz: ${this.caloriesPerOzTarget.textContent}`,
      `Calories per gram: ${this.caloriesPerGramTarget.textContent}`,
      `Energy density: ${this.energyDensityTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  formatNumber(value, decimals = 1) {
    return Number(value).toLocaleString("en-US", {
      minimumFractionDigits: decimals,
      maximumFractionDigits: decimals
    })
  }
}
