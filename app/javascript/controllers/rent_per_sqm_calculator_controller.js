import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "monthlyRent", "area", "unit",
    "pricePerSqm", "pricePerSqft", "annualCost", "areaSqm", "areaSqft"
  ]

  calculate() {
    const rent = parseFloat(this.monthlyRentTarget.value) || 0
    const area = parseFloat(this.areaTarget.value) || 0
    const unit = this.unitTarget.value

    if (rent <= 0 || area <= 0) {
      this.clearResults()
      return
    }

    const SQFT_PER_SQM = 10.7639
    const areaSqm = unit === "sqft" ? area / SQFT_PER_SQM : area
    const areaSqft = unit === "sqft" ? area : area * SQFT_PER_SQM

    const pricePerSqm = rent / areaSqm
    const pricePerSqft = rent / areaSqft
    const annualCost = rent * 12

    this.pricePerSqmTarget.textContent = this.formatCurrency(pricePerSqm)
    this.pricePerSqftTarget.textContent = this.formatCurrency(pricePerSqft)
    this.annualCostTarget.textContent = this.formatCurrency(annualCost)
    this.areaSqmTarget.textContent = this.formatNumber(areaSqm)
    this.areaSqftTarget.textContent = this.formatNumber(areaSqft)
  }

  clearResults() {
    ;["pricePerSqm", "pricePerSqft", "annualCost"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
    ;["areaSqm", "areaSqft"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = `Price per m\u00B2: ${this.pricePerSqmTarget.textContent}\nPrice per sqft: ${this.pricePerSqftTarget.textContent}\nAnnual cost: ${this.annualCostTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  formatNumber(value) {
    return Number(value).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
