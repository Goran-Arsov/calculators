import { Controller } from "@hotwired/stimulus"

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
    "resultGrossArea", "resultNetArea", "resultUnitsPerSqft",
    "resultUnitsNeeded", "resultWasteUnits", "resultMortarBags"]

  calculate() {
    const wallLength = parseFloat(this.wallLengthTarget.value) || 0
    const wallHeight = parseFloat(this.wallHeightTarget.value) || 0
    const unitKey = this.unitTypeTarget.value || "standard_brick"
    const openings = parseFloat(this.openingsTarget.value) || 0

    if (wallLength <= 0 || wallHeight <= 0 || !UNIT_TYPES[unitKey]) {
      this.clearResults()
      return
    }

    const unit = UNIT_TYPES[unitKey]
    const grossArea = wallLength * wallHeight
    let netArea = grossArea - openings
    if (netArea < 0) netArea = 0

    const unitWithMortarLength = unit.length + unit.mortar
    const unitWithMortarHeight = unit.height + unit.mortar
    const unitsPerSqft = (144 / (unitWithMortarLength * unitWithMortarHeight)).toFixed(2)

    const unitsNeededRaw = Math.ceil(netArea * unitsPerSqft)
    const unitsNeeded = Math.ceil(unitsNeededRaw * WASTE_FACTOR)
    const wasteUnits = unitsNeeded - unitsNeededRaw

    let mortarBags
    if (unit.isCmu) {
      mortarBags = Math.ceil(netArea / 35)
    } else {
      mortarBags = Math.ceil(unitsNeeded / 140)
    }

    this.resultGrossAreaTarget.textContent = `${grossArea.toFixed(1)} ft\u00B2`
    this.resultNetAreaTarget.textContent = `${netArea.toFixed(1)} ft\u00B2`
    this.resultUnitsPerSqftTarget.textContent = unitsPerSqft
    this.resultUnitsNeededTarget.textContent = unitsNeeded.toLocaleString()
    this.resultWasteUnitsTarget.textContent = wasteUnits.toLocaleString()
    this.resultMortarBagsTarget.textContent = mortarBags
  }

  clearResults() {
    this.resultGrossAreaTarget.textContent = "0 ft\u00B2"
    this.resultNetAreaTarget.textContent = "0 ft\u00B2"
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
