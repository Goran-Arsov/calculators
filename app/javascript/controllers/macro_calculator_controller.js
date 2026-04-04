import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["calories", "goal", "protein", "carbs", "fat"]

  static ratios = {
    maintain: { protein: 30, carbs: 40, fat: 30 },
    cut:      { protein: 40, carbs: 35, fat: 25 },
    bulk:     { protein: 30, carbs: 45, fat: 25 }
  }

  static calsPerGram = {
    protein: 4,
    carbs: 4,
    fat: 9
  }

  calculate() {
    const calories = parseFloat(this.caloriesTarget.value) || 0
    const goal = this.goalTarget.value

    if (calories <= 0) {
      this.clearResults()
      return
    }

    const ratio = this.constructor.ratios[goal] || this.constructor.ratios.maintain
    const cpg = this.constructor.calsPerGram

    const proteinGrams = (calories * ratio.protein / 100) / cpg.protein
    const carbsGrams = (calories * ratio.carbs / 100) / cpg.carbs
    const fatGrams = (calories * ratio.fat / 100) / cpg.fat

    this.proteinTarget.textContent = `${this.fmt(proteinGrams)} g`
    this.carbsTarget.textContent = `${this.fmt(carbsGrams)} g`
    this.fatTarget.textContent = `${this.fmt(fatGrams)} g`
  }

  clearResults() {
    this.proteinTarget.textContent = "— g"
    this.carbsTarget.textContent = "— g"
    this.fatTarget.textContent = "— g"
  }

  copy() {
    const text = [
      `Protein: ${this.proteinTarget.textContent}`,
      `Carbs: ${this.carbsTarget.textContent}`,
      `Fat: ${this.fatTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Math.round(n).toLocaleString()
  }
}
