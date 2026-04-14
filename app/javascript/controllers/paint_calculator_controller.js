import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, SQFT_TO_SQM, GAL_TO_L } from "utils/units"

const SQ_FT_PER_DOOR = 20
const SQ_FT_PER_WINDOW = 15
const SQ_FT_PER_GALLON = 350

export default class extends Controller {
  static targets = [
    "length", "width", "height", "coats", "doors", "windows",
    "unitSystem", "lengthLabel", "widthLabel", "heightLabel", "gallonsHeading",
    "resultWallArea", "resultPaintableArea", "resultGallons"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el, factor) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * factor : n / factor).toFixed(2)
    }
    convert(this.lengthTarget, FT_TO_M)
    convert(this.widthTarget, FT_TO_M)
    convert(this.heightTarget, FT_TO_M)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Room Length (m)" : "Room Length (ft)"
    this.widthLabelTarget.textContent = metric ? "Room Width (m)" : "Room Width (ft)"
    this.heightLabelTarget.textContent = metric ? "Room Height (m)" : "Room Height (ft)"
    this.gallonsHeadingTarget.textContent = metric ? "Liters Needed" : "Gallons Needed"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const height = parseFloat(this.heightTarget.value) || 0
    const coats = parseInt(this.coatsTarget.value) || 2
    const doors = parseInt(this.doorsTarget.value) || 0
    const windows = parseInt(this.windowsTarget.value) || 0

    // Convert metric to imperial for canonical math
    const lengthFt = metric ? length / FT_TO_M : length
    const widthFt = metric ? width / FT_TO_M : width
    const heightFt = metric ? height / FT_TO_M : height

    const wallAreaSqft = 2 * (lengthFt + widthFt) * heightFt
    const doorArea = doors * SQ_FT_PER_DOOR
    const windowArea = windows * SQ_FT_PER_WINDOW
    const paintableSqft = Math.max(wallAreaSqft - doorArea - windowArea, 0)
    const gallons = paintableSqft > 0 ? Math.ceil((paintableSqft * coats) / SQ_FT_PER_GALLON) : 0

    if (metric) {
      const wallAreaM2 = wallAreaSqft * SQFT_TO_SQM
      const paintableM2 = paintableSqft * SQFT_TO_SQM
      // Round up liters for practical purchasing
      const liters = paintableSqft > 0 ? Math.ceil(gallons * GAL_TO_L) : 0
      this.resultWallAreaTarget.textContent = `${this.fmt(wallAreaM2)} m²`
      this.resultPaintableAreaTarget.textContent = `${this.fmt(paintableM2)} m²`
      this.resultGallonsTarget.textContent = liters
    } else {
      this.resultWallAreaTarget.textContent = `${this.fmt(wallAreaSqft)} sq ft`
      this.resultPaintableAreaTarget.textContent = `${this.fmt(paintableSqft)} sq ft`
      this.resultGallonsTarget.textContent = gallons
    }
  }

  copy() {
    const wallArea = this.resultWallAreaTarget.textContent
    const paintableArea = this.resultPaintableAreaTarget.textContent
    const amount = this.resultGallonsTarget.textContent
    const text = `Paint Estimate:\nWall Area: ${wallArea}\nPaintable Area: ${paintableArea}\n${this.gallonsHeadingTarget.textContent}: ${amount}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
