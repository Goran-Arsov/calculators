import { Controller } from "@hotwired/stimulus"

const GALLONS_PER_CUBIC_FOOT = 7.48052
const LITERS_PER_GALLON = 3.78541

const FACTORS = {
  rectangular: 1.0,
  round: Math.PI / 4.0,
  oval: Math.PI / 4.0,
  kidney: 0.85
}

export default class extends Controller {
  static targets = ["shape", "length", "width", "depth",
                    "resultSurface", "resultCubicFeet", "resultGallons", "resultLiters"]

  connect() { this.calculate() }

  calculate() {
    const shape = this.shapeTarget.value
    const length = parseFloat(this.lengthTarget.value)
    const width = parseFloat(this.widthTarget.value)
    const depth = parseFloat(this.depthTarget.value)
    const factor = FACTORS[shape]

    if (!factor || ![length, width, depth].every(n => Number.isFinite(n) && n > 0)) {
      this.clear()
      return
    }

    const surface = length * width * factor
    const cubicFeet = surface * depth
    const gallons = cubicFeet * GALLONS_PER_CUBIC_FOOT
    const liters = gallons * LITERS_PER_GALLON

    this.resultSurfaceTarget.textContent = `${surface.toFixed(1)} sq ft`
    this.resultCubicFeetTarget.textContent = `${cubicFeet.toFixed(1)} cu ft`
    this.resultGallonsTarget.textContent = `${Math.round(gallons).toLocaleString()} gal`
    this.resultLitersTarget.textContent = `${Math.round(liters).toLocaleString()} L`
  }

  clear() {
    ["resultSurface", "resultCubicFeet", "resultGallons", "resultLiters"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
  }

  copy() {
    const text = `Pool volume:\nSurface area: ${this.resultSurfaceTarget.textContent}\nCubic feet: ${this.resultCubicFeetTarget.textContent}\nGallons: ${this.resultGallonsTarget.textContent}\nLiters: ${this.resultLitersTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
