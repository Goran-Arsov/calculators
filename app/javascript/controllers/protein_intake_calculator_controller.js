import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["weightKg", "activityLevel", "goal",
                     "dailyProteinGrams", "proteinPerKg", "perMealGrams",
                     "proteinCalories", "proteinPctOf2000cal"]

  static values = {
    baseRates: { type: Object, default: { sedentary: 0.8, lightly_active: 1.0, moderately_active: 1.2, very_active: 1.6, athlete: 2.0 } },
    goalAdj: { type: Object, default: { maintain: 0.0, muscle_gain: 0.4, fat_loss: 0.2 } }
  }

  connect() {
    prefillFromUrl(this, { weight_kg: "weightKg", activity_level: "activityLevel", goal: "goal" })
    this.calculate()
  }

  calculate() {
    const weightKg = parseFloat(this.weightKgTarget.value) || 0
    const activityLevel = this.activityLevelTarget.value
    const goal = this.goalTarget.value

    if (weightKg <= 0) {
      this.clearResults()
      return
    }

    const baseRate = this.baseRatesValue[activityLevel] || 0.8
    const goalAdj = this.goalAdjValue[goal] || 0.0
    const proteinPerKg = baseRate + goalAdj
    const dailyGrams = weightKg * proteinPerKg
    const perMeal = dailyGrams / 4
    const calories = dailyGrams * 4
    const pctOf2000 = (calories / 2000) * 100

    this.dailyProteinGramsTarget.textContent = dailyGrams.toFixed(1)
    this.proteinPerKgTarget.textContent = proteinPerKg.toFixed(2)
    this.perMealGramsTarget.textContent = perMeal.toFixed(1)
    this.proteinCaloriesTarget.textContent = Math.round(calories)
    this.proteinPctOf2000calTarget.textContent = pctOf2000.toFixed(1)
  }

  clearResults() {
    this.dailyProteinGramsTarget.textContent = "—"
    this.proteinPerKgTarget.textContent = "—"
    this.perMealGramsTarget.textContent = "—"
    this.proteinCaloriesTarget.textContent = "—"
    this.proteinPctOf2000calTarget.textContent = "—"
  }

  copy() {
    const text = `Daily Protein: ${this.dailyProteinGramsTarget.textContent}g\nProtein/kg: ${this.proteinPerKgTarget.textContent} g/kg\nPer Meal: ${this.perMealGramsTarget.textContent}g\nProtein Calories: ${this.proteinCaloriesTarget.textContent} kcal\n% of 2000 cal: ${this.proteinPctOf2000calTarget.textContent}%`
    navigator.clipboard.writeText(text)
  }
}
