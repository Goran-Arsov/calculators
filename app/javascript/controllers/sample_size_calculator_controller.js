import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["confidence", "margin", "proportion", "resultSampleSize", "resultZScore"]

  calculate() {
    const confidenceLevel = parseFloat(this.confidenceTarget.value)
    const marginOfError = parseFloat(this.marginTarget.value)
    const proportion = parseFloat(this.proportionTarget.value)

    if (isNaN(confidenceLevel) || isNaN(marginOfError) || isNaN(proportion)) {
      this.resultSampleSizeTarget.textContent = "—"
      this.resultZScoreTarget.textContent = "—"
      return
    }

    if (marginOfError <= 0) {
      this.resultSampleSizeTarget.textContent = "Margin must be > 0"
      this.resultZScoreTarget.textContent = "—"
      return
    }

    const zScores = { 90: 1.645, 95: 1.96, 99: 2.576 }
    const z = zScores[confidenceLevel]

    if (!z) {
      this.resultSampleSizeTarget.textContent = "—"
      this.resultZScoreTarget.textContent = "—"
      return
    }

    const p = proportion / 100
    const e = marginOfError / 100
    const n = (z * z * p * (1 - p)) / (e * e)

    this.resultZScoreTarget.textContent = z
    this.resultSampleSizeTarget.textContent = this.fmt(Math.ceil(n))
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
