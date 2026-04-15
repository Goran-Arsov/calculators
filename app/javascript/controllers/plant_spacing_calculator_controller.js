import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM } from "../utils/units"

const TRI_FACTOR = Math.sqrt(3) / 2

export default class extends Controller {
  static targets = ["length", "width", "spacing", "pattern", "resultPlants", "resultRows", "resultPerRow", "resultArea"]

  connect() { this.calculate() }

  calculate() {
    const length = parseFloat(this.lengthTarget.value)
    const width = parseFloat(this.widthTarget.value)
    const spacing = parseFloat(this.spacingTarget.value)
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
    this.resultAreaTarget.textContent = `${areaSqft.toFixed(1)} sq ft (${(areaSqft * SQFT_TO_SQM).toFixed(2)} m²)`
    this.resultPlantsTarget.textContent = `${plants}`
    this.resultRowsTarget.textContent = `${rows}`
    this.resultPerRowTarget.textContent = `${perRow}`
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
