import { Controller } from "@hotwired/stimulus"
import { formatCurrency } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["principal", "rate", "years", "monthlyPayment", "totalPaid", "totalInterest", "numPayments"]

  connect() {
    if (prefillFromUrl(this, { principal: "principal", rate: "rate", years: "years" })) {
      this.calculate()
    }
  }

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

    this.monthlyPaymentTarget.textContent = formatCurrency(monthlyPayment)
    this.totalPaidTarget.textContent = formatCurrency(totalPaid)
    this.totalInterestTarget.textContent = formatCurrency(totalInterest)
    this.numPaymentsTarget.textContent = numPayments
  }

  clearResults() {
    this.monthlyPaymentTarget.textContent = "$0.00"
    this.totalPaidTarget.textContent = "$0.00"
    this.totalInterestTarget.textContent = "$0.00"
    this.numPaymentsTarget.textContent = "0"
  }

  copy(event) {
    const text = `Monthly Payment: ${this.monthlyPaymentTarget.textContent}\nTotal Paid: ${this.totalPaidTarget.textContent}\nTotal Interest: ${this.totalInterestTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
