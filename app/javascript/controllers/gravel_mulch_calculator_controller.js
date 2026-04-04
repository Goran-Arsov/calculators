import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["length", "width", "depth", "resultArea", "resultCubicYards", "resultTons"]

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const depth = parseFloat(this.depthTarget.value) || 0

    const area = length * width
    const cubicYards = length * width * (depth / 12) / 27
    const tons = cubicYards * 1.4

    this.resultAreaTarget.textContent = this.fmt(area)
    this.resultCubicYardsTarget.textContent = this.fmt(cubicYards)
    this.resultTonsTarget.textContent = this.fmt(tons)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
