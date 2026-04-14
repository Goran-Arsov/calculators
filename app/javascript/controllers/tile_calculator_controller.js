import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM, IN_TO_CM, LB_TO_KG } from "utils/units"

const ADHESIVE_SQFT_PER_BAG = 60

export default class extends Controller {
  static targets = [
    "area", "tileLength", "tileWidth", "groutWidth", "waste",
    "unitSystem", "areaLabel", "tileLengthLabel", "tileWidthLabel", "groutLabel",
    "groutHeading",
    "resultAreaWaste", "resultTiles", "resultGrout", "resultAdhesive"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el, factor) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * factor : n / factor).toFixed(3)
    }
    convert(this.areaTarget, SQFT_TO_SQM)
    convert(this.tileLengthTarget, IN_TO_CM)
    convert(this.tileWidthTarget, IN_TO_CM)
    convert(this.groutWidthTarget, IN_TO_CM)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.areaLabelTarget.textContent = metric ? "Area (m²)" : "Area (sq ft)"
    this.tileLengthLabelTarget.textContent = metric ? "Tile Length (cm)" : "Tile Length (inches)"
    this.tileWidthLabelTarget.textContent = metric ? "Tile Width (cm)" : "Tile Width (inches)"
    this.groutLabelTarget.textContent = metric ? "Grout Width (cm)" : "Grout Width (inches)"
    this.groutHeadingTarget.textContent = "Grout"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const rawArea = parseFloat(this.areaTarget.value) || 0
    const rawTileLen = parseFloat(this.tileLengthTarget.value) || 0
    const rawTileWid = parseFloat(this.tileWidthTarget.value) || 0
    const rawGrout = parseFloat(this.groutWidthTarget.value) || (metric ? 0.3 : 0.125)
    const waste = parseFloat(this.wasteTarget.value) || 10

    if (rawArea <= 0 || rawTileLen <= 0 || rawTileWid <= 0) {
      this.clearResults()
      return
    }

    // Canonical: sqft and inches
    const area = metric ? rawArea / SQFT_TO_SQM : rawArea
    const tileLength = metric ? rawTileLen / IN_TO_CM : rawTileLen
    const tileWidth = metric ? rawTileWid / IN_TO_CM : rawTileWid
    const groutWidth = metric ? rawGrout / IN_TO_CM : rawGrout

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

    if (metric) {
      const areaWithWasteM2 = areaWithWaste * SQFT_TO_SQM
      const groutKg = (groutLbs * LB_TO_KG).toFixed(1)
      this.resultAreaWasteTarget.textContent = `${this.fmt(areaWithWasteM2)} m²`
      this.resultGroutTarget.textContent = `${groutKg} kg`
    } else {
      this.resultAreaWasteTarget.textContent = `${this.fmt(areaWithWaste)} sq ft`
      this.resultGroutTarget.textContent = `${groutLbs} lbs`
    }
    this.resultTilesTarget.textContent = tilesNeeded
    this.resultAdhesiveTarget.textContent = `${adhesiveBags} bags`
  }

  clearResults() {
    const metric = this.unitSystemTarget.value === "metric"
    this.resultAreaWasteTarget.textContent = metric ? "0 m²" : "0 sq ft"
    this.resultTilesTarget.textContent = "0"
    this.resultGroutTarget.textContent = metric ? "0 kg" : "0 lbs"
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
