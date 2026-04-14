import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, SQFT_TO_SQM } from "utils/units"

const SQFT_PER_SQUARE = 100.0
const WINDOW_SQFT = 15.0
const DOOR_SQFT = 21.0

export default class extends Controller {
  static targets = [
    "wallLength", "wallHeight", "gableLength", "gableHeight",
    "windows", "doors", "waste",
    "unitSystem", "wallLengthLabel", "wallHeightLabel", "gableLengthLabel", "gableHeightLabel",
    "squaresHeading",
    "resultWall", "resultGable", "resultGross", "resultOpenings", "resultNet", "resultWithWaste", "resultSquares"
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
    convert(this.wallLengthTarget, FT_TO_M)
    convert(this.wallHeightTarget, FT_TO_M)
    convert(this.gableLengthTarget, FT_TO_M)
    convert(this.gableHeightTarget, FT_TO_M)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.wallLengthLabelTarget.textContent = metric ? "Wall length (m)" : "Wall length (ft)"
    this.wallHeightLabelTarget.textContent = metric ? "Wall height (m)" : "Wall height (ft)"
    this.gableLengthLabelTarget.textContent = metric ? "Gable base (m)" : "Gable base (ft)"
    this.gableHeightLabelTarget.textContent = metric ? "Gable height (m)" : "Gable height (ft)"
    this.squaresHeadingTarget.textContent = metric ? "Squares (100 sq ft each)" : "Squares"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const wallL = parseFloat(this.wallLengthTarget.value)
    const wallH = parseFloat(this.wallHeightTarget.value)
    const gableL = parseFloat(this.gableLengthTarget.value) || 0
    const gableH = parseFloat(this.gableHeightTarget.value) || 0
    const windows = parseInt(this.windowsTarget.value, 10) || 0
    const doors = parseInt(this.doorsTarget.value, 10) || 0
    const waste = parseFloat(this.wasteTarget.value)

    if (![wallL, wallH].every(n => Number.isFinite(n) && n > 0) ||
        !Number.isFinite(waste) || waste < 0) {
      this.clear()
      return
    }

    // Convert metric to imperial internally
    const wallLFt = metric ? wallL / FT_TO_M : wallL
    const wallHFt = metric ? wallH / FT_TO_M : wallH
    const gableLFt = metric ? gableL / FT_TO_M : gableL
    const gableHFt = metric ? gableH / FT_TO_M : gableH

    const wallArea = wallLFt * wallHFt
    const gableArea = 0.5 * gableLFt * gableHFt
    const gross = wallArea + gableArea
    const openings = windows * WINDOW_SQFT + doors * DOOR_SQFT
    const net = Math.max(gross - openings, 0)
    const withWaste = net * (1 + waste / 100)
    const squares = withWaste / SQFT_PER_SQUARE

    if (metric) {
      const conv = (v) => (v * SQFT_TO_SQM).toFixed(2)
      this.resultWallTarget.textContent = `${conv(wallArea)} m²`
      this.resultGableTarget.textContent = `${conv(gableArea)} m²`
      this.resultGrossTarget.textContent = `${conv(gross)} m²`
      this.resultOpeningsTarget.textContent = `${conv(openings)} m²`
      this.resultNetTarget.textContent = `${conv(net)} m²`
      this.resultWithWasteTarget.textContent = `${conv(withWaste)} m²`
      this.resultSquaresTarget.textContent = `${squares.toFixed(2)}`
    } else {
      this.resultWallTarget.textContent = `${wallArea.toFixed(1)} sq ft`
      this.resultGableTarget.textContent = `${gableArea.toFixed(1)} sq ft`
      this.resultGrossTarget.textContent = `${gross.toFixed(1)} sq ft`
      this.resultOpeningsTarget.textContent = `${openings.toFixed(1)} sq ft`
      this.resultNetTarget.textContent = `${net.toFixed(1)} sq ft`
      this.resultWithWasteTarget.textContent = `${withWaste.toFixed(1)} sq ft`
      this.resultSquaresTarget.textContent = `${squares.toFixed(2)}`
    }
  }

  clear() {
    ["resultWall", "resultGable", "resultGross", "resultOpenings", "resultNet", "resultWithWaste", "resultSquares"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
  }

  copy() {
    const text = `Siding:\nGross wall area: ${this.resultGrossTarget.textContent}\nNet (after openings): ${this.resultNetTarget.textContent}\nWith waste: ${this.resultWithWasteTarget.textContent}\n${this.squaresHeadingTarget.textContent}: ${this.resultSquaresTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
