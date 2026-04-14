import { Controller } from "@hotwired/stimulus"
import { LB_TO_KG, OZ_TO_G } from "utils/units"

export default class extends Controller {
  static targets = ["weight", "ageCategory", "activityLevel", "environment", "kcalPerCan",
                     "dailyCalories", "cansPerDay", "ozPerDay", "rer",
                     "unitSystem", "weightLabel", "ozPerDayLabel"]

  static ageMultipliers = { kitten: 2.5, adult: 1.2, senior: 1.0 }
  static activityMultipliers = { inactive: 0.8, moderate: 1.0, active: 1.2, very_active: 1.4 }
  static environmentAdjustments = { indoor: 0.0, outdoor: 0.1, both: 0.05 }

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const n = parseFloat(this.weightTarget.value)
    if (Number.isFinite(n)) {
      this.weightTarget.value = (toMetric ? n * LB_TO_KG : n / LB_TO_KG).toFixed(2)
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.weightLabelTarget.textContent = metric ? "Cat's Weight (kg)" : "Cat's Weight (lbs)"
    this.ozPerDayLabelTarget.textContent = metric ? "Grams Per Day" : "Ounces Per Day"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const weightInput = parseFloat(this.weightTarget.value) || 0
    const ageCategory = this.ageCategoryTarget.value
    const activityLevel = this.activityLevelTarget.value
    const environment = this.environmentTarget.value
    const kcalPerCan = parseFloat(this.kcalPerCanTarget.value) || 250

    if (weightInput <= 0 || kcalPerCan <= 0) {
      this.clearResults()
      return
    }

    const weightKg = metric ? weightInput : weightInput * LB_TO_KG
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
    if (metric) {
      const gPerDay = ozPerDay * OZ_TO_G
      this.ozPerDayTarget.textContent = `${gPerDay.toFixed(0)} g`
    } else {
      this.ozPerDayTarget.textContent = `${ozPerDay.toFixed(1)} oz`
    }
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
      `${this.ozPerDayLabelTarget.textContent}: ${this.ozPerDayTarget.textContent}`,
      `RER: ${this.rerTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
