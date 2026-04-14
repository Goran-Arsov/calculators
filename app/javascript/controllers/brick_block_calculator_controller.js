import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, SQFT_TO_SQM } from "utils/units"

const UNIT_TYPES = {
  standard_brick: { length: 8.0, height: 2.25, mortar: 0.375, label: "Standard Brick", isCmu: false },
  modular_brick: { length: 7.625, height: 2.25, mortar: 0.375, label: "Modular Brick", isCmu: false },
  king_brick: { length: 9.625, height: 2.75, mortar: 0.375, label: "King Size Brick", isCmu: false },
  cmu_8: { length: 16.0, height: 8.0, mortar: 0.375, label: "CMU Block 8\"", isCmu: true },
  cmu_12: { length: 16.0, height: 8.0, mortar: 0.375, label: "CMU Block 12\"", isCmu: true }
}

const WASTE_FACTOR = 1.10

export default class extends Controller {
  static targets = ["wallLength", "wallHeight", "unitType", "openings",
    "unitSystem", "wallLengthLabel", "wallHeightLabel", "openingsLabel", "unitsPerAreaHeading",
    "resultGrossArea", "resultNetArea", "resultUnitsPerSqft",
    "resultUnitsNeeded", "resultWasteUnits", "resultMortarBags"]

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
    convert(this.openingsTarget, SQFT_TO_SQM)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.wallLengthLabelTarget.textContent = metric ? "Wall Length (m)" : "Wall Length (ft)"
    this.wallHeightLabelTarget.textContent = metric ? "Wall Height (m)" : "Wall Height (ft)"
    this.openingsLabelTarget.textContent = metric ? "Openings (m²)" : "Openings (sq ft)"
    this.unitsPerAreaHeadingTarget.textContent = metric ? "Units Per m²" : "Units Per Sq Ft"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const wallLengthInput = parseFloat(this.wallLengthTarget.value) || 0
    const wallHeightInput = parseFloat(this.wallHeightTarget.value) || 0
    const unitKey = this.unitTypeTarget.value || "standard_brick"
    const openingsInput = parseFloat(this.openingsTarget.value) || 0

    if (wallLengthInput <= 0 || wallHeightInput <= 0 || !UNIT_TYPES[unitKey]) {
      this.clearResults()
      return
    }

    // Convert metric inputs to imperial for internal math.
    const wallLength = metric ? wallLengthInput / FT_TO_M : wallLengthInput
    const wallHeight = metric ? wallHeightInput / FT_TO_M : wallHeightInput
    const openings = metric ? openingsInput / SQFT_TO_SQM : openingsInput

    const unit = UNIT_TYPES[unitKey]
    const grossArea = wallLength * wallHeight
    let netArea = grossArea - openings
    if (netArea < 0) netArea = 0

    const unitWithMortarLength = unit.length + unit.mortar
    const unitWithMortarHeight = unit.height + unit.mortar
    const unitsPerSqft = 144 / (unitWithMortarLength * unitWithMortarHeight)

    const unitsNeededRaw = Math.ceil(netArea * unitsPerSqft)
    const unitsNeeded = Math.ceil(unitsNeededRaw * WASTE_FACTOR)
    const wasteUnits = unitsNeeded - unitsNeededRaw

    let mortarBags
    if (unit.isCmu) {
      mortarBags = Math.ceil(netArea / 35)
    } else {
      mortarBags = Math.ceil(unitsNeeded / 140)
    }

    if (metric) {
      const grossM2 = grossArea * SQFT_TO_SQM
      const netM2 = netArea * SQFT_TO_SQM
      const unitsPerM2 = unitsPerSqft / SQFT_TO_SQM
      this.resultGrossAreaTarget.textContent = `${grossM2.toFixed(2)} m\u00B2`
      this.resultNetAreaTarget.textContent = `${netM2.toFixed(2)} m\u00B2`
      this.resultUnitsPerSqftTarget.textContent = unitsPerM2.toFixed(2)
    } else {
      this.resultGrossAreaTarget.textContent = `${grossArea.toFixed(1)} ft\u00B2`
      this.resultNetAreaTarget.textContent = `${netArea.toFixed(1)} ft\u00B2`
      this.resultUnitsPerSqftTarget.textContent = unitsPerSqft.toFixed(2)
    }
    this.resultUnitsNeededTarget.textContent = unitsNeeded.toLocaleString()
    this.resultWasteUnitsTarget.textContent = wasteUnits.toLocaleString()
    this.resultMortarBagsTarget.textContent = mortarBags
  }

  clearResults() {
    const metric = this.unitSystemTarget.value === "metric"
    const unit = metric ? "m\u00B2" : "ft\u00B2"
    this.resultGrossAreaTarget.textContent = `0 ${unit}`
    this.resultNetAreaTarget.textContent = `0 ${unit}`
    this.resultUnitsPerSqftTarget.textContent = "0"
    this.resultUnitsNeededTarget.textContent = "0"
    this.resultWasteUnitsTarget.textContent = "0"
    this.resultMortarBagsTarget.textContent = "0"
  }

  copy() {
    const gross = this.resultGrossAreaTarget.textContent
    const net = this.resultNetAreaTarget.textContent
    const units = this.resultUnitsNeededTarget.textContent
    const mortar = this.resultMortarBagsTarget.textContent
    const text = `Brick & Block Estimate:\nGross Area: ${gross}\nNet Area: ${net}\nUnits Needed: ${units}\nMortar Bags: ${mortar}`
    navigator.clipboard.writeText(text)
  }
}
