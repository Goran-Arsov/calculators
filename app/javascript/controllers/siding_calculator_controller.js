import { Controller } from "@hotwired/stimulus"

const SQFT_PER_SQUARE = 100.0
const WINDOW_SQFT = 15.0
const DOOR_SQFT = 21.0

export default class extends Controller {
  static targets = ["wallLength", "wallHeight", "gableLength", "gableHeight",
                    "windows", "doors", "waste",
                    "resultWall", "resultGable", "resultGross", "resultOpenings", "resultNet", "resultWithWaste", "resultSquares"]

  connect() { this.calculate() }

  calculate() {
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

    const wallArea = wallL * wallH
    const gableArea = 0.5 * gableL * gableH
    const gross = wallArea + gableArea
    const openings = windows * WINDOW_SQFT + doors * DOOR_SQFT
    const net = Math.max(gross - openings, 0)
    const withWaste = net * (1 + waste / 100)
    const squares = withWaste / SQFT_PER_SQUARE

    this.resultWallTarget.textContent = `${wallArea.toFixed(1)} sq ft`
    this.resultGableTarget.textContent = `${gableArea.toFixed(1)} sq ft`
    this.resultGrossTarget.textContent = `${gross.toFixed(1)} sq ft`
    this.resultOpeningsTarget.textContent = `${openings.toFixed(1)} sq ft`
    this.resultNetTarget.textContent = `${net.toFixed(1)} sq ft`
    this.resultWithWasteTarget.textContent = `${withWaste.toFixed(1)} sq ft`
    this.resultSquaresTarget.textContent = `${squares.toFixed(2)}`
  }

  clear() {
    ["resultWall", "resultGable", "resultGross", "resultOpenings", "resultNet", "resultWithWaste", "resultSquares"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
  }

  copy() {
    const text = `Siding:\nGross wall area: ${this.resultGrossTarget.textContent}\nNet (after openings): ${this.resultNetTarget.textContent}\nWith waste: ${this.resultWithWasteTarget.textContent}\nSquares: ${this.resultSquaresTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
