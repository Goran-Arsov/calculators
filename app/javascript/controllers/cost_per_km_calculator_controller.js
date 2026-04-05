import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "distance", "fuelUsed", "fuelPrice",
    "costPerKm", "costPerMile", "totalFuelCost", "distanceMiles",
    "resultsPanel", "copyButton"
  ]

  calculate() {
    const distance = parseFloat(this.distanceTarget.value) || 0
    const fuelUsed = parseFloat(this.fuelUsedTarget.value) || 0
    const fuelPrice = parseFloat(this.fuelPriceTarget.value) || 0

    if (distance <= 0 || fuelUsed <= 0 || fuelPrice <= 0) {
      this.clearResults()
      return
    }

    const totalCost = fuelUsed * fuelPrice
    const costPerKm = totalCost / distance
    const distanceMiles = distance / 1.60934
    const costPerMile = totalCost / distanceMiles

    this.costPerKmTarget.textContent = this.formatCurrency(costPerKm)
    this.costPerMileTarget.textContent = this.formatCurrency(costPerMile)
    this.totalFuelCostTarget.textContent = this.formatCurrency(totalCost)
    this.distanceMilesTarget.textContent = this.formatNumber(distanceMiles)
  }

  clearResults() {
    const targets = ["costPerKm", "costPerMile", "totalFuelCost"]
    targets.forEach(t => { if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) this[`${t}Target`].textContent = "\u2014" })
    if (this.hasDistanceMilesTarget) this.distanceMilesTarget.textContent = "\u2014"
  }

  copy() {
    const text = `Cost per km: ${this.costPerKmTarget.textContent}\nCost per mile: ${this.costPerMileTarget.textContent}\nTotal fuel cost: ${this.totalFuelCostTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  formatNumber(value) {
    return Number(value).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
