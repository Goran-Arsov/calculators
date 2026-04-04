import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["confidence", "marginOfError", "proportion", "sampleSize", "zScore"]

  calculate() {
    const confidenceLevel = parseFloat(this.confidenceTarget.value)
    const marginOfError = parseFloat(this.marginOfErrorTarget.value)
    const proportion = parseFloat(this.proportionTarget.value)

    if (isNaN(confidenceLevel) || isNaN(marginOfError) || isNaN(proportion)) {
      this.sampleSizeTarget.textContent = "—"
      this.zScoreTarget.textContent = "—"
      return
    }

    if (marginOfError <= 0) {
      this.sampleSizeTarget.textContent = "Margin must be > 0"
      this.zScoreTarget.textContent = "—"
      return
    }

    const zScores = { 90: 1.645, 95: 1.96, 99: 2.576 }
    const z = zScores[confidenceLevel]

    if (!z) {
      this.sampleSizeTarget.textContent = "—"
      this.zScoreTarget.textContent = "—"
      return
    }

    const p = proportion / 100
    const e = marginOfError / 100
    const n = (z * z * p * (1 - p)) / (e * e)

    this.zScoreTarget.textContent = z
    this.sampleSizeTarget.textContent = this.fmt(Math.ceil(n))
  }

  fmt(n) {
    if (n >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const sampleSize = this.sampleSizeTarget.textContent
    const zScore = this.zScoreTarget.textContent
    navigator.clipboard.writeText(`Sample Size: ${sampleSize}\nZ-Score: ${zScore}`)
  }
}
