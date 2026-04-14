import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM } from "utils/units"

const SQFT_PER_SQM = 1 / SQFT_TO_SQM
const SQFT_PER_ACRE = 43560

export default class extends Controller {
  static targets = [
    "totalCost", "areaSqft",
    "unitSystem", "areaLabel",
    "costPerSqft", "costPerSqm", "costPerAcre",
    "areaSqm", "areaAcres"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const n = parseFloat(this.areaSqftTarget.value)
    if (Number.isFinite(n)) {
      this.areaSqftTarget.value = (toMetric ? n * SQFT_TO_SQM : n / SQFT_TO_SQM).toFixed(2)
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.areaLabelTarget.textContent = metric ? "Area (m²)" : "Area (sqft)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const totalCost = parseFloat(this.totalCostTarget.value) || 0
    const areaInput = parseFloat(this.areaSqftTarget.value) || 0

    if (totalCost <= 0 || areaInput <= 0) {
      this.clearResults()
      return
    }

    // Canonical area in sqft
    const areaSqft = metric ? areaInput / SQFT_TO_SQM : areaInput

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
