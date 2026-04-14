import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, SQFT_TO_SQM } from "utils/units"

const SQUARE_SQFT = 100
const BUNDLES_PER_SQUARE = 3
const FELT_ROLL_SQFT = 400
const NAILS_PER_SQUARE = 320
const NAILS_PER_BOX = 250

const PITCH_MULTIPLIERS = {
  0: 1.000, 1: 1.003, 2: 1.014, 3: 1.031, 4: 1.054, 5: 1.083,
  6: 1.118, 7: 1.158, 8: 1.202, 9: 1.250, 10: 1.302, 11: 1.357, 12: 1.414
}

export default class extends Controller {
  static targets = [
    "length", "width", "pitch", "waste",
    "unitSystem", "lengthLabel", "widthLabel", "squaresHeading",
    "resultFootprint", "resultRoofArea", "resultAreaWaste",
    "resultSquares", "resultBundles", "resultFelt", "resultNailBoxes"
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
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Roof Length (m)" : "Roof Length (ft)"
    this.widthLabelTarget.textContent = metric ? "Roof Width (m)" : "Roof Width (ft)"
    this.squaresHeadingTarget.textContent = metric ? "Squares (100 sq ft units)" : "Squares"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const pitch = parseInt(this.pitchTarget.value) || 0
    const waste = parseFloat(this.wasteTarget.value) || 10

    if (length <= 0 || width <= 0) {
      this.clearResults()
      return
    }

    // Convert metric to imperial internally
    const lengthFt = metric ? length / FT_TO_M : length
    const widthFt = metric ? width / FT_TO_M : width

    const footprintSqft = lengthFt * widthFt
    const multiplier = PITCH_MULTIPLIERS[pitch] || Math.sqrt(1 + Math.pow(pitch / 12, 2))
    const roofAreaSqft = footprintSqft * multiplier
    const areaWithWasteSqft = roofAreaSqft * (1 + waste / 100)

    const squares = Math.ceil(areaWithWasteSqft / SQUARE_SQFT)
    const bundles = squares * BUNDLES_PER_SQUARE
    const feltRolls = Math.ceil(areaWithWasteSqft / FELT_ROLL_SQFT)
    const nailBoxes = Math.ceil((squares * NAILS_PER_SQUARE) / NAILS_PER_BOX)

    if (metric) {
      const footprintM2 = footprintSqft * SQFT_TO_SQM
      const roofAreaM2 = roofAreaSqft * SQFT_TO_SQM
      const areaWithWasteM2 = areaWithWasteSqft * SQFT_TO_SQM
      this.resultFootprintTarget.textContent = `${this.fmt(footprintM2)} m²`
      this.resultRoofAreaTarget.textContent = `${this.fmt(roofAreaM2)} m²`
      this.resultAreaWasteTarget.textContent = `${this.fmt(areaWithWasteM2)} m²`
    } else {
      this.resultFootprintTarget.textContent = `${this.fmt(footprintSqft)} sq ft`
      this.resultRoofAreaTarget.textContent = `${this.fmt(roofAreaSqft)} sq ft`
      this.resultAreaWasteTarget.textContent = `${this.fmt(areaWithWasteSqft)} sq ft`
    }

    this.resultSquaresTarget.textContent = squares
    this.resultBundlesTarget.textContent = bundles
    this.resultFeltTarget.textContent = feltRolls
    this.resultNailBoxesTarget.textContent = nailBoxes
  }

  clearResults() {
    const metric = this.unitSystemTarget.value === "metric"
    const unit = metric ? "m²" : "sq ft"
    this.resultFootprintTarget.textContent = `0 ${unit}`
    this.resultRoofAreaTarget.textContent = `0 ${unit}`
    this.resultAreaWasteTarget.textContent = `0 ${unit}`
    this.resultSquaresTarget.textContent = "0"
    this.resultBundlesTarget.textContent = "0"
    this.resultFeltTarget.textContent = "0"
    this.resultNailBoxesTarget.textContent = "0"
  }

  copy() {
    const text = `Roofing Estimate:\nFootprint Area: ${this.resultFootprintTarget.textContent}\nRoof Area: ${this.resultRoofAreaTarget.textContent}\nArea with Waste: ${this.resultAreaWasteTarget.textContent}\n${this.squaresHeadingTarget.textContent}: ${this.resultSquaresTarget.textContent}\nBundles: ${this.resultBundlesTarget.textContent}\nFelt Rolls: ${this.resultFeltTarget.textContent}\nNail Boxes: ${this.resultNailBoxesTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
