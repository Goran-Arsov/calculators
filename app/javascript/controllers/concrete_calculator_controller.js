import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["length", "width", "depth", "resultCubicFt", "resultCubicYards", "resultBags60", "resultBags80"]

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const depth = parseFloat(this.depthTarget.value) || 0

    const cubicFt = length * width * (depth / 12)
    const cubicYards = cubicFt / 27
    const bags60 = Math.ceil(cubicYards / 0.0167)
    const bags80 = Math.ceil(cubicYards / 0.022)

    this.resultCubicFtTarget.textContent = this.fmt(cubicFt)
    this.resultCubicYardsTarget.textContent = this.fmt(cubicYards)
    this.resultBags60Target.textContent = bags60
    this.resultBags80Target.textContent = bags80
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
