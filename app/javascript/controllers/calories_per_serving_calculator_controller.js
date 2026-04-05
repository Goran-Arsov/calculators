import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalCalories", "servings", "totalProtein", "totalCarbs", "totalFat",
    "caloriesPerServing", "proteinPerServing", "carbsPerServing", "fatPerServing",
    "proteinCalories", "carbsCalories", "fatCalories"
  ]

  calculate() {
    const totalCalories = parseFloat(this.totalCaloriesTarget.value) || 0
    const servings = parseFloat(this.servingsTarget.value) || 0

    if (totalCalories <= 0 || servings <= 0) {
      this.clearResults()
      return
    }

    const totalProtein = parseFloat(this.totalProteinTarget.value) || 0
    const totalCarbs = parseFloat(this.totalCarbsTarget.value) || 0
    const totalFat = parseFloat(this.totalFatTarget.value) || 0

    const calPerServing = totalCalories / servings
    const protPerServing = totalProtein / servings
    const carbsPerServing = totalCarbs / servings
    const fatPerServing = totalFat / servings

    this.caloriesPerServingTarget.textContent = this.formatNumber(calPerServing, 1)
    this.proteinPerServingTarget.textContent = this.formatNumber(protPerServing, 1) + " g"
    this.carbsPerServingTarget.textContent = this.formatNumber(carbsPerServing, 1) + " g"
    this.fatPerServingTarget.textContent = this.formatNumber(fatPerServing, 1) + " g"

    this.proteinCaloriesTarget.textContent = this.formatNumber(protPerServing * 4, 1) + " kcal"
    this.carbsCaloriesTarget.textContent = this.formatNumber(carbsPerServing * 4, 1) + " kcal"
    this.fatCaloriesTarget.textContent = this.formatNumber(fatPerServing * 9, 1) + " kcal"
  }

  clearResults() {
    this.caloriesPerServingTarget.textContent = "\u2014"
    this.proteinPerServingTarget.textContent = "\u2014"
    this.carbsPerServingTarget.textContent = "\u2014"
    this.fatPerServingTarget.textContent = "\u2014"
    this.proteinCaloriesTarget.textContent = "\u2014"
    this.carbsCaloriesTarget.textContent = "\u2014"
    this.fatCaloriesTarget.textContent = "\u2014"
  }

  copy() {
    const text = [
      `Calories per serving: ${this.caloriesPerServingTarget.textContent}`,
      `Protein per serving: ${this.proteinPerServingTarget.textContent}`,
      `Carbs per serving: ${this.carbsPerServingTarget.textContent}`,
      `Fat per serving: ${this.fatPerServingTarget.textContent}`,
      `Protein calories: ${this.proteinCaloriesTarget.textContent}`,
      `Carbs calories: ${this.carbsCaloriesTarget.textContent}`,
      `Fat calories: ${this.fatCaloriesTarget.textContent}`
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
