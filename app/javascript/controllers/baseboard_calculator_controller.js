import { Controller } from "@hotwired/stimulus"
import { FT_TO_M } from "utils/units"

const DEFAULT_DOOR_FT = 3.0

export default class extends Controller {
  static targets = ["length", "width", "doors", "waste", "stick", "price",
                    "unitSystem", "lengthLabel", "widthLabel", "stickLabel", "priceLabel",
                    "resultPerimeter", "resultDoors", "resultLf", "resultWithWaste", "resultSticks", "resultCost"]

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
    convert(this.stickTarget, FT_TO_M)
    // price per linear foot → price per meter (÷FT_TO_M)
    convert(this.priceTarget, 1 / FT_TO_M)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Length (m)" : "Length (ft)"
    this.widthLabelTarget.textContent = metric ? "Width (m)" : "Width (ft)"
    this.stickLabelTarget.textContent = metric ? "Stick length (m)" : "Stick length (ft)"
    this.priceLabelTarget.textContent = metric ? "Price per meter ($, optional)" : "Price per linear foot ($, optional)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const length = parseFloat(this.lengthTarget.value)
    const width = parseFloat(this.widthTarget.value)
    const doors = parseInt(this.doorsTarget.value, 10)
    const waste = parseFloat(this.wasteTarget.value)
    const stick = parseFloat(this.stickTarget.value)
    const price = parseFloat(this.priceTarget.value)

    if (![length, width, stick].every(n => Number.isFinite(n) && n > 0) ||
        !Number.isFinite(doors) || doors < 0 ||
        !Number.isFinite(waste) || waste < 0) {
      this.clear()
      return
    }

    // Math is in imperial internally.
    const lengthFt = metric ? length / FT_TO_M : length
    const widthFt = metric ? width / FT_TO_M : width
    const stickFt = metric ? stick / FT_TO_M : stick

    const perimeterFt = 2 * (lengthFt + widthFt)
    const doorDeductionFt = doors * DEFAULT_DOOR_FT
    const lfFt = Math.max(perimeterFt - doorDeductionFt, 0)
    const withWasteFt = lfFt * (1 + waste / 100)
    const sticks = Math.ceil(withWasteFt / stickFt)

    if (metric) {
      const perimeterM = perimeterFt * FT_TO_M
      const doorDeductionM = doorDeductionFt * FT_TO_M
      const lfM = lfFt * FT_TO_M
      const withWasteM = withWasteFt * FT_TO_M
      this.resultPerimeterTarget.textContent = `${perimeterM.toFixed(2)} m`
      this.resultDoorsTarget.textContent = `${doorDeductionM.toFixed(2)} m`
      this.resultLfTarget.textContent = `${lfM.toFixed(2)} m`
      this.resultWithWasteTarget.textContent = `${withWasteM.toFixed(2)} m`
      this.resultSticksTarget.textContent = `${sticks}`
      if (Number.isFinite(price) && price > 0) {
        this.resultCostTarget.textContent = `$${(withWasteM * price).toFixed(2)}`
      } else {
        this.resultCostTarget.textContent = "—"
      }
    } else {
      this.resultPerimeterTarget.textContent = `${perimeterFt.toFixed(1)} ft`
      this.resultDoorsTarget.textContent = `${doorDeductionFt.toFixed(1)} ft`
      this.resultLfTarget.textContent = `${lfFt.toFixed(1)} ft`
      this.resultWithWasteTarget.textContent = `${withWasteFt.toFixed(1)} ft`
      this.resultSticksTarget.textContent = `${sticks}`
      if (Number.isFinite(price) && price > 0) {
        this.resultCostTarget.textContent = `$${(withWasteFt * price).toFixed(2)}`
      } else {
        this.resultCostTarget.textContent = "—"
      }
    }
  }

  clear() {
    ["resultPerimeter", "resultDoors", "resultLf", "resultWithWaste", "resultSticks", "resultCost"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
  }

  copy() {
    const text = `Baseboard:\nPerimeter: ${this.resultPerimeterTarget.textContent}\nLinear feet needed: ${this.resultLfTarget.textContent}\nWith waste: ${this.resultWithWasteTarget.textContent}\nSticks: ${this.resultSticksTarget.textContent}\nCost: ${this.resultCostTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
