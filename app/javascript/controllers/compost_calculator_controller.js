import { Controller } from "@hotwired/stimulus"

const CUBIC_FEET_PER_YARD = 27.0
const BAG_CUBIC_FEET = 1.0
const POUNDS_PER_CUBIC_FOOT = 45.0

export default class extends Controller {
  static targets = ["length", "width", "depth", "resultArea", "resultCubicFeet", "resultCubicYards", "resultPounds", "resultBags"]

  connect() { this.calculate() }

  calculate() {
    const length = parseFloat(this.lengthTarget.value)
    const width = parseFloat(this.widthTarget.value)
    const depth = parseFloat(this.depthTarget.value)

    if (!Number.isFinite(length) || length <= 0 ||
        !Number.isFinite(width) || width <= 0 ||
        !Number.isFinite(depth) || depth <= 0) {
      this.clear()
      return
    }

    const area = length * width
    const cubicFeet = area * (depth / 12.0)
    const cubicYards = cubicFeet / CUBIC_FEET_PER_YARD
    const pounds = cubicFeet * POUNDS_PER_CUBIC_FOOT
    const bags = Math.ceil(cubicFeet / BAG_CUBIC_FEET)

    this.resultAreaTarget.textContent = `${area.toFixed(1)} sq ft`
    this.resultCubicFeetTarget.textContent = `${cubicFeet.toFixed(2)} cu ft`
    this.resultCubicYardsTarget.textContent = `${cubicYards.toFixed(2)} cu yd`
    this.resultPoundsTarget.textContent = `${Math.round(pounds)} lb`
    this.resultBagsTarget.textContent = `${bags}`
  }

  clear() {
    this.resultAreaTarget.textContent = "—"
    this.resultCubicFeetTarget.textContent = "—"
    this.resultCubicYardsTarget.textContent = "—"
    this.resultPoundsTarget.textContent = "—"
    this.resultBagsTarget.textContent = "—"
  }

  copy() {
    const text = `Compost needed:\nArea: ${this.resultAreaTarget.textContent}\nCubic feet: ${this.resultCubicFeetTarget.textContent}\nCubic yards: ${this.resultCubicYardsTarget.textContent}\nPounds: ${this.resultPoundsTarget.textContent}\n1 cu ft bags: ${this.resultBagsTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
