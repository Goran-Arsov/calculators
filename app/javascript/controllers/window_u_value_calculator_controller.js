import { Controller } from "@hotwired/stimulus"

const GLASS_TYPES = {
  single: { u: 5.7, shgc: 0.86, label: "Single Pane" },
  double: { u: 2.8, shgc: 0.76, label: "Double Pane (air)" },
  double_argon: { u: 2.0, shgc: 0.73, label: "Double Pane (argon)" },
  double_low_e: { u: 1.6, shgc: 0.40, label: "Double Pane Low-E (air)" },
  double_low_e_argon: { u: 1.1, shgc: 0.40, label: "Double Pane Low-E (argon)" },
  triple: { u: 1.0, shgc: 0.68, label: "Triple Pane (air)" },
  triple_argon: { u: 0.7, shgc: 0.65, label: "Triple Pane (argon)" },
  triple_low_e_argon: { u: 0.5, shgc: 0.27, label: "Triple Pane Low-E (argon)" }
}

const FRAME_TYPES = {
  aluminum: { adj: 1.2, label: "Aluminum (no break)" },
  aluminum_break: { adj: 0.6, label: "Aluminum (thermal break)" },
  vinyl: { adj: 0.3, label: "Vinyl / PVC" },
  wood: { adj: 0.2, label: "Wood" },
  fiberglass: { adj: 0.25, label: "Fiberglass" }
}

export default class extends Controller {
  static targets = ["glassType", "frameType", "framePercentage",
    "resultWholeU", "resultRMetric", "resultRImperial",
    "resultUImperial", "resultShgc", "resultEnergyStar",
    "resultGlassLabel", "resultFrameLabel"]

  calculate() {
    const glassKey = this.glassTypeTarget.value || "double"
    const frameKey = this.frameTypeTarget.value || "vinyl"
    const framePct = (parseFloat(this.framePercentageTarget.value) || 20) / 100

    if (!GLASS_TYPES[glassKey] || !FRAME_TYPES[frameKey] || framePct <= 0 || framePct > 0.5) {
      this.clearResults()
      return
    }

    const glass = GLASS_TYPES[glassKey]
    const frame = FRAME_TYPES[frameKey]

    const glassU = glass.u
    const frameU = frame.adj + glassU * 0.5
    const glassFraction = 1.0 - framePct
    const wholeWindowU = (glassU * glassFraction + frameU * framePct).toFixed(2)

    const rMetric = wholeWindowU > 0 ? (1.0 / wholeWindowU).toFixed(2) : "0.00"
    const rImperial = (rMetric * 5.678).toFixed(2)
    const uImperial = (wholeWindowU / 5.678).toFixed(3)
    const energyStar = uImperial <= 0.30

    this.resultWholeUTarget.textContent = `${wholeWindowU} W/m\u00B2K`
    this.resultRMetricTarget.textContent = `${rMetric} m\u00B2K/W`
    this.resultRImperialTarget.textContent = `R-${rImperial}`
    this.resultUImperialTarget.textContent = `${uImperial} BTU/h\u00B7ft\u00B2\u00B7\u00B0F`
    this.resultShgcTarget.textContent = glass.shgc.toFixed(2)
    this.resultEnergyStarTarget.textContent = energyStar ? "Yes" : "No"
    this.resultEnergyStarTarget.className = energyStar
      ? "text-xl font-bold text-green-600 dark:text-green-400"
      : "text-xl font-bold text-red-600 dark:text-red-400"
    this.resultGlassLabelTarget.textContent = glass.label
    this.resultFrameLabelTarget.textContent = frame.label
  }

  clearResults() {
    this.resultWholeUTarget.textContent = "0 W/m\u00B2K"
    this.resultRMetricTarget.textContent = "0 m\u00B2K/W"
    this.resultRImperialTarget.textContent = "R-0"
    this.resultUImperialTarget.textContent = "0"
    this.resultShgcTarget.textContent = "0"
    this.resultEnergyStarTarget.textContent = "--"
    this.resultEnergyStarTarget.className = "text-xl font-bold text-gray-400"
    this.resultGlassLabelTarget.textContent = "--"
    this.resultFrameLabelTarget.textContent = "--"
  }

  copy() {
    const u = this.resultWholeUTarget.textContent
    const rImp = this.resultRImperialTarget.textContent
    const shgc = this.resultShgcTarget.textContent
    const es = this.resultEnergyStarTarget.textContent
    const text = `Window U-Value Estimate:\nWhole Window U-Value: ${u}\nR-Value: ${rImp}\nSHGC: ${shgc}\nEnergy Star Qualified: ${es}`
    navigator.clipboard.writeText(text)
  }
}
