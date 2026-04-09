import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "responseTimes",
    "resultCount", "resultMean", "resultMedian", "resultMin", "resultMax",
    "resultStdDev", "resultP50", "resultP90", "resultP95", "resultP99",
    "resultsContainer"
  ]

  calculate() {
    const input = this.responseTimesTarget.value.trim()
    if (!input) {
      this.clearResults()
      return
    }

    const parts = input.split(",").map(s => s.trim()).filter(s => s.length > 0)
    if (parts.length === 0) {
      this.clearResults()
      return
    }

    const values = []
    for (const part of parts) {
      const num = parseFloat(part)
      if (isNaN(num) || num < 0) {
        this.showError("Invalid or negative value: " + part)
        return
      }
      values.push(num)
    }

    values.sort((a, b) => a - b)
    const count = values.length
    const sum = values.reduce((a, b) => a + b, 0)
    const mean = sum / count
    const median = this.percentile(values, 50)
    const min = values[0]
    const max = values[count - 1]

    const variance = values.reduce((acc, v) => acc + Math.pow(v - mean, 2), 0) / count
    const stdDev = Math.sqrt(variance)

    this.resultsContainerTarget.classList.remove("hidden")

    this.resultCountTarget.textContent = count.toLocaleString()
    this.resultMeanTarget.textContent = mean.toFixed(2) + " ms"
    this.resultMedianTarget.textContent = median.toFixed(2) + " ms"
    this.resultMinTarget.textContent = min.toFixed(2) + " ms"
    this.resultMaxTarget.textContent = max.toFixed(2) + " ms"
    this.resultStdDevTarget.textContent = stdDev.toFixed(2) + " ms"
    this.resultP50Target.textContent = this.percentile(values, 50).toFixed(2) + " ms"
    this.resultP90Target.textContent = this.percentile(values, 90).toFixed(2) + " ms"
    this.resultP95Target.textContent = this.percentile(values, 95).toFixed(2) + " ms"
    this.resultP99Target.textContent = this.percentile(values, 99).toFixed(2) + " ms"
  }

  // Nearest-rank method
  percentile(sorted, pct) {
    if (sorted.length === 1) return sorted[0]
    let rank = Math.ceil((pct / 100) * sorted.length)
    rank = Math.max(rank, 1)
    rank = Math.min(rank, sorted.length)
    return sorted[rank - 1]
  }

  showError(message) {
    this.resultsContainerTarget.classList.remove("hidden")
    this.resultCountTarget.textContent = message
    this.resultMeanTarget.textContent = "\u2014"
    this.resultMedianTarget.textContent = "\u2014"
    this.resultMinTarget.textContent = "\u2014"
    this.resultMaxTarget.textContent = "\u2014"
    this.resultStdDevTarget.textContent = "\u2014"
    this.resultP50Target.textContent = "\u2014"
    this.resultP90Target.textContent = "\u2014"
    this.resultP95Target.textContent = "\u2014"
    this.resultP99Target.textContent = "\u2014"
  }

  clearResults() {
    this.resultsContainerTarget.classList.add("hidden")
    this.resultCountTarget.textContent = "\u2014"
    this.resultMeanTarget.textContent = "\u2014"
    this.resultMedianTarget.textContent = "\u2014"
    this.resultMinTarget.textContent = "\u2014"
    this.resultMaxTarget.textContent = "\u2014"
    this.resultStdDevTarget.textContent = "\u2014"
    this.resultP50Target.textContent = "\u2014"
    this.resultP90Target.textContent = "\u2014"
    this.resultP95Target.textContent = "\u2014"
    this.resultP99Target.textContent = "\u2014"
  }
}
