import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fixedCosts", "price", "variableCost", "resultUnits", "resultRevenue"]

  calculate() {
    const fixedCosts = parseFloat(this.fixedCostsTarget.value) || 0
    const price = parseFloat(this.priceTarget.value) || 0
    const variableCost = parseFloat(this.variableCostTarget.value) || 0

    if (fixedCosts <= 0 || price <= 0 || price <= variableCost) {
      this.resultUnitsTarget.textContent = "—"
      this.resultRevenueTarget.textContent = "—"
      return
    }

    const units = Math.ceil(fixedCosts / (price - variableCost))
    const revenue = units * price

    this.resultUnitsTarget.textContent = this.fmt(units) + " units"
    this.resultRevenueTarget.textContent = "$" + this.fmt(revenue)
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy(event) {
    const card = event.target.closest("[data-card]")
    const result = card.querySelector("[data-result]")
    navigator.clipboard.writeText(`${card.dataset.card}: ${result.textContent}`)
  }
}
