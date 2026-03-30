import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["principal", "rate", "years", "monthlyPayment", "totalPaid", "totalInterest", "numPayments"]

  calculate() {
    const principal = parseFloat(this.principalTarget.value) || 0
    const annualRate = parseFloat(this.rateTarget.value) / 100
    const years = parseInt(this.yearsTarget.value) || 0

    if (principal <= 0 || years <= 0 || annualRate < 0) {
      this.clearResults()
      return
    }

    const monthlyRate = annualRate / 12
    const numPayments = years * 12
    let monthlyPayment

    if (monthlyRate === 0) {
      monthlyPayment = principal / numPayments
    } else {
      monthlyPayment = principal * (monthlyRate * Math.pow(1 + monthlyRate, numPayments)) /
                        (Math.pow(1 + monthlyRate, numPayments) - 1)
    }

    const totalPaid = monthlyPayment * numPayments
    const totalInterest = totalPaid - principal

    this.monthlyPaymentTarget.textContent = this.formatCurrency(monthlyPayment)
    this.totalPaidTarget.textContent = this.formatCurrency(totalPaid)
    this.totalInterestTarget.textContent = this.formatCurrency(totalInterest)
    this.numPaymentsTarget.textContent = numPayments
  }

  clearResults() {
    this.monthlyPaymentTarget.textContent = "$0.00"
    this.totalPaidTarget.textContent = "$0.00"
    this.totalInterestTarget.textContent = "$0.00"
    this.numPaymentsTarget.textContent = "0"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Monthly Payment: ${this.monthlyPaymentTarget.textContent}\nTotal Paid: ${this.totalPaidTarget.textContent}\nTotal Interest: ${this.totalInterestTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
