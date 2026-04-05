import { Controller } from "@hotwired/stimulus"

const ADHESIVE_SQFT_PER_BAG = 60

export default class extends Controller {
  static targets = [
    "area", "tileLength", "tileWidth", "groutWidth", "waste",
    "resultAreaWaste", "resultTiles", "resultGrout", "resultAdhesive"
  ]

  calculate() {
    const area = parseFloat(this.areaTarget.value) || 0
    const tileLength = parseFloat(this.tileLengthTarget.value) || 0
    const tileWidth = parseFloat(this.tileWidthTarget.value) || 0
    const groutWidth = parseFloat(this.groutWidthTarget.value) || 0.125
    const waste = parseFloat(this.wasteTarget.value) || 10

    if (area <= 0 || tileLength <= 0 || tileWidth <= 0) {
      this.clearResults()
      return
    }

    const areaWithWaste = area * (1 + waste / 100)
    const effectiveLength = tileLength + groutWidth
    const effectiveWidth = tileWidth + groutWidth
    const effectiveAreaSqft = (effectiveLength * effectiveWidth) / 144
    const tilesNeeded = Math.ceil(areaWithWaste / effectiveAreaSqft)

    // Grout estimate
    const groutLinearInPerTile = tileLength + tileWidth
    const totalGroutLinearFt = (tilesNeeded * groutLinearInPerTile) / 12
    const groutDepth = 0.25
    const groutVolumeCuIn = totalGroutLinearFt * 12 * groutWidth * groutDepth
    const groutLbs = Math.max(Math.ceil(groutVolumeCuIn / 13.5), 1)

    // Adhesive
    const adhesiveBags = Math.ceil(areaWithWaste / ADHESIVE_SQFT_PER_BAG)

    this.resultAreaWasteTarget.textContent = `${this.fmt(areaWithWaste)} sq ft`
    this.resultTilesTarget.textContent = tilesNeeded
    this.resultGroutTarget.textContent = `${groutLbs} lbs`
    this.resultAdhesiveTarget.textContent = `${adhesiveBags} bags`
  }

  clearResults() {
    this.resultAreaWasteTarget.textContent = "0 sq ft"
    this.resultTilesTarget.textContent = "0"
    this.resultGroutTarget.textContent = "0 lbs"
    this.resultAdhesiveTarget.textContent = "0 bags"
  }

  copy() {
    const text = `Tile Estimate:\nArea with Waste: ${this.resultAreaWasteTarget.textContent}\nTiles Needed: ${this.resultTilesTarget.textContent}\nGrout: ${this.resultGroutTarget.textContent}\nAdhesive: ${this.resultAdhesiveTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
