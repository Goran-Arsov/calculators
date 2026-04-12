import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weight", "ageCategory", "activityLevel", "environment", "kcalPerCan",
                     "dailyCalories", "cansPerDay", "ozPerDay", "rer"]

  static ageMultipliers = { kitten: 2.5, adult: 1.2, senior: 1.0 }
  static activityMultipliers = { inactive: 0.8, moderate: 1.0, active: 1.2, very_active: 1.4 }
  static environmentAdjustments = { indoor: 0.0, outdoor: 0.1, both: 0.05 }

  calculate() {
    const weightLbs = parseFloat(this.weightTarget.value) || 0
    const ageCategory = this.ageCategoryTarget.value
    const activityLevel = this.activityLevelTarget.value
    const environment = this.environmentTarget.value
    const kcalPerCan = parseFloat(this.kcalPerCanTarget.value) || 250

    if (weightLbs <= 0 || kcalPerCan <= 0) {
      this.clearResults()
      return
    }

    const weightKg = weightLbs * 0.453592
    const rer = 70 * Math.pow(weightKg, 0.75)

    const ageFactor = this.constructor.ageMultipliers[ageCategory] || 1.2
    const activityFactor = this.constructor.activityMultipliers[activityLevel] || 1.0
    const envBonus = this.constructor.environmentAdjustments[environment] || 0.0

    const dailyCalories = rer * ageFactor * (activityFactor + envBonus)
    const cansPerDay = dailyCalories / kcalPerCan
    const ozPerDay = cansPerDay * 5.5

    this.rerTarget.textContent = `${Math.round(rer)} kcal`
    this.dailyCaloriesTarget.textContent = `${Math.round(dailyCalories)} kcal`
    this.cansPerDayTarget.textContent = `${cansPerDay.toFixed(2)} cans`
    this.ozPerDayTarget.textContent = `${ozPerDay.toFixed(1)} oz`
  }

  clearResults() {
    this.rerTarget.textContent = "\u2014"
    this.dailyCaloriesTarget.textContent = "\u2014"
    this.cansPerDayTarget.textContent = "\u2014"
    this.ozPerDayTarget.textContent = "\u2014"
  }

  copy() {
    const text = [
      `Daily Calories: ${this.dailyCaloriesTarget.textContent}`,
      `Cans Per Day: ${this.cansPerDayTarget.textContent}`,
      `Ounces Per Day: ${this.ozPerDayTarget.textContent}`,
      `RER: ${this.rerTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
