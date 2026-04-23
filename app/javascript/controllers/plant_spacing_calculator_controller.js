import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM, FT_TO_M, IN_TO_CM } from "../utils/units"

const TRI_FACTOR = Math.sqrt(3) / 2
const IMPERIAL_DEFAULTS = { length: 8, width: 4, spacing: 12 }
const METRIC_DEFAULTS = { length: 2.5, width: 1.2, spacing: 30 }

export default class extends Controller {
  static targets = [
    "unitSystem", "length", "width", "spacing", "pattern",
    "lengthLabel", "widthLabel", "spacingLabel",
    "resultPlants", "resultRows", "resultPerRow", "resultArea"
  ]

  connect() { this.calculate() }

  unitChanged() {
    const metric = this.isMetric()
    const inputs = [
      [this.lengthTarget, IMPERIAL_DEFAULTS.length, METRIC_DEFAULTS.length, "length"],
      [this.widthTarget, IMPERIAL_DEFAULTS.width, METRIC_DEFAULTS.width, "length"],
      [this.spacingTarget, IMPERIAL_DEFAULTS.spacing, METRIC_DEFAULTS.spacing, "small"]
    ]

    for (const [el, impDefault, metricDefault, scale] of inputs) {
      const current = parseFloat(el.value) || 0
      if (current > 0) {
        el.value = metric
          ? (scale === "length" ? (current * FT_TO_M).toFixed(2) : (current * IN_TO_CM).toFixed(1))
          : (scale === "length" ? (current / FT_TO_M).toFixed(2) : (current / IN_TO_CM).toFixed(2))
      } else {
        el.value = metric ? metricDefault : impDefault
      }
    }

    if (this.hasLengthLabelTarget) {
      this.lengthLabelTarget.textContent = metric ? "Bed length (m)" : "Bed length (ft)"
      this.widthLabelTarget.textContent = metric ? "Bed width (m)" : "Bed width (ft)"
      this.spacingLabelTarget.textContent = metric ? "Plant spacing (cm)" : "Plant spacing (inches)"
    }

    this.calculate()
  }

  calculate() {
    const metric = this.isMetric()
    // Convert inputs to feet (for length/width) and inches (for spacing).
    const length = metric
      ? (parseFloat(this.lengthTarget.value) || 0) / FT_TO_M
      : (parseFloat(this.lengthTarget.value) || 0)
    const width = metric
      ? (parseFloat(this.widthTarget.value) || 0) / FT_TO_M
      : (parseFloat(this.widthTarget.value) || 0)
    const spacing = metric
      ? (parseFloat(this.spacingTarget.value) || 0) / IN_TO_CM
      : (parseFloat(this.spacingTarget.value) || 0)
    const pattern = this.patternTarget.value

    if (!Number.isFinite(length) || length <= 0 ||
        !Number.isFinite(width) || width <= 0 ||
        !Number.isFinite(spacing) || spacing <= 0) {
      this.clear()
      return
    }

    const lengthIn = length * 12
    const widthIn = width * 12
    const rowSpacing = pattern === "triangular" ? spacing * TRI_FACTOR : spacing
    const rows = Math.floor(widthIn / rowSpacing) + 1
    const perRow = Math.floor(lengthIn / spacing) + 1
    const plants = rows * perRow

    const areaSqft = length * width
    this.resultAreaTarget.textContent =
      `${areaSqft.toFixed(1)} sq ft (${(areaSqft * SQFT_TO_SQM).toFixed(2)} m²)`
    this.resultPlantsTarget.textContent = `${plants}`
    this.resultRowsTarget.textContent = `${rows}`
    this.resultPerRowTarget.textContent = `${perRow}`
  }

  isMetric() {
    return this.hasUnitSystemTarget && this.unitSystemTarget.value === "metric"
  }

  clear() {
    this.resultAreaTarget.textContent = "—"
    this.resultPlantsTarget.textContent = "—"
    this.resultRowsTarget.textContent = "—"
    this.resultPerRowTarget.textContent = "—"
  }

  copy() {
    const text = `Plant spacing:\nArea: ${this.resultAreaTarget.textContent}\nTotal plants: ${this.resultPlantsTarget.textContent}\nRows: ${this.resultRowsTarget.textContent}\nPlants per row: ${this.resultPerRowTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
