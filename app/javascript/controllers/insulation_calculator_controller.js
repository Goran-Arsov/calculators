import { Controller } from "@hotwired/stimulus"

const R_VALUE_TABLE = {
  1: { attic: 30, wall: 13, floor: 13 },
  2: { attic: 30, wall: 13, floor: 13 },
  3: { attic: 38, wall: 13, floor: 19 },
  4: { attic: 49, wall: 20, floor: 25 },
  5: { attic: 49, wall: 20, floor: 25 },
  6: { attic: 60, wall: 21, floor: 30 },
  7: { attic: 60, wall: 21, floor: 30 }
}

const R_PER_INCH = {
  fiberglass_batt: 3.2,
  blown_cellulose: 3.7,
  spray_foam: 6.5
}

const COST_PER_SQFT = {
  fiberglass_batt: 0.50,
  blown_cellulose: 0.80,
  spray_foam: 1.50
}

const COVERAGE_PER_UNIT = 40

const UNIT_LABELS = {
  fiberglass_batt: "rolls",
  blown_cellulose: "bags",
  spray_foam: "units"
}

export default class extends Controller {
  static targets = ["areaSqft", "climateZone", "location", "insulationType",
    "resultRValue", "resultThickness", "resultQuantity", "resultCost"]

  calculate() {
    const area = parseFloat(this.areaSqftTarget.value) || 0
    const zone = parseInt(this.climateZoneTarget.value) || 1
    const location = this.locationTarget.value || "attic"
    const type = this.insulationTypeTarget.value || "fiberglass_batt"

    if (area <= 0 || !R_VALUE_TABLE[zone]) {
      this.resultRValueTarget.textContent = "0"
      this.resultThicknessTarget.textContent = "0 in"
      this.resultQuantityTarget.textContent = "0"
      this.resultCostTarget.textContent = "$0.00"
      return
    }

    const rValue = R_VALUE_TABLE[zone][location]
    const rPerInch = R_PER_INCH[type]
    const thickness = (rValue / rPerInch).toFixed(1)
    const quantity = Math.ceil(area / COVERAGE_PER_UNIT)
    const cost = (area * COST_PER_SQFT[type]).toFixed(2)
    const unitLabel = UNIT_LABELS[type]

    this.resultRValueTarget.textContent = `R-${rValue}`
    this.resultThicknessTarget.textContent = `${thickness} in`
    this.resultQuantityTarget.textContent = `${quantity} ${unitLabel}`
    this.resultCostTarget.textContent = `$${Number(cost).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
  }

  copy() {
    const rValue = this.resultRValueTarget.textContent
    const thickness = this.resultThicknessTarget.textContent
    const quantity = this.resultQuantityTarget.textContent
    const cost = this.resultCostTarget.textContent
    const text = `Insulation Estimate:\nRequired R-Value: ${rValue}\nThickness: ${thickness}\nQuantity: ${quantity}\nEstimated Cost: ${cost}`
    navigator.clipboard.writeText(text)
  }
}
