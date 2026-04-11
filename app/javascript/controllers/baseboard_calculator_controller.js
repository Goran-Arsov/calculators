import { Controller } from "@hotwired/stimulus"

const DEFAULT_DOOR_FT = 3.0

export default class extends Controller {
  static targets = ["length", "width", "doors", "waste", "stick", "price",
                    "resultPerimeter", "resultDoors", "resultLf", "resultWithWaste", "resultSticks", "resultCost"]

  connect() { this.calculate() }

  calculate() {
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

    const perimeter = 2 * (length + width)
    const doorDeduction = doors * DEFAULT_DOOR_FT
    const lf = Math.max(perimeter - doorDeduction, 0)
    const withWaste = lf * (1 + waste / 100)
    const sticks = Math.ceil(withWaste / stick)

    this.resultPerimeterTarget.textContent = `${perimeter.toFixed(1)} ft`
    this.resultDoorsTarget.textContent = `${doorDeduction.toFixed(1)} ft`
    this.resultLfTarget.textContent = `${lf.toFixed(1)} ft`
    this.resultWithWasteTarget.textContent = `${withWaste.toFixed(1)} ft`
    this.resultSticksTarget.textContent = `${sticks}`
    if (Number.isFinite(price) && price > 0) {
      this.resultCostTarget.textContent = `$${(withWaste * price).toFixed(2)}`
    } else {
      this.resultCostTarget.textContent = "—"
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
