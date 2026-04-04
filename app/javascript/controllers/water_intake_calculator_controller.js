import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weight", "exercise", "resultLiters", "resultGlasses", "resultMl"]

  calculate() {
    const weight = parseFloat(this.weightTarget.value) || 0
    const exercise = parseFloat(this.exerciseTarget.value) || 0

    if (weight <= 0) {
      this.clearResults()
      return
    }

    const baseLiters = weight * 0.033
    const extraLiters = (exercise / 30) * 0.5
    const totalLiters = baseLiters + extraLiters
    const totalMl = totalLiters * 1000
    const glasses = totalMl / 250

    this.resultLitersTarget.textContent = this.fmt(totalLiters)
    this.resultGlassesTarget.textContent = Math.round(glasses)
    this.resultMlTarget.textContent = Math.round(totalMl).toLocaleString()
  }

  clearResults() {
    this.resultLitersTarget.textContent = "0"
    this.resultGlassesTarget.textContent = "0"
    this.resultMlTarget.textContent = "0"
  }

  fmt(n) {
    return n.toFixed(2)
  }
}
