import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalCost", "numberOfDays",
    "resultCostPerDay", "resultCostPerWeek", "resultCostPerMonth", "resultCostPerYear"
  ]

  calculate() {
    const totalCost = parseFloat(this.totalCostTarget.value) || 0
    const days = parseFloat(this.numberOfDaysTarget.value) || 0

    if (totalCost <= 0 || days <= 0) {
      this.clearResults()
      return
    }

    const costPerDay = totalCost / days
    const costPerWeek = costPerDay * 7
    const costPerMonth = costPerDay * 30.4375
    const costPerYear = costPerDay * 365.25

    this.resultCostPerDayTarget.textContent = this.formatCurrency(costPerDay)
    this.resultCostPerWeekTarget.textContent = this.formatCurrency(costPerWeek)
    this.resultCostPerMonthTarget.textContent = this.formatCurrency(costPerMonth)
    this.resultCostPerYearTarget.textContent = this.formatCurrency(costPerYear)
  }

  clearResults() {
    const targets = ["resultCostPerDay", "resultCostPerWeek", "resultCostPerMonth", "resultCostPerYear"]
    targets.forEach(t => {
      if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) {
        this[`${t}Target`].textContent = "\u2014"
      }
    })
  }

  copy() {
    const text = [
      `Cost Per Day: ${this.resultCostPerDayTarget.textContent}`,
      `Cost Per Week: ${this.resultCostPerWeekTarget.textContent}`,
      `Cost Per Month: ${this.resultCostPerMonthTarget.textContent}`,
      `Cost Per Year: ${this.resultCostPerYearTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }
}
