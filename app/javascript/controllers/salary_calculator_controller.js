import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["amount", "type", "hoursPerWeek", "hourly", "daily", "weekly", "biweekly", "monthly", "annual"]

  calculate() {
    const amount = parseFloat(this.amountTarget.value) || 0
    const type = this.typeTarget.value
    const hoursPerWeek = parseFloat(this.hoursPerWeekTarget.value) || 40

    if (amount <= 0 || hoursPerWeek <= 0) {
      this.clearResults()
      return
    }

    let hourly
    switch (type) {
      case "hourly":   hourly = amount; break
      case "daily":    hourly = amount / (hoursPerWeek / 5); break
      case "weekly":   hourly = amount / hoursPerWeek; break
      case "biweekly": hourly = amount / (hoursPerWeek * 2); break
      case "monthly":  hourly = amount * 12 / (52 * hoursPerWeek); break
      case "annual":   hourly = amount / (52 * hoursPerWeek); break
      default:         hourly = amount / (52 * hoursPerWeek)
    }

    this.hourlyTarget.textContent = this.formatCurrency(hourly)
    this.dailyTarget.textContent = this.formatCurrency(hourly * hoursPerWeek / 5)
    this.weeklyTarget.textContent = this.formatCurrency(hourly * hoursPerWeek)
    this.biweeklyTarget.textContent = this.formatCurrency(hourly * hoursPerWeek * 2)
    this.monthlyTarget.textContent = this.formatCurrency(hourly * hoursPerWeek * 52 / 12)
    this.annualTarget.textContent = this.formatCurrency(hourly * hoursPerWeek * 52)
  }

  clearResults() {
    const targets = ["hourly", "daily", "weekly", "biweekly", "monthly", "annual"]
    targets.forEach(t => this[`${t}Target`].textContent = "$0.00")
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Hourly: ${this.hourlyTarget.textContent}\nDaily: ${this.dailyTarget.textContent}\nWeekly: ${this.weeklyTarget.textContent}\nBiweekly: ${this.biweeklyTarget.textContent}\nMonthly: ${this.monthlyTarget.textContent}\nAnnual: ${this.annualTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
