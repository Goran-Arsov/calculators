import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weight", "activityLevel", "ageCategory", "kcalPerCup",
                     "dailyCalories", "cupsPerDay", "perMeal", "rer"]

  static multipliers = {
    puppy:  { low: 2.0, normal: 2.5, active: 3.0, very_active: 3.0 },
    adult:  { low: 1.2, normal: 1.4, active: 1.6, very_active: 2.0 },
    senior: { low: 1.0, normal: 1.2, active: 1.4, very_active: 1.6 }
  }

  calculate() {
    const weightLbs = parseFloat(this.weightTarget.value) || 0
    const activityLevel = this.activityLevelTarget.value
    const ageCategory = this.ageCategoryTarget.value
    const kcalPerCup = parseFloat(this.kcalPerCupTarget.value) || 350

    if (weightLbs <= 0 || kcalPerCup <= 0) {
      this.clearResults()
      return
    }

    const weightKg = weightLbs * 0.453592

    // RER = 70 x (weight_kg ^ 0.75)
    const rer = 70 * Math.pow(weightKg, 0.75)

    const multiplier = this.constructor.multipliers[ageCategory]?.[activityLevel] || 1.4
    const dailyCalories = rer * multiplier
    const cupsPerDay = dailyCalories / kcalPerCup
    const perMeal = cupsPerDay / 2

    this.rerTarget.textContent = `${Math.round(rer)} kcal`
    this.dailyCaloriesTarget.textContent = `${Math.round(dailyCalories)} kcal`
    this.cupsPerDayTarget.textContent = this.fmtCups(cupsPerDay)
    this.perMealTarget.textContent = `${this.fmtCups(perMeal)} per meal`
  }

  clearResults() {
    this.rerTarget.textContent = "\u2014"
    this.dailyCaloriesTarget.textContent = "\u2014"
    this.cupsPerDayTarget.textContent = "\u2014"
    this.perMealTarget.textContent = "\u2014"
  }

  fmtCups(n) {
    return `${n.toFixed(2)} cups`
  }

  copy() {
    const text = [
      `Daily Calories: ${this.dailyCaloriesTarget.textContent}`,
      `Cups Per Day: ${this.cupsPerDayTarget.textContent}`,
      `Per Meal (2x/day): ${this.perMealTarget.textContent}`,
      `RER: ${this.rerTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
