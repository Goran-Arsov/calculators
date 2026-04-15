import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM, PSI_TO_KPA } from "utils/units"

const C_FACTOR = { pvc: 150, copper: 140, pex: 150, steel: 120, galvanized: 100, cast_iron: 100 }
const PSI_PER_FT_WATER = 0.4331
const GPM_TO_LPM = 3.785411784

export default class extends Controller {
  static targets = [
    "flow", "diameter", "length", "material",
    "unitSystem", "flowLabel", "diameterLabel", "lengthLabel",
    "resultHead", "resultPsi", "resultPer100", "resultVelocity", "resultVelocityOk"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const flow = parseFloat(this.flowTarget.value)
    if (Number.isFinite(flow)) this.flowTarget.value = (toMetric ? flow * GPM_TO_LPM : flow / GPM_TO_LPM).toFixed(2)
    const d = parseFloat(this.diameterTarget.value)
    if (Number.isFinite(d)) this.diameterTarget.value = (toMetric ? d * IN_TO_CM * 10 : d / (IN_TO_CM * 10)).toFixed(2) // in ↔ mm
    const len = parseFloat(this.lengthTarget.value)
    if (Number.isFinite(len)) this.lengthTarget.value = (toMetric ? len * FT_TO_M : len / FT_TO_M).toFixed(2)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.flowLabelTarget.textContent = metric ? "Flow (L/min)" : "Flow (GPM)"
    this.diameterLabelTarget.textContent = metric ? "Inside diameter (mm)" : "Inside diameter (inches)"
    this.lengthLabelTarget.textContent = metric ? "Pipe length (m)" : "Pipe length (ft)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const flowInput = parseFloat(this.flowTarget.value) || 0
    const dInput = parseFloat(this.diameterTarget.value) || 0
    const lenInput = parseFloat(this.lengthTarget.value) || 0
    const material = this.materialTarget.value

    if (flowInput <= 0 || dInput <= 0 || lenInput <= 0 || !C_FACTOR[material]) {
      this.clear()
      return
    }

    // Convert to imperial internally (gpm, inches, feet).
    const flowGpm = metric ? flowInput / GPM_TO_LPM : flowInput
    const dIn = metric ? dInput / (IN_TO_CM * 10) : dInput
    const lenFt = metric ? lenInput / FT_TO_M : lenInput

    const c = C_FACTOR[material]
    const hfPerFt = 4.52 * Math.pow(flowGpm, 1.852) / (Math.pow(c, 1.852) * Math.pow(dIn, 4.87))
    const headLossFt = hfPerFt * lenFt
    const pressureLossPsi = headLossFt * PSI_PER_FT_WATER
    const lossPer100ft = pressureLossPsi / lenFt * 100
    const velFps = 0.4085 * flowGpm / (dIn * dIn)
    const velOk = velFps <= 8

    const headLossM = headLossFt * FT_TO_M
    const pressureLossKpa = pressureLossPsi * PSI_TO_KPA
    const velMps = velFps * FT_TO_M

    if (metric) {
      this.resultHeadTarget.textContent = `${headLossM.toFixed(3)} m (${headLossFt.toFixed(2)} ft of water)`
      this.resultPsiTarget.textContent = `${pressureLossKpa.toFixed(1)} kPa (${pressureLossPsi.toFixed(2)} psi)`
      this.resultPer100Target.textContent = `${(lossPer100ft * PSI_TO_KPA / 30.48 * 100).toFixed(1)} kPa/30 m (${lossPer100ft.toFixed(2)} psi/100 ft)`
      this.resultVelocityTarget.textContent = `${velMps.toFixed(2)} m/s (${velFps.toFixed(2)} ft/s)`
    } else {
      this.resultHeadTarget.textContent = `${headLossFt.toFixed(2)} ft of water (${headLossM.toFixed(2)} m)`
      this.resultPsiTarget.textContent = `${pressureLossPsi.toFixed(2)} psi (${pressureLossKpa.toFixed(1)} kPa)`
      this.resultPer100Target.textContent = `${lossPer100ft.toFixed(2)} psi/100 ft`
      this.resultVelocityTarget.textContent = `${velFps.toFixed(2)} ft/s (${velMps.toFixed(2)} m/s)`
    }
    this.resultVelocityOkTarget.textContent = velOk ? "✓ Within 8 ft/s limit" : "✗ Exceeds 8 ft/s (erosion risk)"
    this.resultVelocityOkTarget.className = velOk
      ? "text-base font-bold text-green-600 dark:text-green-400"
      : "text-base font-bold text-red-600 dark:text-red-400"
  }

  clear() {
    ["Head","Psi","Per100","Velocity","VelocityOk"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Pipe friction loss:",
      `Head loss: ${this.resultHeadTarget.textContent}`,
      `Pressure loss: ${this.resultPsiTarget.textContent}`,
      `Loss per 100 ft: ${this.resultPer100Target.textContent}`,
      `Velocity: ${this.resultVelocityTarget.textContent}`,
      this.resultVelocityOkTarget.textContent
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
