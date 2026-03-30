import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["balance", "rate", "monthlyPayment", "monthsToPayoff", "yearsToPayoff", "totalPaid", "totalInterest"]

  calculate() {
    const balance = parseFloat(this.balanceTarget.value) || 0
    const annualRate = parseFloat(this.rateTarget.value) / 100
    const monthlyPayment = parseFloat(this.monthlyPaymentTarget.value) || 0

    if (balance <= 0 || monthlyPayment <= 0 || annualRate < 0) {
      this.clearResults()
      return
    }

    const monthlyRate = annualRate / 12
    let months

    if (monthlyRate === 0) {
      months = Math.ceil(balance / monthlyPayment)
    } else {
      const minPayment = balance * monthlyRate
      if (monthlyPayment <= minPayment) {
        this.monthsToPayoffTarget.textContent = "Never"
        this.yearsToPayoffTarget.textContent = "Payment too low"
        this.totalPaidTarget.textContent = "—"
        this.totalInterestTarget.textContent = "—"
        return
      }
      months = Math.ceil(-Math.log(1 - monthlyRate * balance / monthlyPayment) / Math.log(1 + monthlyRate))
    }

    const totalPaid = monthlyPayment * months
    const totalInterest = totalPaid - balance

    this.monthsToPayoffTarget.textContent = months
    this.yearsToPayoffTarget.textContent = (months / 12).toFixed(1)
    this.totalPaidTarget.textContent = this.formatCurrency(totalPaid)
    this.totalInterestTarget.textContent = this.formatCurrency(totalInterest)
  }

  clearResults() {
    this.monthsToPayoffTarget.textContent = "0"
    this.yearsToPayoffTarget.textContent = "0"
    this.totalPaidTarget.textContent = "$0.00"
    this.totalInterestTarget.textContent = "$0.00"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Months to Payoff: ${this.monthsToPayoffTarget.textContent}\nTotal Paid: ${this.totalPaidTarget.textContent}\nTotal Interest: ${this.totalInterestTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
