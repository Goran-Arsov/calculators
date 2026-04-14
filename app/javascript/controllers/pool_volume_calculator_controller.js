import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, SQFT_TO_SQM, CUFT_TO_CUM } from "utils/units"

const GALLONS_PER_CUBIC_FOOT = 7.48052
const LITERS_PER_GALLON = 3.78541

const FACTORS = {
  rectangular: 1.0,
  round: Math.PI / 4.0,
  oval: Math.PI / 4.0,
  kidney: 0.85
}

export default class extends Controller {
  static targets = [
    "shape", "length", "width", "depth",
    "unitSystem", "lengthLabel", "widthLabel", "depthLabel",
    "surfaceHeading", "volumeHeading", "primaryHeading", "secondaryHeading",
    "resultSurface", "resultCubicFeet", "resultGallons", "resultLiters"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el, factor) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * factor : n / factor).toFixed(2)
    }
    convert(this.lengthTarget, FT_TO_M)
    convert(this.widthTarget, FT_TO_M)
    convert(this.depthTarget, FT_TO_M)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Length / diameter (m)" : "Length / diameter (ft)"
    this.widthLabelTarget.textContent = metric ? "Width (m)" : "Width (ft)"
    this.depthLabelTarget.textContent = metric ? "Average depth (m)" : "Average depth (ft)"
    this.surfaceHeadingTarget.textContent = metric ? "Surface area" : "Surface area"
    this.volumeHeadingTarget.textContent = metric ? "Cubic meters" : "Cubic feet"
    this.primaryHeadingTarget.textContent = metric ? "Liters" : "Gallons"
    this.secondaryHeadingTarget.textContent = metric ? "Gallons" : "Liters"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const shape = this.shapeTarget.value
    const length = parseFloat(this.lengthTarget.value)
    const width = parseFloat(this.widthTarget.value)
    const depth = parseFloat(this.depthTarget.value)
    const factor = FACTORS[shape]

    if (!factor || ![length, width, depth].every(n => Number.isFinite(n) && n > 0)) {
      this.clear()
      return
    }

    // Convert to imperial internally
    const lengthFt = metric ? length / FT_TO_M : length
    const widthFt = metric ? width / FT_TO_M : width
    const depthFt = metric ? depth / FT_TO_M : depth

    const surfaceSqft = lengthFt * widthFt * factor
    const cubicFeet = surfaceSqft * depthFt
    const gallons = cubicFeet * GALLONS_PER_CUBIC_FOOT
    const liters = gallons * LITERS_PER_GALLON

    if (metric) {
      const surfaceM2 = surfaceSqft * SQFT_TO_SQM
      const cubicM = cubicFeet * CUFT_TO_CUM
      this.resultSurfaceTarget.textContent = `${surfaceM2.toFixed(2)} m²`
      this.resultCubicFeetTarget.textContent = `${cubicM.toFixed(2)} m³`
      this.resultGallonsTarget.textContent = `${Math.round(liters).toLocaleString()} L`
      this.resultLitersTarget.textContent = `${Math.round(gallons).toLocaleString()} gal`
    } else {
      this.resultSurfaceTarget.textContent = `${surfaceSqft.toFixed(1)} sq ft`
      this.resultCubicFeetTarget.textContent = `${cubicFeet.toFixed(1)} cu ft`
      this.resultGallonsTarget.textContent = `${Math.round(gallons).toLocaleString()} gal`
      this.resultLitersTarget.textContent = `${Math.round(liters).toLocaleString()} L`
    }
  }

  clear() {
    ["resultSurface", "resultCubicFeet", "resultGallons", "resultLiters"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
  }

  copy() {
    const text = `Pool volume:\n${this.surfaceHeadingTarget.textContent}: ${this.resultSurfaceTarget.textContent}\n${this.volumeHeadingTarget.textContent}: ${this.resultCubicFeetTarget.textContent}\n${this.primaryHeadingTarget.textContent}: ${this.resultGallonsTarget.textContent}\n${this.secondaryHeadingTarget.textContent}: ${this.resultLitersTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
