import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalCost", "areaSqft",
    "costPerSqft", "costPerSqm", "costPerAcre",
    "areaSqm", "areaAcres"
  ]

  calculate() {
    const totalCost = parseFloat(this.totalCostTarget.value) || 0
    const areaSqft = parseFloat(this.areaSqftTarget.value) || 0

    if (totalCost <= 0 || areaSqft <= 0) {
      this.clearResults()
      return
    }

    const SQFT_PER_SQM = 10.7639
    const SQFT_PER_ACRE = 43560

    const costPerSqft = totalCost / areaSqft
    const areaSqm = areaSqft / SQFT_PER_SQM
    const costPerSqm = totalCost / areaSqm
    const areaAcres = areaSqft / SQFT_PER_ACRE
    const costPerAcre = totalCost / areaAcres

    this.costPerSqftTarget.textContent = this.formatCurrency(costPerSqft)
    this.costPerSqmTarget.textContent = this.formatCurrency(costPerSqm)
    this.costPerAcreTarget.textContent = this.formatCurrency(costPerAcre)
    this.areaSqmTarget.textContent = this.formatNumber(areaSqm)
    this.areaAcresTarget.textContent = this.formatNumber(areaAcres)
  }

  clearResults() {
    ;["costPerSqft", "costPerSqm", "costPerAcre"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
    ;["areaSqm", "areaAcres"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = `Cost per sqft: ${this.costPerSqftTarget.textContent}\nCost per m\u00B2: ${this.costPerSqmTarget.textContent}\nCost per acre: ${this.costPerAcreTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  formatNumber(value) {
    return Number(value).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
