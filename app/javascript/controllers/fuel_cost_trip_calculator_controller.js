import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "distance", "fuelEfficiency", "fuelPrice",
    "efficiencyUnit", "distanceUnit", "priceUnit",
    "tripCost", "fuelNeededLiters", "fuelNeededGallons",
    "costPerKm", "costPerMile", "lPer100km"
  ]

  calculate() {
    const distance = parseFloat(this.distanceTarget.value) || 0
    const efficiency = parseFloat(this.fuelEfficiencyTarget.value) || 0
    const fuelPrice = parseFloat(this.fuelPriceTarget.value) || 0
    const effUnit = this.efficiencyUnitTarget.value
    const distUnit = this.distanceUnitTarget.value
    const priceUnit = this.priceUnitTarget.value

    if (distance <= 0 || efficiency <= 0 || fuelPrice <= 0) {
      this.clearResults()
      return
    }

    const KM_PER_MILE = 1.60934
    const LITERS_PER_GALLON = 3.78541

    const distanceKm = distUnit === "miles" ? distance * KM_PER_MILE : distance
    const distanceMiles = distUnit === "miles" ? distance : distance / KM_PER_MILE

    let lPer100km
    switch (effUnit) {
      case "l_per_100km": lPer100km = efficiency; break
      case "mpg":         lPer100km = LITERS_PER_GALLON * 100 / (efficiency * KM_PER_MILE); break
      case "km_per_l":    lPer100km = 100 / efficiency; break
      default:            lPer100km = efficiency
    }

    const fuelLiters = distanceKm * lPer100km / 100
    const fuelGallons = fuelLiters / LITERS_PER_GALLON

    const pricePerLiter = priceUnit === "per_gallon" ? fuelPrice / LITERS_PER_GALLON : fuelPrice
    const tripCost = fuelLiters * pricePerLiter

    this.tripCostTarget.textContent = this.formatCurrency(tripCost)
    this.fuelNeededLitersTarget.textContent = this.formatNumber(fuelLiters) + " L"
    this.fuelNeededGallonsTarget.textContent = this.formatNumber(fuelGallons) + " gal"
    this.costPerKmTarget.textContent = this.formatCurrency(tripCost / distanceKm)
    this.costPerMileTarget.textContent = this.formatCurrency(tripCost / distanceMiles)
    this.lPer100kmTarget.textContent = this.formatNumber(lPer100km)
  }

  clearResults() {
    ;["tripCost", "fuelNeededLiters", "fuelNeededGallons", "costPerKm", "costPerMile", "lPer100km"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = `Trip cost: ${this.tripCostTarget.textContent}\nFuel needed: ${this.fuelNeededLitersTarget.textContent} (${this.fuelNeededGallonsTarget.textContent})\nCost per km: ${this.costPerKmTarget.textContent}\nCost per mile: ${this.costPerMileTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  formatNumber(value) {
    return Number(value).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
