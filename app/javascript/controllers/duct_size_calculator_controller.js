import { Controller } from "@hotwired/stimulus"
import { IN_TO_CM, FT_TO_M } from "utils/units"

const CFM_TO_M3H = 1.69901 // cubic feet per minute → cubic meters per hour
const FPM_TO_MPS = 0.00508 // feet per minute → meters per second

export default class extends Controller {
  static targets = [
    "cfm", "velocity", "aspect",
    "unitSystem", "cfmLabel", "velocityLabel",
    "resultArea", "resultRound", "resultRect", "resultEquiv"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const cfm = parseFloat(this.cfmTarget.value)
    if (Number.isFinite(cfm)) this.cfmTarget.value = (toMetric ? cfm * CFM_TO_M3H : cfm / CFM_TO_M3H).toFixed(0)
    const vel = parseFloat(this.velocityTarget.value)
    if (Number.isFinite(vel)) this.velocityTarget.value = (toMetric ? vel * FPM_TO_MPS : vel / FPM_TO_MPS).toFixed(2)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.cfmLabelTarget.textContent = metric ? "Airflow (m³/h)" : "Airflow (CFM)"
    this.velocityLabelTarget.textContent = metric ? "Velocity (m/s)" : "Velocity (fpm)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const cfmInput = parseFloat(this.cfmTarget.value) || 0
    const velInput = parseFloat(this.velocityTarget.value) || 0
    const aspect = parseFloat(this.aspectTarget.value) || 2

    if (cfmInput <= 0 || velInput <= 0 || aspect < 1) {
      this.clear()
      return
    }

    // Work in imperial internally.
    const cfm = metric ? cfmInput / CFM_TO_M3H : cfmInput
    const velFpm = metric ? velInput / FPM_TO_MPS : velInput

    const areaSqft = cfm / velFpm
    const areaSqin = areaSqft * 144
    const roundIn = 2 * Math.sqrt(areaSqin / Math.PI)
    const shortIn = Math.sqrt(areaSqin / aspect)
    const longIn = shortIn * aspect
    const equivIn = 1.30 * Math.pow(longIn * shortIn, 0.625) / Math.pow(longIn + shortIn, 0.25)

    const roundCm = roundIn * IN_TO_CM
    const longCm = longIn * IN_TO_CM
    const shortCm = shortIn * IN_TO_CM
    const equivCm = equivIn * IN_TO_CM
    const areaM2 = areaSqft * 0.09290304

    if (metric) {
      this.resultAreaTarget.textContent = `${areaM2.toFixed(3)} m² (${areaSqft.toFixed(3)} sq ft)`
      this.resultRoundTarget.textContent = `${roundCm.toFixed(1)} cm (${roundIn.toFixed(2)} in)`
      this.resultRectTarget.textContent = `${longCm.toFixed(1)} × ${shortCm.toFixed(1)} cm (${longIn.toFixed(1)} × ${shortIn.toFixed(1)} in)`
      this.resultEquivTarget.textContent = `${equivCm.toFixed(1)} cm (${equivIn.toFixed(2)} in)`
    } else {
      this.resultAreaTarget.textContent = `${areaSqft.toFixed(3)} sq ft (${areaM2.toFixed(3)} m²)`
      this.resultRoundTarget.textContent = `${roundIn.toFixed(2)}" (${roundCm.toFixed(1)} cm)`
      this.resultRectTarget.textContent = `${longIn.toFixed(1)}" × ${shortIn.toFixed(1)}" (${longCm.toFixed(1)} × ${shortCm.toFixed(1)} cm)`
      this.resultEquivTarget.textContent = `${equivIn.toFixed(2)}" (${equivCm.toFixed(1)} cm)`
    }
  }

  clear() {
    ["Area","Round","Rect","Equiv"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Duct size:",
      `Area: ${this.resultAreaTarget.textContent}`,
      `Round diameter: ${this.resultRoundTarget.textContent}`,
      `Rectangular: ${this.resultRectTarget.textContent}`,
      `Equivalent round: ${this.resultEquivTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
