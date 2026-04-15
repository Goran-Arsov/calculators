import { Controller } from "@hotwired/stimulus"
import { FT_TO_M } from "utils/units"

// IRC Table R502.3.1(1) max spans in feet for 40 psf live + 10 psf dead.
const MAX_SPAN_FT = {
  "2x6":  { 12: { spf_2: 10.75, syp_2: 10.75, df_2: 10.75 }, 16: { spf_2: 9.75,  syp_2: 9.75,  df_2: 9.75 },  24: { spf_2: 8.5,  syp_2: 8.5,  df_2: 8.5 } },
  "2x8":  { 12: { spf_2: 14.17, syp_2: 14.17, df_2: 14.17 }, 16: { spf_2: 12.67, syp_2: 12.83, df_2: 12.83 }, 24: { spf_2: 11.0, syp_2: 11.08, df_2: 11.08 } },
  "2x10": { 12: { spf_2: 18.0,  syp_2: 18.0,  df_2: 18.0 },  16: { spf_2: 15.42, syp_2: 16.17, df_2: 16.17 }, 24: { spf_2: 12.58, syp_2: 13.17, df_2: 13.17 } },
  "2x12": { 12: { spf_2: 21.0,  syp_2: 21.0,  df_2: 21.0 },  16: { spf_2: 17.83, syp_2: 18.75, df_2: 18.75 }, 24: { spf_2: 14.58, syp_2: 15.25, df_2: 15.25 } }
}

const BF_PER_LIN_FT = { "2x6": 1.0, "2x8": 1.333, "2x10": 1.667, "2x12": 2.0 }

export default class extends Controller {
  static targets = [
    "length", "width", "size", "spacing", "species",
    "unitSystem", "lengthLabel", "widthLabel",
    "resultSpan", "resultCarry", "resultCount", "resultLinear", "resultBoard", "resultMaxSpan", "resultOk"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * FT_TO_M : n / FT_TO_M).toFixed(2)
    }
    convert(this.lengthTarget)
    convert(this.widthTarget)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Room length (m)" : "Room length (ft)"
    this.widthLabelTarget.textContent = metric ? "Room width (m)" : "Room width (ft)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const lengthInput = parseFloat(this.lengthTarget.value) || 0
    const widthInput = parseFloat(this.widthTarget.value) || 0
    const size = this.sizeTarget.value
    const spacingIn = parseInt(this.spacingTarget.value, 10) || 16
    const species = this.speciesTarget.value

    if (lengthInput <= 0 || widthInput <= 0 || !MAX_SPAN_FT[size]) {
      this.clear()
      return
    }

    const lengthFt = metric ? lengthInput / FT_TO_M : lengthInput
    const widthFt = metric ? widthInput / FT_TO_M : widthInput

    const spanFt = Math.min(lengthFt, widthFt)
    const carryFt = Math.max(lengthFt, widthFt)
    const joistCount = Math.ceil((carryFt * 12) / spacingIn) + 1
    const totalLinearFt = joistCount * spanFt
    const boardFeet = totalLinearFt * BF_PER_LIN_FT[size]
    const maxSpanFt = (MAX_SPAN_FT[size][spacingIn] || {})[species] || 0
    const spanOk = spanFt <= maxSpanFt

    if (metric) {
      this.resultSpanTarget.textContent = `${(spanFt * FT_TO_M).toFixed(2)} m (${spanFt.toFixed(2)} ft)`
      this.resultCarryTarget.textContent = `${(carryFt * FT_TO_M).toFixed(2)} m (${carryFt.toFixed(2)} ft)`
      this.resultLinearTarget.textContent = `${(totalLinearFt * FT_TO_M).toFixed(1)} m (${totalLinearFt.toFixed(1)} ft)`
      this.resultMaxSpanTarget.textContent = `${(maxSpanFt * FT_TO_M).toFixed(2)} m (${maxSpanFt.toFixed(2)} ft)`
    } else {
      this.resultSpanTarget.textContent = `${spanFt.toFixed(2)} ft (${(spanFt * FT_TO_M).toFixed(2)} m)`
      this.resultCarryTarget.textContent = `${carryFt.toFixed(2)} ft (${(carryFt * FT_TO_M).toFixed(2)} m)`
      this.resultLinearTarget.textContent = `${totalLinearFt.toFixed(1)} ft (${(totalLinearFt * FT_TO_M).toFixed(1)} m)`
      this.resultMaxSpanTarget.textContent = `${maxSpanFt.toFixed(2)} ft (${(maxSpanFt * FT_TO_M).toFixed(2)} m)`
    }
    this.resultCountTarget.textContent = joistCount
    this.resultBoardTarget.textContent = `${boardFeet.toFixed(1)} BF`
    this.resultOkTarget.textContent = spanOk ? "✓ Span OK" : "✗ Span exceeds IRC max"
    this.resultOkTarget.className = spanOk
      ? "text-base font-bold text-green-600 dark:text-green-400"
      : "text-base font-bold text-red-600 dark:text-red-400"
  }

  clear() {
    ["Span","Carry","Count","Linear","Board","MaxSpan","Ok"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Joist estimate:",
      `Span: ${this.resultSpanTarget.textContent}`,
      `Count: ${this.resultCountTarget.textContent}`,
      `Total linear: ${this.resultLinearTarget.textContent}`,
      `Board feet: ${this.resultBoardTarget.textContent}`,
      `Max IRC span: ${this.resultMaxSpanTarget.textContent}`,
      `Status: ${this.resultOkTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
