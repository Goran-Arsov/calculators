import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "systemSize", "rate", "sunHours", "systemCost",
    "resultAnnualProduction", "resultAnnualSavings", "resultPaybackYears", "resultSavings25"
  ]

  calculate() {
    const size = parseFloat(this.systemSizeTarget.value) || 0
    const rate = parseFloat(this.rateTarget.value) || 0
    const sunHours = parseFloat(this.sunHoursTarget.value) || 0
    const systemCost = parseFloat(this.systemCostTarget.value) || 0

    if (size <= 0 || rate <= 0 || sunHours <= 0 || systemCost <= 0) {
      this.resultAnnualProductionTarget.textContent = "—"
      this.resultAnnualSavingsTarget.textContent = "—"
      this.resultPaybackYearsTarget.textContent = "—"
      this.resultSavings25Target.textContent = "—"
      return
    }

    const annualProduction = size * sunHours * 365
    const annualSavings = annualProduction * rate
    const paybackYears = systemCost / annualSavings
    const savings25 = (annualSavings * 25) - systemCost

    this.resultAnnualProductionTarget.textContent = this.fmt(annualProduction) + " kWh"
    this.resultAnnualSavingsTarget.textContent = "$" + this.fmt(annualSavings)
    this.resultPaybackYearsTarget.textContent = this.fmt(paybackYears) + " years"
    this.resultSavings25Target.textContent = "$" + this.fmt(savings25)
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
