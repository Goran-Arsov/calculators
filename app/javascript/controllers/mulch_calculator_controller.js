import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM, CUFT_TO_CUM, FT_TO_M, IN_TO_CM } from "../utils/units"

const CUBIC_FEET_PER_YARD = 27.0
const BAG_CUBIC_FEET = 2.0
const IMPERIAL_DEFAULTS = { length: 20, width: 5, depth: 3 }
const METRIC_DEFAULTS = { length: 6, width: 1.5, depth: 7.5 }

export default class extends Controller {
  static targets = [
    "unitSystem", "length", "width", "depth",
    "lengthLabel", "widthLabel", "depthLabel",
    "resultCubicYards", "resultCubicFeet", "resultBags", "resultArea"
  ]

  connect() { this.calculate() }

  unitChanged() {
    const metric = this.isMetric()
    const inputs = [
      [this.lengthTarget, IMPERIAL_DEFAULTS.length, METRIC_DEFAULTS.length, FT_TO_M],
      [this.widthTarget, IMPERIAL_DEFAULTS.width, METRIC_DEFAULTS.width, FT_TO_M],
      [this.depthTarget, IMPERIAL_DEFAULTS.depth, METRIC_DEFAULTS.depth, IN_TO_CM]
    ]

    for (const [el, impDefault, metricDefault, factor] of inputs) {
      const current = parseFloat(el.value) || 0
      if (current > 0) {
        el.value = metric ? (current * factor).toFixed(2) : (current / factor).toFixed(2)
      } else {
        el.value = metric ? metricDefault : impDefault
      }
    }

    if (this.hasLengthLabelTarget) {
      this.lengthLabelTarget.textContent = metric ? "Length (m)" : "Length (ft)"
      this.widthLabelTarget.textContent = metric ? "Width (m)" : "Width (ft)"
      this.depthLabelTarget.textContent = metric ? "Depth (cm)" : "Depth (inches)"
    }

    this.calculate()
  }

  calculate() {
    const metric = this.isMetric()
    const length = metric
      ? (parseFloat(this.lengthTarget.value) || 0) / FT_TO_M
      : (parseFloat(this.lengthTarget.value) || 0)
    const width = metric
      ? (parseFloat(this.widthTarget.value) || 0) / FT_TO_M
      : (parseFloat(this.widthTarget.value) || 0)
    const depth = metric
      ? (parseFloat(this.depthTarget.value) || 0) / IN_TO_CM
      : (parseFloat(this.depthTarget.value) || 0)

    if (!Number.isFinite(length) || length <= 0 ||
        !Number.isFinite(width) || width <= 0 ||
        !Number.isFinite(depth) || depth <= 0) {
      this.clear()
      return
    }

    const area = length * width
    const cubicFeet = area * (depth / 12.0)
    const cubicYards = cubicFeet / CUBIC_FEET_PER_YARD
    const bags = Math.ceil(cubicFeet / BAG_CUBIC_FEET)
    const cubicMeters = cubicFeet * CUFT_TO_CUM

    this.resultAreaTarget.textContent = `${area.toFixed(1)} sq ft (${(area * SQFT_TO_SQM).toFixed(2)} m²)`
    this.resultCubicFeetTarget.textContent = `${cubicFeet.toFixed(2)} cu ft (${cubicMeters.toFixed(2)} m³)`
    this.resultCubicYardsTarget.textContent = `${cubicYards.toFixed(2)} cu yd (${cubicMeters.toFixed(2)} m³)`
    this.resultBagsTarget.textContent = `${bags}`
  }

  isMetric() {
    return this.hasUnitSystemTarget && this.unitSystemTarget.value === "metric"
  }

  clear() {
    this.resultAreaTarget.textContent = "—"
    this.resultCubicFeetTarget.textContent = "—"
    this.resultCubicYardsTarget.textContent = "—"
    this.resultBagsTarget.textContent = "—"
  }

  copy() {
    const text = `Mulch needed:\nArea: ${this.resultAreaTarget.textContent}\nCubic feet: ${this.resultCubicFeetTarget.textContent}\nCubic yards: ${this.resultCubicYardsTarget.textContent}\n2 cu ft bags: ${this.resultBagsTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
