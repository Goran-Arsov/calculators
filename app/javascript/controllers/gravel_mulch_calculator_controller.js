import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["length", "width", "depth", "resultArea", "resultCubicYards", "resultTons"]

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const depth = parseFloat(this.depthTarget.value) || 0

    const area = length * width
    const cubicYards = (length * width * depth) / 324
    const tons = cubicYards * 1.4

    this.resultAreaTarget.textContent = `${this.fmt(area)} sq ft`
    this.resultCubicYardsTarget.textContent = this.fmt(cubicYards)
    this.resultTonsTarget.textContent = this.fmt(tons)
  }

  copy() {
    const area = this.resultAreaTarget.textContent
    const cubicYards = this.resultCubicYardsTarget.textContent
    const tons = this.resultTonsTarget.textContent
    const text = `Gravel & Mulch Estimate:\nArea: ${area}\nCubic Yards: ${cubicYards}\nTons (Gravel): ${tons}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
