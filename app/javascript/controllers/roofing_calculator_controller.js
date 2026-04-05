import { Controller } from "@hotwired/stimulus"

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
    "resultFootprint", "resultRoofArea", "resultAreaWaste",
    "resultSquares", "resultBundles", "resultFelt", "resultNailBoxes"
  ]

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const pitch = parseInt(this.pitchTarget.value) || 0
    const waste = parseFloat(this.wasteTarget.value) || 10

    if (length <= 0 || width <= 0) {
      this.clearResults()
      return
    }

    const footprint = length * width
    const multiplier = PITCH_MULTIPLIERS[pitch] || Math.sqrt(1 + Math.pow(pitch / 12, 2))
    const roofArea = footprint * multiplier
    const areaWithWaste = roofArea * (1 + waste / 100)

    const squares = Math.ceil(areaWithWaste / SQUARE_SQFT)
    const bundles = squares * BUNDLES_PER_SQUARE
    const feltRolls = Math.ceil(areaWithWaste / FELT_ROLL_SQFT)
    const nailBoxes = Math.ceil((squares * NAILS_PER_SQUARE) / NAILS_PER_BOX)

    this.resultFootprintTarget.textContent = `${this.fmt(footprint)} sq ft`
    this.resultRoofAreaTarget.textContent = `${this.fmt(roofArea)} sq ft`
    this.resultAreaWasteTarget.textContent = `${this.fmt(areaWithWaste)} sq ft`
    this.resultSquaresTarget.textContent = squares
    this.resultBundlesTarget.textContent = bundles
    this.resultFeltTarget.textContent = feltRolls
    this.resultNailBoxesTarget.textContent = nailBoxes
  }

  clearResults() {
    this.resultFootprintTarget.textContent = "0 sq ft"
    this.resultRoofAreaTarget.textContent = "0 sq ft"
    this.resultAreaWasteTarget.textContent = "0 sq ft"
    this.resultSquaresTarget.textContent = "0"
    this.resultBundlesTarget.textContent = "0"
    this.resultFeltTarget.textContent = "0"
    this.resultNailBoxesTarget.textContent = "0"
  }

  copy() {
    const text = `Roofing Estimate:\nFootprint Area: ${this.resultFootprintTarget.textContent}\nRoof Area: ${this.resultRoofAreaTarget.textContent}\nArea with Waste: ${this.resultAreaWasteTarget.textContent}\nSquares: ${this.resultSquaresTarget.textContent}\nBundles: ${this.resultBundlesTarget.textContent}\nFelt Rolls: ${this.resultFeltTarget.textContent}\nNail Boxes: ${this.resultNailBoxesTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
