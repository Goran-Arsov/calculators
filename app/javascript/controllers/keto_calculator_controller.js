import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weight", "height", "age", "gender", "activityLevel", "goal", "unitSystem",
                     "dailyCalories", "fatGrams", "proteinGrams", "carbGrams",
                     "fatPercent", "proteinPercent", "carbPercent",
                     "weightLabel", "heightLabel"]

  static multipliers = { sedentary: 1.2, light: 1.375, moderate: 1.55, active: 1.725, very_active: 1.9 }
  static goals = { maintain: 0, lose: -500, gain: 500 }

  connect() {
    this.updateLabels()
  }

  updateLabels() {
    const unit = this.unitSystemTarget.value
    this.weightLabelTarget.textContent = unit === "imperial" ? "Weight (lbs)" : "Weight (kg)"
    this.heightLabelTarget.textContent = unit === "imperial" ? "Height (inches)" : "Height (cm)"
    this.calculate()
  }

  calculate() {
    const weight = parseFloat(this.weightTarget.value) || 0
    const height = parseFloat(this.heightTarget.value) || 0
    const age = parseInt(this.ageTarget.value) || 0
    const gender = this.genderTarget.value
    const activity = this.activityLevelTarget.value
    const goal = this.goalTarget.value
    const unit = this.unitSystemTarget.value

    if (weight <= 0 || height <= 0 || age <= 0) {
      this.clearResults()
      return
    }

    const weightKg = unit === "imperial" ? weight * 0.453592 : weight
    const heightCm = unit === "imperial" ? height * 2.54 : height

    // Mifflin-St Jeor
    let bmr
    if (gender === "male") {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5
    } else {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161
    }

    const multiplier = this.constructor.multipliers[activity] || 1.2
    const tdee = bmr * multiplier
    const adjustment = this.constructor.goals[goal] || 0
    const dailyCals = tdee + adjustment

    // Keto ratios: 70% fat, 25% protein, 5% carbs
    let fatCals = dailyCals * 0.70
    let proteinCals = dailyCals * 0.25
    let carbCals = dailyCals * 0.05

    let carbGrams = carbCals / 4
    // Cap net carbs at 25g
    if (carbGrams > 25) {
      const excessCals = (carbGrams - 25) * 4
      carbGrams = 25
      carbCals = 100
      fatCals += excessCals
    }

    const fatGrams = fatCals / 9
    const proteinGrams = proteinCals / 4

    const fatPct = Math.round(fatCals / dailyCals * 100)
    const proteinPct = Math.round(proteinCals / dailyCals * 100)
    const carbPct = Math.round(carbCals / dailyCals * 100)

    this.dailyCaloriesTarget.textContent = Math.round(dailyCals).toLocaleString() + " cal"
    this.fatGramsTarget.textContent = Math.round(fatGrams) + "g"
    this.proteinGramsTarget.textContent = Math.round(proteinGrams) + "g"
    this.carbGramsTarget.textContent = Math.round(carbGrams) + "g"
    this.fatPercentTarget.textContent = fatPct + "%"
    this.proteinPercentTarget.textContent = proteinPct + "%"
    this.carbPercentTarget.textContent = carbPct + "%"
  }

  clearResults() {
    const targets = ["dailyCalories", "fatGrams", "proteinGrams", "carbGrams", "fatPercent", "proteinPercent", "carbPercent"]
    targets.forEach(t => this[`${t}Target`].textContent = "—")
  }

  copy() {
    const text = [
      `Daily Calories: ${this.dailyCaloriesTarget.textContent}`,
      `Fat: ${this.fatGramsTarget.textContent} (${this.fatPercentTarget.textContent})`,
      `Protein: ${this.proteinGramsTarget.textContent} (${this.proteinPercentTarget.textContent})`,
      `Net Carbs: ${this.carbGramsTarget.textContent} (${this.carbPercentTarget.textContent})`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
