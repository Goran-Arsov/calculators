import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM } from "utils/units"

const MERV_DROP = { 8: 0.08, 11: 0.14, 13: 0.22, 16: 0.35 }
const CFM_TO_M3H = 1.69901
const IWC_TO_PA = 249.089

export default class extends Controller {
  static targets = [
    "cfm", "length", "diameter", "fittings", "merv", "coilDrop",
    "unitSystem", "cfmLabel", "lengthLabel", "diameterLabel", "coilLabel",
    "resultFrictionPer100", "resultDuct", "resultFittings",
    "resultFilter", "resultCoil", "resultTotal", "resultStatus"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const cfm = parseFloat(this.cfmTarget.value)
    if (Number.isFinite(cfm)) this.cfmTarget.value = (toMetric ? cfm * CFM_TO_M3H : cfm / CFM_TO_M3H).toFixed(0)
    const len = parseFloat(this.lengthTarget.value)
    if (Number.isFinite(len)) this.lengthTarget.value = (toMetric ? len * FT_TO_M : len / FT_TO_M).toFixed(1)
    const d = parseFloat(this.diameterTarget.value)
    if (Number.isFinite(d)) this.diameterTarget.value = (toMetric ? d * IN_TO_CM : d / IN_TO_CM).toFixed(1)
    const coil = parseFloat(this.coilDropTarget.value)
    if (Number.isFinite(coil)) this.coilDropTarget.value = (toMetric ? coil * IWC_TO_PA : coil / IWC_TO_PA).toFixed(toMetric ? 0 : 2)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.cfmLabelTarget.textContent = metric ? "Airflow (m³/h)" : "Airflow (CFM)"
    this.lengthLabelTarget.textContent = metric ? "Total duct length (m)" : "Total duct length (ft)"
    this.diameterLabelTarget.textContent = metric ? "Duct diameter (cm)" : "Duct diameter (inches round or equiv)"
    this.coilLabelTarget.textContent = metric ? "Coil drop (Pa)" : "Coil drop (iwc)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const cfmInput = parseFloat(this.cfmTarget.value) || 0
    const lenInput = parseFloat(this.lengthTarget.value) || 0
    const dInput = parseFloat(this.diameterTarget.value) || 0
    const fittings = parseInt(this.fittingsTarget.value, 10) || 0
    const merv = parseInt(this.mervTarget.value, 10) || 8
    const coilInput = parseFloat(this.coilDropTarget.value) || 0

    if (cfmInput <= 0 || lenInput <= 0 || dInput <= 0) {
      this.clear()
      return
    }

    // Convert to imperial internally.
    const cfm = metric ? cfmInput / CFM_TO_M3H : cfmInput
    const lengthFt = metric ? lenInput / FT_TO_M : lenInput
    const dIn = metric ? dInput / IN_TO_CM : dInput
    const coilDrop = metric ? coilInput / IWC_TO_PA : coilInput

    const hfPer100 = 0.109136 * Math.pow(cfm, 1.9) / Math.pow(dIn, 5.02)
    const ductDrop = hfPer100 * lengthFt / 100
    const fittingEquivFt = fittings * 10
    const fittingDrop = hfPer100 * fittingEquivFt / 100
    const filterDrop = MERV_DROP[merv] || 0.1
    const total = ductDrop + fittingDrop + filterDrop + coilDrop

    const fmt = (iwc) => metric
      ? `${(iwc * IWC_TO_PA).toFixed(0)} Pa (${iwc.toFixed(3)} iwc)`
      : `${iwc.toFixed(3)} iwc (${(iwc * IWC_TO_PA).toFixed(0)} Pa)`

    this.resultFrictionPer100Target.textContent = metric
      ? `${(hfPer100 * IWC_TO_PA / 30.48 * 100).toFixed(1)} Pa/30 m (${hfPer100.toFixed(3)} iwc/100 ft)`
      : `${hfPer100.toFixed(3)} iwc/100 ft`
    this.resultDuctTarget.textContent = fmt(ductDrop)
    this.resultFittingsTarget.textContent = fmt(fittingDrop)
    this.resultFilterTarget.textContent = fmt(filterDrop)
    this.resultCoilTarget.textContent = fmt(coilDrop)
    this.resultTotalTarget.textContent = fmt(total)

    if (total <= 0.5) {
      this.resultStatusTarget.textContent = "✓ Within 0.5 iwc target"
      this.resultStatusTarget.className = "text-base font-bold text-green-600 dark:text-green-400"
    } else if (total <= 0.8) {
      this.resultStatusTarget.textContent = "⚠ 0.5-0.8 iwc (high, check blower)"
      this.resultStatusTarget.className = "text-base font-bold text-amber-600 dark:text-amber-400"
    } else {
      this.resultStatusTarget.textContent = "✗ Over 0.8 iwc (very high)"
      this.resultStatusTarget.className = "text-base font-bold text-red-600 dark:text-red-400"
    }
  }

  clear() {
    ["FrictionPer100","Duct","Fittings","Filter","Coil","Total","Status"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Static pressure:",
      `Friction per 100 ft: ${this.resultFrictionPer100Target.textContent}`,
      `Duct drop: ${this.resultDuctTarget.textContent}`,
      `Fittings: ${this.resultFittingsTarget.textContent}`,
      `Filter: ${this.resultFilterTarget.textContent}`,
      `Coil: ${this.resultCoilTarget.textContent}`,
      `Total TESP: ${this.resultTotalTarget.textContent}`,
      this.resultStatusTarget.textContent
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
