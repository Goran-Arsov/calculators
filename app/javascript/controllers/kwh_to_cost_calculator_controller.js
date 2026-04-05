import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "kwhUsage", "ratePerKwh", "period",
    "dailyCost", "monthlyCost", "yearlyCost", "dailyKwh",
    "resultsPanel", "copyButton"
  ]

  calculate() {
    const kwh = parseFloat(this.kwhUsageTarget.value) || 0
    const rate = parseFloat(this.ratePerKwhTarget.value) || 0
    const period = this.periodTarget.value

    if (kwh <= 0 || rate <= 0) {
      this.clearResults()
      return
    }

    let dailyKwh
    switch (period) {
      case "daily":   dailyKwh = kwh; break
      case "monthly": dailyKwh = kwh / 30; break
      case "yearly":  dailyKwh = kwh / 365; break
      default:        dailyKwh = kwh
    }

    const dailyCost = dailyKwh * rate
    const monthlyCost = dailyCost * 30
    const yearlyCost = dailyCost * 365

    this.dailyKwhTarget.textContent = this.formatNumber(dailyKwh)
    this.dailyCostTarget.textContent = this.formatCurrency(dailyCost)
    this.monthlyCostTarget.textContent = this.formatCurrency(monthlyCost)
    this.yearlyCostTarget.textContent = this.formatCurrency(yearlyCost)
  }

  clearResults() {
    ;["dailyCost", "monthlyCost", "yearlyCost", "dailyKwh"].forEach(t => {
      if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = `Daily: ${this.dailyCostTarget.textContent}\nMonthly: ${this.monthlyCostTarget.textContent}\nYearly: ${this.yearlyCostTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  formatNumber(value) {
    return Number(value).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
