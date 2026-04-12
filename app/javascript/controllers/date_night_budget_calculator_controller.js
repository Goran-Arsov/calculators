import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dinner", "activity", "transport", "extras", "dates", "resultPerDate", "resultMonthly", "resultAnnual"]

  connect() { this.calculate() }

  calculate() {
    const dinner = parseFloat(this.dinnerTarget.value) || 0
    const activity = parseFloat(this.activityTarget.value) || 0
    const transport = parseFloat(this.transportTarget.value) || 0
    const extras = parseFloat(this.extrasTarget.value) || 0
    const dates = parseInt(this.datesTarget.value) || 1
    if (dates < 1) { this.clear(); return }

    const perDate = dinner + activity + transport + extras
    const monthly = perDate * dates
    const annual = monthly * 12

    this.resultPerDateTarget.textContent = this.money(perDate)
    this.resultMonthlyTarget.textContent = this.money(monthly)
    this.resultAnnualTarget.textContent = this.money(annual)
  }

  money(n) { return `$${n.toLocaleString("en-US", { maximumFractionDigits: 0 })}` }

  clear() {
    ["PerDate","Monthly","Annual"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Date night budget: ${this.resultPerDateTarget.textContent} per date, ${this.resultMonthlyTarget.textContent}/mo`)
  }
}
