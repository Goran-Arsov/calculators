import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "cartridgeCost", "pageYield", "pagesPerMonth",
    "resultCostPerPage", "resultCostPer100", "resultMonthlyCost",
    "resultYearlyCost", "resultCartridgesPerYear",
    "monthlyPanel"
  ]

  calculate() {
    const cartridgeCost = parseFloat(this.cartridgeCostTarget.value) || 0
    const pageYield = parseFloat(this.pageYieldTarget.value) || 0
    const pagesPerMonth = parseFloat(this.pagesPerMonthTarget.value) || 0

    if (cartridgeCost <= 0 || pageYield <= 0) {
      this.clearResults()
      return
    }

    const costPerPage = cartridgeCost / pageYield
    const costPer100 = costPerPage * 100

    this.resultCostPerPageTarget.textContent = "$" + costPerPage.toFixed(4)
    this.resultCostPer100Target.textContent = this.formatCurrency(costPer100)

    if (pagesPerMonth > 0) {
      const monthlyCost = costPerPage * pagesPerMonth
      const yearlyCost = monthlyCost * 12
      const cartridgesPerYear = (pagesPerMonth * 12) / pageYield

      this.resultMonthlyCostTarget.textContent = this.formatCurrency(monthlyCost)
      this.resultYearlyCostTarget.textContent = this.formatCurrency(yearlyCost)
      this.resultCartridgesPerYearTarget.textContent = cartridgesPerYear.toFixed(1)
      if (this.hasMonthlyPanelTarget) this.monthlyPanelTarget.classList.remove("hidden")
    } else {
      if (this.hasMonthlyPanelTarget) this.monthlyPanelTarget.classList.add("hidden")
    }
  }

  clearResults() {
    this.resultCostPerPageTarget.textContent = "\u2014"
    this.resultCostPer100Target.textContent = "\u2014"
    if (this.hasMonthlyPanelTarget) this.monthlyPanelTarget.classList.add("hidden")
  }

  copy() {
    let text = `Cost Per Page: ${this.resultCostPerPageTarget.textContent}\nCost Per 100 Pages: ${this.resultCostPer100Target.textContent}`
    if (this.hasMonthlyPanelTarget && !this.monthlyPanelTarget.classList.contains("hidden")) {
      text += `\nMonthly Cost: ${this.resultMonthlyCostTarget.textContent}`
      text += `\nYearly Cost: ${this.resultYearlyCostTarget.textContent}`
      text += `\nCartridges/Year: ${this.resultCartridgesPerYearTarget.textContent}`
    }
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }
}
