import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "distanceForCost", "mpgForCost", "priceForCost", "resultCost",
    "budgetForDist", "mpgForDist", "priceForDist", "resultDistance",
    "distanceForMpg", "budgetForMpg", "priceForMpg", "resultMpg"
  ]

  calcCost() {
    const dist = parseFloat(this.distanceForCostTarget.value) || 0
    const mpg = parseFloat(this.mpgForCostTarget.value) || 0
    const price = parseFloat(this.priceForCostTarget.value) || 0

    const cost = mpg > 0 ? (dist / mpg) * price : 0

    this.resultCostTarget.textContent = this.fmt(cost)
  }

  calcDistance() {
    const budget = parseFloat(this.budgetForDistTarget.value) || 0
    const mpg = parseFloat(this.mpgForDistTarget.value) || 0
    const price = parseFloat(this.priceForDistTarget.value) || 0

    const distance = price > 0 ? (budget / price) * mpg : 0

    this.resultDistanceTarget.textContent = this.fmt(distance)
  }

  calcMpg() {
    const dist = parseFloat(this.distanceForMpgTarget.value) || 0
    const budget = parseFloat(this.budgetForMpgTarget.value) || 0
    const price = parseFloat(this.priceForMpgTarget.value) || 0

    const mpgNeeded = budget > 0 && price > 0 ? dist / (budget / price) : 0

    this.resultMpgTarget.textContent = this.fmt(mpgNeeded)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
