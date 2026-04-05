import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalCost", "numberOfHours",
    "resultCostPerHour", "resultCostPerMinute", "resultCostPerDay", "resultCostPer8Hours"
  ]

  calculate() {
    const totalCost = parseFloat(this.totalCostTarget.value) || 0
    const hours = parseFloat(this.numberOfHoursTarget.value) || 0

    if (totalCost <= 0 || hours <= 0) {
      this.clearResults()
      return
    }

    const costPerHour = totalCost / hours
    const costPerMinute = costPerHour / 60
    const costPerDay = costPerHour * 24
    const costPer8Hours = costPerHour * 8

    this.resultCostPerHourTarget.textContent = this.formatCurrency(costPerHour)
    this.resultCostPerMinuteTarget.textContent = this.formatCurrency(costPerMinute)
    this.resultCostPerDayTarget.textContent = this.formatCurrency(costPerDay)
    this.resultCostPer8HoursTarget.textContent = this.formatCurrency(costPer8Hours)
  }

  clearResults() {
    const targets = ["resultCostPerHour", "resultCostPerMinute", "resultCostPerDay", "resultCostPer8Hours"]
    targets.forEach(t => {
      if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) {
        this[`${t}Target`].textContent = "\u2014"
      }
    })
  }

  copy() {
    const text = [
      `Cost Per Hour: ${this.resultCostPerHourTarget.textContent}`,
      `Cost Per Minute: ${this.resultCostPerMinuteTarget.textContent}`,
      `Cost Per Day (24h): ${this.resultCostPerDayTarget.textContent}`,
      `Cost Per 8-Hour Day: ${this.resultCostPer8HoursTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }
}
