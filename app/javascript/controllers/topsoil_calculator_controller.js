import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM, CUFT_TO_CUM, LB_TO_KG } from "../utils/units"

const CUBIC_FEET_PER_YARD = 27.0
const POUNDS_PER_CUBIC_FOOT = 75.0
const BAG_CUBIC_FEET_40LB = 0.5

export default class extends Controller {
  static targets = ["length", "width", "depth", "resultCubicYards", "resultCubicFeet", "resultPounds", "resultBags", "resultArea"]

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
    const bags = Math.ceil(cubicFeet / BAG_CUBIC_FEET_40LB)
    const cubicMeters = cubicFeet * CUFT_TO_CUM

    this.resultAreaTarget.textContent = `${area.toFixed(1)} sq ft (${(area * SQFT_TO_SQM).toFixed(2)} m²)`
    this.resultCubicFeetTarget.textContent = `${cubicFeet.toFixed(2)} cu ft (${cubicMeters.toFixed(2)} m³)`
    this.resultCubicYardsTarget.textContent = `${cubicYards.toFixed(2)} cu yd (${cubicMeters.toFixed(2)} m³)`
    this.resultPoundsTarget.textContent = `${Math.round(pounds)} lb (${Math.round(pounds * LB_TO_KG)} kg)`
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
    const text = `Topsoil needed:\nArea: ${this.resultAreaTarget.textContent}\nCubic feet: ${this.resultCubicFeetTarget.textContent}\nCubic yards: ${this.resultCubicYardsTarget.textContent}\nPounds: ${this.resultPoundsTarget.textContent}\n40 lb bags: ${this.resultBagsTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
