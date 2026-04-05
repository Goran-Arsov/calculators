import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "dailyProtein", "mealsPerDay",
    "proteinPerMeal", "recommendedMin", "recommendedMax",
    "distribution", "proteinPerMealOz"
  ]

  calculate() {
    const dailyProtein = parseFloat(this.dailyProteinTarget.value) || 0
    const meals = parseInt(this.mealsPerDayTarget.value) || 0

    if (dailyProtein <= 0 || meals <= 0) {
      this.clearResults()
      return
    }

    const proteinPerMeal = dailyProtein / meals

    const MIN_PER_MEAL = 20
    const MAX_PER_MEAL = 40

    const recMin = Math.min(proteinPerMeal * 0.8, MIN_PER_MEAL)
    const recMax = Math.max(proteinPerMeal * 1.2, MAX_PER_MEAL)

    let distribution
    if (proteinPerMeal >= MIN_PER_MEAL && proteinPerMeal <= MAX_PER_MEAL) {
      distribution = "Optimal"
    } else if (proteinPerMeal < MIN_PER_MEAL) {
      distribution = "Low per meal"
    } else {
      distribution = "High per meal"
    }

    this.proteinPerMealTarget.textContent = this.formatNumber(proteinPerMeal) + " g"
    this.recommendedMinTarget.textContent = this.formatNumber(recMin) + " g"
    this.recommendedMaxTarget.textContent = this.formatNumber(recMax) + " g"
    this.distributionTarget.textContent = distribution
    this.proteinPerMealOzTarget.textContent = this.formatNumber(proteinPerMeal / 28.35) + " oz"
  }

  clearResults() {
    this.proteinPerMealTarget.textContent = "\u2014"
    this.recommendedMinTarget.textContent = "\u2014"
    this.recommendedMaxTarget.textContent = "\u2014"
    this.distributionTarget.textContent = "\u2014"
    this.proteinPerMealOzTarget.textContent = "\u2014"
  }

  copy() {
    const text = [
      `Protein per meal: ${this.proteinPerMealTarget.textContent}`,
      `Recommended min: ${this.recommendedMinTarget.textContent}`,
      `Recommended max: ${this.recommendedMaxTarget.textContent}`,
      `Distribution: ${this.distributionTarget.textContent}`,
      `Protein per meal (oz): ${this.proteinPerMealOzTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  formatNumber(value) {
    return Number(value).toLocaleString("en-US", {
      minimumFractionDigits: 1,
      maximumFractionDigits: 1
    })
  }
}
