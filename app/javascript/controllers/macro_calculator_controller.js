import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["calories", "goal", "resultProtein", "resultCarbs", "resultFat"]

  static ratios = {
    maintain: { protein: 30, carbs: 40, fat: 30 },
    cut:      { protein: 40, carbs: 30, fat: 30 },
    bulk:     { protein: 25, carbs: 50, fat: 25 }
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

    this.resultProteinTarget.textContent = this.fmt(proteinGrams)
    this.resultCarbsTarget.textContent = this.fmt(carbsGrams)
    this.resultFatTarget.textContent = this.fmt(fatGrams)
  }

  clearResults() {
    this.resultProteinTarget.textContent = "0"
    this.resultCarbsTarget.textContent = "0"
    this.resultFatTarget.textContent = "0"
  }

  fmt(n) {
    return Math.round(n).toLocaleString()
  }
}
