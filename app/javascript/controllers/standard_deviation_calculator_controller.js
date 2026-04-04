import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "values", "resultCount", "resultMean", "resultStdDev",
    "resultVariance", "resultMin", "resultMax", "resultRange"
  ]

  calculate() {
    const input = this.valuesTarget.value.trim()
    if (!input) {
      this.clearResults()
      return
    }

    const numbers = input.split(",")
      .map(s => s.trim())
      .filter(s => s !== "")
      .map(Number)
      .filter(n => !isNaN(n))

    if (numbers.length === 0) {
      this.clearResults()
      return
    }

    const count = numbers.length
    const sum = numbers.reduce((acc, n) => acc + n, 0)
    const mean = sum / count
    const min = Math.min(...numbers)
    const max = Math.max(...numbers)
    const range = max - min

    const squaredDiffs = numbers.map(n => (n - mean) ** 2)
    const variance = squaredDiffs.reduce((acc, d) => acc + d, 0) / count
    const stdDev = Math.sqrt(variance)

    this.resultCountTarget.textContent = count
    this.resultMeanTarget.textContent = this.fmt(mean)
    this.resultStdDevTarget.textContent = this.fmt(stdDev)
    this.resultVarianceTarget.textContent = this.fmt(variance)
    this.resultMinTarget.textContent = this.fmt(min)
    this.resultMaxTarget.textContent = this.fmt(max)
    this.resultRangeTarget.textContent = this.fmt(range)
  }

  clearResults() {
    this.resultCountTarget.textContent = "—"
    this.resultMeanTarget.textContent = "—"
    this.resultStdDevTarget.textContent = "—"
    this.resultVarianceTarget.textContent = "—"
    this.resultMinTarget.textContent = "—"
    this.resultMaxTarget.textContent = "—"
    this.resultRangeTarget.textContent = "—"
  }

  fmt(n) {
    if (n >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy(event) {
    const card = event.target.closest("[data-card]")
    const label = card.dataset.card
    const result = card.querySelector("[data-result]")
    navigator.clipboard.writeText(`${label}: ${result.textContent}`)
  }
}
