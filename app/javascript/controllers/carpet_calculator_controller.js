import { Controller } from "@hotwired/stimulus"

const SQFT_PER_SQYD = 9.0

export default class extends Controller {
  static targets = ["length", "width", "waste", "rollWidth", "price",
                    "resultArea", "resultWithWaste", "resultSqyd", "resultLinear", "resultSeam", "resultCost"]

  connect() { this.calculate() }

  calculate() {
    const length = parseFloat(this.lengthTarget.value)
    const width = parseFloat(this.widthTarget.value)
    const waste = parseFloat(this.wasteTarget.value)
    const rollWidth = parseFloat(this.rollWidthTarget.value)
    const price = parseFloat(this.priceTarget.value)

    if (![length, width, rollWidth].every(n => Number.isFinite(n) && n > 0) ||
        !Number.isFinite(waste) || waste < 0) {
      this.clear()
      return
    }

    const area = length * width
    const withWaste = area * (1 + waste / 100)
    const sqyd = withWaste / SQFT_PER_SQYD
    const linear = withWaste / rollWidth
    const needsSeam = Math.min(length, width) > rollWidth

    this.resultAreaTarget.textContent = `${area.toFixed(1)} sq ft`
    this.resultWithWasteTarget.textContent = `${withWaste.toFixed(1)} sq ft`
    this.resultSqydTarget.textContent = `${sqyd.toFixed(2)} sq yd`
    this.resultLinearTarget.textContent = `${linear.toFixed(1)} lin ft`
    this.resultSeamTarget.textContent = needsSeam ? "Yes — seam required" : "No seam needed"
    if (Number.isFinite(price) && price > 0) {
      this.resultCostTarget.textContent = `$${(sqyd * price).toFixed(2)}`
    } else {
      this.resultCostTarget.textContent = "—"
    }
  }

  clear() {
    ["resultArea", "resultWithWaste", "resultSqyd", "resultLinear", "resultSeam", "resultCost"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
  }

  copy() {
    const text = `Carpet needed:\nArea: ${this.resultAreaTarget.textContent}\nWith waste: ${this.resultWithWasteTarget.textContent}\nSquare yards: ${this.resultSqydTarget.textContent}\nLinear feet off roll: ${this.resultLinearTarget.textContent}\nSeam: ${this.resultSeamTarget.textContent}\nCost: ${this.resultCostTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
