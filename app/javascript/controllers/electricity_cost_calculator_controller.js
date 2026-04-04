import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "powerForCost", "hoursForCost", "rateForCost", "resultCost", "kwhForCost",
    "costForPower", "hoursForPower", "rateForPower", "resultPower", "kwhForPower",
    "costForHours", "powerForHours", "rateForHours", "resultHours", "kwhForHours",
    "costForRate", "powerForRate", "hoursForRate", "resultRate", "kwhForRate"
  ]

  calcCost() {
    const p = parseFloat(this.powerForCostTarget.value)
    const h = parseFloat(this.hoursForCostTarget.value)
    const r = parseFloat(this.rateForCostTarget.value)
    if (p > 0 && h > 0 && r > 0) {
      const kwh = p * h
      this.kwhForCostTarget.textContent = this.fmt(kwh) + " kWh"
      this.resultCostTarget.textContent = "$" + this.fmt(kwh * r)
    } else { this.resultCostTarget.textContent = "—"; this.kwhForCostTarget.textContent = "—" }
  }

  calcPower() {
    const c = parseFloat(this.costForPowerTarget.value)
    const h = parseFloat(this.hoursForPowerTarget.value)
    const r = parseFloat(this.rateForPowerTarget.value)
    if (c >= 0 && !isNaN(c) && h > 0 && r > 0) {
      const p = c / (h * r)
      this.resultPowerTarget.textContent = this.fmt(p) + " kW"
      this.kwhForPowerTarget.textContent = this.fmt(p * h) + " kWh"
    } else { this.resultPowerTarget.textContent = "—"; this.kwhForPowerTarget.textContent = "—" }
  }

  calcHours() {
    const c = parseFloat(this.costForHoursTarget.value)
    const p = parseFloat(this.powerForHoursTarget.value)
    const r = parseFloat(this.rateForHoursTarget.value)
    if (c >= 0 && !isNaN(c) && p > 0 && r > 0) {
      const h = c / (p * r)
      this.resultHoursTarget.textContent = this.fmt(h) + " hrs"
      this.kwhForHoursTarget.textContent = this.fmt(p * h) + " kWh"
    } else { this.resultHoursTarget.textContent = "—"; this.kwhForHoursTarget.textContent = "—" }
  }

  calcRate() {
    const c = parseFloat(this.costForRateTarget.value)
    const p = parseFloat(this.powerForRateTarget.value)
    const h = parseFloat(this.hoursForRateTarget.value)
    if (c >= 0 && !isNaN(c) && p > 0 && h > 0) {
      const r = c / (p * h)
      this.resultRateTarget.textContent = "$" + this.fmt(r) + "/kWh"
      this.kwhForRateTarget.textContent = this.fmt(p * h) + " kWh"
    } else { this.resultRateTarget.textContent = "—"; this.kwhForRateTarget.textContent = "—" }
  }

  fmt(n) {
    if (n >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy(event) {
    const card = event.target.closest("[data-card]")
    const result = card.querySelector("[data-result]")
    navigator.clipboard.writeText(`${card.dataset.card}: ${result.textContent}`)
  }
}
