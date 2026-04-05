import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalCost", "area", "unit",
    "pricePerSqm", "pricePerSqft", "pricePerAcre",
    "areaSqm", "areaSqft", "areaAcres"
  ]

  calculate() {
    const totalCost = parseFloat(this.totalCostTarget.value) || 0
    const area = parseFloat(this.areaTarget.value) || 0
    const unit = this.unitTarget.value

    if (totalCost <= 0 || area <= 0) {
      this.clearResults()
      return
    }

    const SQFT_PER_SQM = 10.7639
    const SQM_PER_ACRE = 4046.8564224

    const areaSqm = unit === "sqft" ? area / SQFT_PER_SQM : area
    const areaSqft = unit === "sqft" ? area : area * SQFT_PER_SQM
    const areaAcres = areaSqm / SQM_PER_ACRE

    const pricePerSqm = totalCost / areaSqm
    const pricePerSqft = totalCost / areaSqft
    const pricePerAcre = totalCost / areaAcres

    this.pricePerSqmTarget.textContent = this.formatCurrency(pricePerSqm)
    this.pricePerSqftTarget.textContent = this.formatCurrency(pricePerSqft)
    this.pricePerAcreTarget.textContent = this.formatCurrency(pricePerAcre)
    this.areaSqmTarget.textContent = this.formatNumber(areaSqm)
    this.areaSqftTarget.textContent = this.formatNumber(areaSqft)
    this.areaAcresTarget.textContent = this.formatNumber(areaAcres)
  }

  clearResults() {
    ;["pricePerSqm", "pricePerSqft", "pricePerAcre"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
    ;["areaSqm", "areaSqft", "areaAcres"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = [
      `Price per m\u00B2: ${this.pricePerSqmTarget.textContent}`,
      `Price per sqft: ${this.pricePerSqftTarget.textContent}`,
      `Price per acre: ${this.pricePerAcreTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  formatNumber(value) {
    return Number(value).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
