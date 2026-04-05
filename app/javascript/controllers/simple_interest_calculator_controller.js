import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["principal", "rate", "years", "totalInterest", "totalValue"]

  calculate() {
    const principal = parseFloat(this.principalTarget.value) || 0
    const rate = parseFloat(this.rateTarget.value) / 100
    const years = parseFloat(this.yearsTarget.value) || 0

    if (principal <= 0 || years <= 0 || rate < 0) {
      this.clearResults()
      return
    }

    const totalInterest = principal * rate * years
    const totalValue = principal + totalInterest

    this.totalInterestTarget.textContent = this.formatCurrency(totalInterest)
    this.totalValueTarget.textContent = this.formatCurrency(totalValue)
  }

  clearResults() {
    this.totalInterestTarget.textContent = "$0.00"
    this.totalValueTarget.textContent = "$0.00"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Simple Interest: ${this.totalInterestTarget.textContent}\nTotal Value: ${this.totalValueTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
