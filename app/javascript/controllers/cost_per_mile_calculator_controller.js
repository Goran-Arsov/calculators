import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fuelCost", "insuranceCost", "maintenanceCost", "depreciationCost",
    "otherCosts", "milesDriven",
    "resultCostPerMile", "resultCostPerKm", "resultTotalCost",
    "resultKmDriven", "resultFuelPct", "resultInsurancePct",
    "resultMaintenancePct", "resultDepreciationPct", "resultOtherPct"
  ]

  calculate() {
    const fuel = parseFloat(this.fuelCostTarget.value) || 0
    const insurance = parseFloat(this.insuranceCostTarget.value) || 0
    const maintenance = parseFloat(this.maintenanceCostTarget.value) || 0
    const depreciation = parseFloat(this.depreciationCostTarget.value) || 0
    const other = parseFloat(this.otherCostsTarget.value) || 0
    const miles = parseFloat(this.milesDrivenTarget.value) || 0

    const total = fuel + insurance + maintenance + depreciation + other

    if (total <= 0 || miles <= 0) {
      this.clearResults()
      return
    }

    const costPerMile = total / miles
    const kmDriven = miles * 1.60934
    const costPerKm = total / kmDriven

    this.resultCostPerMileTarget.textContent = "$" + costPerMile.toFixed(4)
    this.resultCostPerKmTarget.textContent = "$" + costPerKm.toFixed(4)
    this.resultTotalCostTarget.textContent = this.formatCurrency(total)
    this.resultKmDrivenTarget.textContent = this.formatNumber(kmDriven)

    this.resultFuelPctTarget.textContent = this.pct(fuel, total)
    this.resultInsurancePctTarget.textContent = this.pct(insurance, total)
    this.resultMaintenancePctTarget.textContent = this.pct(maintenance, total)
    this.resultDepreciationPctTarget.textContent = this.pct(depreciation, total)
    this.resultOtherPctTarget.textContent = this.pct(other, total)
  }

  pct(value, total) {
    if (total <= 0) return "0%"
    return ((value / total) * 100).toFixed(1) + "%"
  }

  clearResults() {
    const targets = [
      "resultCostPerMile", "resultCostPerKm", "resultTotalCost", "resultKmDriven",
      "resultFuelPct", "resultInsurancePct", "resultMaintenancePct",
      "resultDepreciationPct", "resultOtherPct"
    ]
    targets.forEach(t => {
      if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) {
        this[`${t}Target`].textContent = "\u2014"
      }
    })
  }

  copy() {
    const text = [
      `Cost Per Mile: ${this.resultCostPerMileTarget.textContent}`,
      `Cost Per Km: ${this.resultCostPerKmTarget.textContent}`,
      `Total Cost: ${this.resultTotalCostTarget.textContent}`,
      `Miles Driven: ${this.milesDrivenTarget.value}`,
      `Km Driven: ${this.resultKmDrivenTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  formatNumber(value) {
    return Number(value).toLocaleString("en-US", { minimumFractionDigits: 1, maximumFractionDigits: 1 })
  }
}
