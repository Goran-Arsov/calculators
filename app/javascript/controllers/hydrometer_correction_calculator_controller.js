import { Controller } from "@hotwired/stimulus"
import { fToC, cToF } from "utils/units"

export default class extends Controller {
  static targets = [
    "measured", "sampleTemp", "calTemp",
    "resultCorrected", "resultAdjustment", "resultBrix",
    "unitSystem", "sampleTempLabel", "calTempLabel"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? fToC(n) : cToF(n)).toFixed(1)
    }
    convert(this.sampleTempTarget)
    convert(this.calTempTarget)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.sampleTempLabelTarget.textContent = metric ? "Sample Temperature (°C)" : "Sample Temperature (°F)"
    this.calTempLabelTarget.textContent = metric ? "Calibration Temperature (°C)" : "Calibration Temperature (°F)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const measured = parseFloat(this.measuredTarget.value) || 0
    const sampleInput = parseFloat(this.sampleTempTarget.value)
    const calInput = parseFloat(this.calTempTarget.value)

    if (!Number.isFinite(sampleInput) || !Number.isFinite(calInput)) {
      this.clearResults()
      return
    }

    const sampleTempF = metric ? cToF(sampleInput) : sampleInput
    const calTempF = metric ? cToF(calInput) : calInput

    if (measured <= 0.98 || measured > 1.2 || sampleTempF < 32 || sampleTempF > 212) {
      this.clearResults()
      return
    }

    const poly = (t) => 1.313454 - 0.132674 * t + 2.057793e-3 * t * t - 2.627634e-6 * t * t * t
    const adjustment = (poly(sampleTempF) - poly(calTempF)) / 1000.0
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
