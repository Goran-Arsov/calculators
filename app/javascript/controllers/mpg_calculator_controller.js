import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "distance", "fuelUsed", "unitSystem",
    "mpg", "lper100km", "costPerMile", "fuelCostInput"
  ]

  calculate() {
    const distance = parseFloat(this.distanceTarget.value) || 0
    const fuelUsed = parseFloat(this.fuelUsedTarget.value) || 0
    const unit = this.unitSystemTarget.value
    const fuelCost = this.hasFuelCostInputTarget ? parseFloat(this.fuelCostInputTarget.value) || 0 : 0

    if (distance <= 0 || fuelUsed <= 0) {
      this.clearResults()
      return
    }

    let mpg, lper100km, costPerMile

    if (unit === "metric") {
      lper100km = (fuelUsed / distance) * 100
      mpg = 235.215 / lper100km
      costPerMile = fuelCost > 0 ? (fuelUsed * fuelCost / distance) : 0
    } else {
      mpg = distance / fuelUsed
      lper100km = 235.215 / mpg
      costPerMile = fuelCost > 0 ? fuelCost / mpg : 0
    }

    this.mpgTarget.textContent = mpg.toFixed(1)
    this.lper100kmTarget.textContent = lper100km.toFixed(2)
    if (this.hasCostPerMileTarget) {
      this.costPerMileTarget.textContent = "$" + costPerMile.toFixed(3)
    }
  }

  clearResults() {
    this.mpgTarget.textContent = "0.0"
    this.lper100kmTarget.textContent = "0.00"
    if (this.hasCostPerMileTarget) {
      this.costPerMileTarget.textContent = "$0.000"
    }
  }

  copy() {
    const text = `MPG: ${this.mpgTarget.textContent}\nL/100km: ${this.lper100kmTarget.textContent}\nCost per Mile: ${this.hasCostPerMileTarget ? this.costPerMileTarget.textContent : 'N/A'}`
    navigator.clipboard.writeText(text)
  }
}
