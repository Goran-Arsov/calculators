import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM, CUFT_TO_CUM } from "utils/units"

const CFM_TO_M3H = 1.69901

export default class extends Controller {
  static targets = [
    "floor", "bedrooms", "ach50", "volume", "nf",
    "unitSystem", "floorLabel", "volumeLabel",
    "resultTotal", "resultInfil", "resultMechanical"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const a = parseFloat(this.floorTarget.value)
    if (Number.isFinite(a)) this.floorTarget.value = (toMetric ? a * SQFT_TO_SQM : a / SQFT_TO_SQM).toFixed(0)
    const v = parseFloat(this.volumeTarget.value)
    if (Number.isFinite(v)) this.volumeTarget.value = (toMetric ? v * CUFT_TO_CUM : v / CUFT_TO_CUM).toFixed(0)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.floorLabelTarget.textContent = metric ? "Conditioned floor area (m²)" : "Conditioned floor area (sq ft)"
    this.volumeLabelTarget.textContent = metric ? "House volume (m³, optional)" : "House volume (cu ft, optional)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const floor = parseFloat(this.floorTarget.value) || 0
    const bedrooms = parseInt(this.bedroomsTarget.value, 10) || 0
    const ach50 = parseFloat(this.ach50Target.value) || 0
    const volume = parseFloat(this.volumeTarget.value) || 0
    const nf = parseFloat(this.nfTarget.value) || 17

    if (floor <= 0) {
      this.clear()
      return
    }

    const floorSqft = metric ? floor / SQFT_TO_SQM : floor
    const volumeCuft = metric ? volume / CUFT_TO_CUM : volume

    const qTotal = (0.03 * floorSqft) + (7.5 * (bedrooms + 1))
    let qInfil = 0
    if (ach50 > 0 && volumeCuft > 0 && nf > 0) {
      const naturalAch = ach50 / nf
      qInfil = naturalAch * volumeCuft / 60
    }
    const qMech = Math.max(qTotal - qInfil, 0)

    const fmt = (cfm) => metric
      ? `${(cfm * CFM_TO_M3H).toFixed(0)} m³/h (${cfm.toFixed(1)} CFM)`
      : `${cfm.toFixed(1)} CFM (${(cfm * CFM_TO_M3H).toFixed(0)} m³/h)`

    this.resultTotalTarget.textContent = fmt(qTotal)
    this.resultInfilTarget.textContent = fmt(qInfil)
    this.resultMechanicalTarget.textContent = fmt(qMech)
  }

  clear() {
    ["Total","Infil","Mechanical"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "ASHRAE 62.2 ventilation:",
      `Total required: ${this.resultTotalTarget.textContent}`,
      `Infiltration credit: ${this.resultInfilTarget.textContent}`,
      `Required mechanical CFM: ${this.resultMechanicalTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
