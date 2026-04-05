import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["values", "count", "sum", "mean", "median", "mode", "range", "min", "max", "stdDev", "variance"]

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

    const sorted = [...numbers].sort((a, b) => a - b)
    const count = sorted.length
    const sum = sorted.reduce((acc, n) => acc + n, 0)
    const mean = sum / count

    let median
    if (count % 2 === 1) {
      median = sorted[Math.floor(count / 2)]
    } else {
      median = (sorted[count / 2 - 1] + sorted[count / 2]) / 2
    }

    const mode = this.computeMode(sorted)
    const min = sorted[0]
    const max = sorted[count - 1]
    const range = max - min

    const variance = sorted.reduce((acc, n) => acc + (n - mean) ** 2, 0) / count
    const stdDev = Math.sqrt(variance)

    this.countTarget.textContent = count
    this.sumTarget.textContent = this.fmt(sum)
    this.meanTarget.textContent = this.fmt(mean)
    this.medianTarget.textContent = this.fmt(median)
    this.modeTarget.textContent = mode
    this.rangeTarget.textContent = this.fmt(range)
    this.minTarget.textContent = this.fmt(min)
    this.maxTarget.textContent = this.fmt(max)
    this.stdDevTarget.textContent = this.fmt(stdDev)
    this.varianceTarget.textContent = this.fmt(variance)
  }

  computeMode(sorted) {
    const freq = {}
    sorted.forEach(n => { freq[n] = (freq[n] || 0) + 1 })
    const maxFreq = Math.max(...Object.values(freq))
    if (maxFreq === 1) return "No mode"
    const modes = Object.keys(freq).filter(k => freq[k] === maxFreq).map(Number)
    return modes.map(m => this.fmt(m)).join(", ")
  }

  clearResults() {
    this.countTarget.textContent = "—"
    this.sumTarget.textContent = "—"
    this.meanTarget.textContent = "—"
    this.medianTarget.textContent = "—"
    this.modeTarget.textContent = "—"
    this.rangeTarget.textContent = "—"
    this.minTarget.textContent = "—"
    this.maxTarget.textContent = "—"
    this.stdDevTarget.textContent = "—"
    this.varianceTarget.textContent = "—"
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const data = [
      `Count: ${this.countTarget.textContent}`,
      `Sum: ${this.sumTarget.textContent}`,
      `Mean: ${this.meanTarget.textContent}`,
      `Median: ${this.medianTarget.textContent}`,
      `Mode: ${this.modeTarget.textContent}`,
      `Range: ${this.rangeTarget.textContent}`,
      `Std Dev: ${this.stdDevTarget.textContent}`,
      `Variance: ${this.varianceTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(data)
  }
}
