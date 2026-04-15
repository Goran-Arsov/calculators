import { Controller } from "@hotwired/stimulus"
import { BTU_TO_W } from "utils/units"

const CURVES = {
  standard: {
    65: 1.10, 47: 1.00, 35: 0.88, 17: 0.70, 5: 0.55, "-5": 0.40, "-13": 0.30, "-25": 0.15
  },
  cold_climate: {
    65: 1.10, 47: 1.00, 35: 0.98, 17: 0.90, 5: 0.80, "-5": 0.70, "-13": 0.58, "-25": 0.40
  }
}

const fToC = (f) => (f - 32) * 5 / 9
const cToF = (c) => c * 9 / 5 + 32

function interpolate(curve, temp) {
  const sorted = Object.entries(curve).map(([t, f]) => [parseFloat(t), f]).sort((a, b) => a[0] - b[0])
  if (temp <= sorted[0][0]) return sorted[0][1]
  if (temp >= sorted[sorted.length - 1][0]) return sorted[sorted.length - 1][1]
  for (let i = 0; i < sorted.length - 1; i++) {
    const [t1, f1] = sorted[i]
    const [t2, f2] = sorted[i + 1]
    if (temp >= t1 && temp <= t2) {
      return f1 + (f2 - f1) * (temp - t1) / (t2 - t1)
    }
  }
  return 1.0
}

export default class extends Controller {
  static targets = [
    "rated", "outdoor", "hpType",
    "unitSystem", "outdoorLabel",
    "resultFraction", "resultActual", "resultTons", "resultDerating"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const t = parseFloat(this.outdoorTarget.value)
    if (Number.isFinite(t)) this.outdoorTarget.value = (toMetric ? fToC(t) : cToF(t)).toFixed(1)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.outdoorLabelTarget.textContent = metric ? "Outdoor temperature (°C)" : "Outdoor temperature (°F)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const rated = parseFloat(this.ratedTarget.value) || 0
    const outdoorInput = parseFloat(this.outdoorTarget.value)
    const hpType = this.hpTypeTarget.value

    if (rated <= 0 || !Number.isFinite(outdoorInput) || !CURVES[hpType]) {
      this.clear()
      return
    }

    const outdoorF = metric ? cToF(outdoorInput) : outdoorInput
    const fraction = interpolate(CURVES[hpType], outdoorF)
    const actualBtu = rated * fraction
    const actualW = actualBtu * BTU_TO_W
    const tons = actualBtu / 12000
    const derating = (1 - fraction) * 100

    this.resultFractionTarget.textContent = `${(fraction * 100).toFixed(1)}% of rated`
    this.resultActualTarget.textContent = metric
      ? `${actualW.toFixed(0)} W (${actualBtu.toFixed(0)} BTU/hr)`
      : `${actualBtu.toFixed(0)} BTU/hr (${actualW.toFixed(0)} W)`
    this.resultTonsTarget.textContent = `${tons.toFixed(2)} tons (${(actualW / 1000).toFixed(2)} kW)`
    this.resultDeratingTarget.textContent = `${derating.toFixed(1)}% capacity lost`
  }

  clear() {
    ["Fraction","Actual","Tons","Derating"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Heat pump capacity at temperature:",
      `Capacity fraction: ${this.resultFractionTarget.textContent}`,
      `Actual output: ${this.resultActualTarget.textContent}`,
      `Tons: ${this.resultTonsTarget.textContent}`,
      `Derating: ${this.resultDeratingTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
