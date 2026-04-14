import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, SQFT_TO_SQM, SQYD_TO_SQM } from "utils/units"

const SQFT_PER_SQYD = 9.0

export default class extends Controller {
  static targets = ["length", "width", "waste", "rollWidth", "price",
                    "unitSystem", "lengthLabel", "widthLabel", "rollWidthLabel", "priceLabel",
                    "sqydHeading", "linearHeading",
                    "resultArea", "resultWithWaste", "resultSqyd", "resultLinear", "resultSeam", "resultCost"]

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
    convert(this.rollWidthTarget, FT_TO_M)
    convert(this.priceTarget, 1 / SQYD_TO_SQM) // price per sq yd → price per m² (÷0.836)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Length (m)" : "Length (ft)"
    this.widthLabelTarget.textContent = metric ? "Width (m)" : "Width (ft)"
    this.rollWidthLabelTarget.textContent = metric ? "Roll width (m)" : "Roll width (ft)"
    this.priceLabelTarget.textContent = metric ? "Price per m² ($, optional)" : "Price per sq yd ($, optional)"
    this.sqydHeadingTarget.textContent = metric ? "Square meters" : "Square yards"
    this.linearHeadingTarget.textContent = metric ? "Linear m / roll" : "Linear ft / roll"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
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

    // Math is in imperial internally; convert metric inputs to ft before computing.
    const lengthFt = metric ? length / FT_TO_M : length
    const widthFt = metric ? width / FT_TO_M : width
    const rollWidthFt = metric ? rollWidth / FT_TO_M : rollWidth

    const areaSqft = lengthFt * widthFt
    const withWasteSqft = areaSqft * (1 + waste / 100)
    const sqyd = withWasteSqft / SQFT_PER_SQYD
    const linearFt = withWasteSqft / rollWidthFt
    const needsSeam = Math.min(lengthFt, widthFt) > rollWidthFt

    if (metric) {
      const areaM2 = areaSqft * SQFT_TO_SQM
      const withWasteM2 = withWasteSqft * SQFT_TO_SQM
      const linearM = linearFt * FT_TO_M
      this.resultAreaTarget.textContent = `${areaM2.toFixed(2)} m²`
      this.resultWithWasteTarget.textContent = `${withWasteM2.toFixed(2)} m²`
      this.resultSqydTarget.textContent = `${withWasteM2.toFixed(2)} m²`
      this.resultLinearTarget.textContent = `${linearM.toFixed(2)} m`
      // price is per m² in metric mode
      if (Number.isFinite(price) && price > 0) {
        this.resultCostTarget.textContent = `$${(withWasteM2 * price).toFixed(2)}`
      } else {
        this.resultCostTarget.textContent = "—"
      }
    } else {
      this.resultAreaTarget.textContent = `${areaSqft.toFixed(1)} sq ft`
      this.resultWithWasteTarget.textContent = `${withWasteSqft.toFixed(1)} sq ft`
      this.resultSqydTarget.textContent = `${sqyd.toFixed(2)} sq yd`
      this.resultLinearTarget.textContent = `${linearFt.toFixed(1)} lin ft`
      if (Number.isFinite(price) && price > 0) {
        this.resultCostTarget.textContent = `$${(sqyd * price).toFixed(2)}`
      } else {
        this.resultCostTarget.textContent = "—"
      }
    }
    this.resultSeamTarget.textContent = needsSeam ? "Yes — seam required" : "No seam needed"
  }

  clear() {
    ["resultArea", "resultWithWaste", "resultSqyd", "resultLinear", "resultSeam", "resultCost"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
  }

  copy() {
    const text = `Carpet needed:\nArea: ${this.resultAreaTarget.textContent}\nWith waste: ${this.resultWithWasteTarget.textContent}\n${this.sqydHeadingTarget.textContent}: ${this.resultSqydTarget.textContent}\n${this.linearHeadingTarget.textContent}: ${this.resultLinearTarget.textContent}\nSeam: ${this.resultSeamTarget.textContent}\nCost: ${this.resultCostTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
