import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["length", "width", "depth", "resultCubicFeet", "resultCubicYards", "resultBags60", "resultBags80"]

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const depth = parseFloat(this.depthTarget.value) || 0

    const cubicFeet = length * width * (depth / 12)
    const cubicYards = cubicFeet / 27
    const bags60 = cubicFeet > 0 ? Math.ceil(cubicFeet / 0.45) : 0
    const bags80 = cubicFeet > 0 ? Math.ceil(cubicFeet / 0.6) : 0

    this.resultCubicFeetTarget.textContent = this.fmt(cubicFeet)
    this.resultCubicYardsTarget.textContent = this.fmt(cubicYards)
    this.resultBags60Target.textContent = bags60
    this.resultBags80Target.textContent = bags80
  }

  copy() {
    const cubicFeet = this.resultCubicFeetTarget.textContent
    const cubicYards = this.resultCubicYardsTarget.textContent
    const bags60 = this.resultBags60Target.textContent
    const bags80 = this.resultBags80Target.textContent
    const text = `Concrete Estimate:\nCubic Feet: ${cubicFeet}\nCubic Yards: ${cubicYards}\n60 lb Bags: ${bags60}\n80 lb Bags: ${bags80}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
