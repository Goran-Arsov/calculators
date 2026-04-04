import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["length", "width", "waste", "resultArea", "resultWithWaste", "resultBoxes"]

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const waste = parseFloat(this.wasteTarget.value) || 10

    const area = length * width
    const withWaste = area * (1 + waste / 100)
    const boxes = Math.ceil(withWaste / 20)

    this.resultAreaTarget.textContent = this.fmt(area)
    this.resultWithWasteTarget.textContent = this.fmt(withWaste)
    this.resultBoxesTarget.textContent = boxes
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
