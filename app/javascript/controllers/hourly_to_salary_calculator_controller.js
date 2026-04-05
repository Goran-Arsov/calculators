import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "amount", "direction", "hoursPerWeek", "weeksPerYear",
    "resultHourly", "resultDaily", "resultWeekly", "resultBiweekly",
    "resultMonthly", "resultAnnual"
  ]

  calculate() {
    const amount = parseFloat(this.amountTarget.value) || 0
    const direction = this.directionTarget.value
    const hoursPerWeek = parseFloat(this.hoursPerWeekTarget.value) || 40
    const weeksPerYear = parseFloat(this.weeksPerYearTarget.value) || 52

    if (amount <= 0 || hoursPerWeek <= 0 || weeksPerYear <= 0) {
      this.clearResults()
      return
    }

    let hourly, annual
    if (direction === "hourly_to_salary") {
      hourly = amount
      annual = hourly * hoursPerWeek * weeksPerYear
    } else {
      annual = amount
      hourly = annual / (hoursPerWeek * weeksPerYear)
    }

    const daily = hourly * (hoursPerWeek / 5)
    const weekly = hourly * hoursPerWeek
    const biweekly = weekly * 2
    const monthly = annual / 12

    this.resultHourlyTarget.textContent = this.formatCurrency(hourly)
    this.resultDailyTarget.textContent = this.formatCurrency(daily)
    this.resultWeeklyTarget.textContent = this.formatCurrency(weekly)
    this.resultBiweeklyTarget.textContent = this.formatCurrency(biweekly)
    this.resultMonthlyTarget.textContent = this.formatCurrency(monthly)
    this.resultAnnualTarget.textContent = this.formatCurrency(annual)
  }

  clearResults() {
    ;["resultHourly", "resultDaily", "resultWeekly", "resultBiweekly", "resultMonthly", "resultAnnual"].forEach(t => {
      this[`${t}Target`].textContent = "$0.00"
    })
  }

  copy() {
    const text = `Hourly: ${this.resultHourlyTarget.textContent}\nDaily: ${this.resultDailyTarget.textContent}\nWeekly: ${this.resultWeeklyTarget.textContent}\nBiweekly: ${this.resultBiweeklyTarget.textContent}\nMonthly: ${this.resultMonthlyTarget.textContent}\nAnnual: ${this.resultAnnualTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }
}
