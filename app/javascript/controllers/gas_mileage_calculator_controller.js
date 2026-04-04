import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["distanceMiles", "fuelGallons", "resultMpg", "distanceKm", "fuelLiters", "resultLper100km"]

  calcMpg() {
    const dist = parseFloat(this.distanceMilesTarget.value) || 0
    const fuel = parseFloat(this.fuelGallonsTarget.value) || 0

    const mpg = fuel > 0 ? dist / fuel : 0

    this.resultMpgTarget.textContent = this.fmt(mpg)
  }

  calcLper100km() {
    const dist = parseFloat(this.distanceKmTarget.value) || 0
    const fuel = parseFloat(this.fuelLitersTarget.value) || 0

    const l100 = dist > 0 ? (fuel / dist) * 100 : 0

    this.resultLper100kmTarget.textContent = this.fmt(l100)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
