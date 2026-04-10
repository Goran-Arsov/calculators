import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "measured", "sampleTemp", "calTemp",
    "resultCorrected", "resultAdjustment", "resultBrix"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const measured = parseFloat(this.measuredTarget.value) || 0
    const sampleTemp = parseFloat(this.sampleTempTarget.value) || 0
    const calTemp = parseFloat(this.calTempTarget.value) || 60

    if (measured <= 0.98 || measured > 1.2 || sampleTemp < 32 || sampleTemp > 212) {
      this.clearResults()
      return
    }

    const poly = (t) => 1.313454 - 0.132674 * t + 2.057793e-3 * t * t - 2.627634e-6 * t * t * t
    const adjustment = (poly(sampleTemp) - poly(calTemp)) / 1000.0
    const corrected = measured + adjustment
    const brix = (((182.4601 * corrected - 775.6821) * corrected + 1262.7794) * corrected) - 669.5622

    this.resultCorrectedTarget.textContent = corrected.toFixed(4)
    this.resultAdjustmentTarget.textContent = (adjustment >= 0 ? "+" : "") + adjustment.toFixed(4)
    this.resultBrixTarget.textContent = brix.toFixed(2) + " °Bx"
  }

  clearResults() {
    this.resultCorrectedTarget.textContent = "—"
    this.resultAdjustmentTarget.textContent = "—"
    this.resultBrixTarget.textContent = "—"
  }

  copy() {
    const text = `Hydrometer Temperature Correction:\nCorrected Gravity: ${this.resultCorrectedTarget.textContent}\nAdjustment: ${this.resultAdjustmentTarget.textContent}\nBrix: ${this.resultBrixTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
