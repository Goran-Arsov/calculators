import { Controller } from "@hotwired/stimulus"
import { GAL_TO_L } from "utils/units"

export default class extends Controller {
  static targets = [
    "batchVolume", "og",
    "hop1Weight", "hop1Aa", "hop1Time",
    "hop2Weight", "hop2Aa", "hop2Time",
    "hop3Weight", "hop3Aa", "hop3Time",
    "hop4Weight", "hop4Aa", "hop4Time",
    "resultTotal", "resultCategory",
    "resultHop1", "resultHop2", "resultHop3", "resultHop4",
    "unitSystem", "batchVolumeLabel"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const n = parseFloat(this.batchVolumeTarget.value)
    if (Number.isFinite(n)) {
      this.batchVolumeTarget.value = (toMetric ? n * GAL_TO_L : n / GAL_TO_L).toFixed(2)
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.batchVolumeLabelTarget.textContent = metric ? "Batch (L)" : "Batch (gal)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const volumeInput = parseFloat(this.batchVolumeTarget.value) || 0
    const og = parseFloat(this.ogTarget.value) || 0

    if (volumeInput <= 0 || og <= 1.0) {
      this.clearResults()
      return
    }

    // Tinseth's formula uses batch volume in gallons internally.
    const volumeGal = metric ? volumeInput / GAL_TO_L : volumeInput
    const bigness = 1.65 * Math.pow(0.000125, og - 1.0)

    const hops = [
      { w: this.hop1WeightTarget, a: this.hop1AaTarget, t: this.hop1TimeTarget, r: this.resultHop1Target },
      { w: this.hop2WeightTarget, a: this.hop2AaTarget, t: this.hop2TimeTarget, r: this.resultHop2Target },
      { w: this.hop3WeightTarget, a: this.hop3AaTarget, t: this.hop3TimeTarget, r: this.resultHop3Target },
      { w: this.hop4WeightTarget, a: this.hop4AaTarget, t: this.hop4TimeTarget, r: this.resultHop4Target }
    ]

    let total = 0
    hops.forEach((h) => {
      const weight = parseFloat(h.w.value) || 0
      const aa = (parseFloat(h.a.value) || 0) / 100.0
      const time = parseFloat(h.t.value) || 0
      if (weight > 0 && aa > 0 && time >= 0) {
        const boilFactor = (1.0 - Math.exp(-0.04 * time)) / 4.15
        const utilization = bigness * boilFactor
        const ibus = (aa * weight * utilization * 7489.0) / volumeGal
        total += ibus
        h.r.textContent = ibus.toFixed(1) + " IBU"
      } else {
        h.r.textContent = "—"
      }
    })

    this.resultTotalTarget.textContent = total.toFixed(1)
    this.resultCategoryTarget.textContent = this.category(total)
  }

  category(ibu) {
    if (ibu < 10) return "Very low (light lagers, kölsch)"
    if (ibu < 20) return "Low (wheat beer, blonde ale)"
    if (ibu < 30) return "Mild (amber, brown, stout)"
    if (ibu < 45) return "Moderate (pale ale, porter)"
    if (ibu < 60) return "Assertive (IPA, ESB)"
    if (ibu < 80) return "Strong (American IPA, double IPA)"
    return "Very strong (imperial IPA)"
  }

  clearResults() {
    this.resultTotalTarget.textContent = "0"
    this.resultCategoryTarget.textContent = "—"
    ;[this.resultHop1Target, this.resultHop2Target, this.resultHop3Target, this.resultHop4Target].forEach(t => t.textContent = "—")
  }

  copy() {
    const text = `IBU Calculation:\nTotal IBU: ${this.resultTotalTarget.textContent}\nCategory: ${this.resultCategoryTarget.textContent}\nHop 1: ${this.resultHop1Target.textContent}\nHop 2: ${this.resultHop2Target.textContent}\nHop 3: ${this.resultHop3Target.textContent}\nHop 4: ${this.resultHop4Target.textContent}`
    navigator.clipboard.writeText(text)
  }
}
