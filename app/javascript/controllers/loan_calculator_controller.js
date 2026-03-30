import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["amount", "rate", "years", "monthlyPayment", "totalPaid", "totalInterest", "numPayments"]

  calculate() {
    const amount = parseFloat(this.amountTarget.value) || 0
    const annualRate = parseFloat(this.rateTarget.value) / 100
    const years = parseInt(this.yearsTarget.value) || 0

    if (amount <= 0 || years <= 0 || annualRate < 0) {
      this.clearResults()
      return
    }

    const monthlyRate = annualRate / 12
    const numPayments = years * 12
    let monthlyPayment

    if (monthlyRate === 0) {
      monthlyPayment = amount / numPayments
    } else {
      monthlyPayment = amount * (monthlyRate * Math.pow(1 + monthlyRate, numPayments)) /
                        (Math.pow(1 + monthlyRate, numPayments) - 1)
    }

    const totalPaid = monthlyPayment * numPayments
    const totalInterest = totalPaid - amount

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
