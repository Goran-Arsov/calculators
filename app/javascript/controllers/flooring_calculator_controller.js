import { Controller } from "@hotwired/stimulus"

const SQ_FT_PER_BOX = 25

export default class extends Controller {
  static targets = ["length", "width", "waste", "resultArea", "resultAreaWaste", "resultBoxes"]

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const waste = parseFloat(this.wasteTarget.value) || 10

    const area = length * width
    const areaWaste = area * (1 + waste / 100)
    const boxes = areaWaste > 0 ? Math.ceil(areaWaste / SQ_FT_PER_BOX) : 0

    this.resultAreaTarget.textContent = `${this.fmt(area)} sq ft`
    this.resultAreaWasteTarget.textContent = `${this.fmt(areaWaste)} sq ft`
    this.resultBoxesTarget.textContent = boxes
  }

  copy() {
    const area = this.resultAreaTarget.textContent
    const areaWaste = this.resultAreaWasteTarget.textContent
    const boxes = this.resultBoxesTarget.textContent
    const text = `Flooring Estimate:\nArea: ${area}\nArea with Waste: ${areaWaste}\nBoxes Needed: ${boxes}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
