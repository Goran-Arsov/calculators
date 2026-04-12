import { Controller } from "@hotwired/stimulus"
import { formatCurrency } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "homeValue", "mortgageBalance", "creditLimitPercent", "annualRate",
    "drawAmount", "repaymentYears",
    "availableEquity", "monthlyPayment", "interestOnlyPayment",
    "totalPaid", "totalInterest"
  ]

  connect() {
    if (prefillFromUrl(this, {
      homeValue: "homeValue", mortgageBalance: "mortgageBalance",
      creditLimitPercent: "creditLimitPercent", annualRate: "annualRate",
      drawAmount: "drawAmount", repaymentYears: "repaymentYears"
    })) {
      this.calculate()
    }
  }

  calculate() {
    const homeValue = parseFloat(this.homeValueTarget.value) || 0
    const mortgageBalance = parseFloat(this.mortgageBalanceTarget.value) || 0
    const creditLimitPercent = parseFloat(this.creditLimitPercentTarget.value) / 100 || 0
    const annualRate = parseFloat(this.annualRateTarget.value) / 100 || 0
    const drawAmount = parseFloat(this.drawAmountTarget.value) || 0
    const repaymentYears = parseInt(this.repaymentYearsTarget.value) || 0

    if (homeValue <= 0 || repaymentYears <= 0) {
      this.clearResults()
      return
    }

    const availableEquity = Math.max((homeValue * creditLimitPercent) - mortgageBalance, 0)
    const monthlyRate = annualRate / 12
    const numPayments = repaymentYears * 12

    let monthlyPayment = 0
    let totalPaid = 0
    let totalInterest = 0

    if (drawAmount > 0 && numPayments > 0) {
      if (monthlyRate === 0) {
        monthlyPayment = drawAmount / numPayments
      } else {
        monthlyPayment = drawAmount * (monthlyRate * Math.pow(1 + monthlyRate, numPayments)) /
                         (Math.pow(1 + monthlyRate, numPayments) - 1)
      }
      totalPaid = monthlyPayment * numPayments
      totalInterest = totalPaid - drawAmount
    }

    const interestOnlyPayment = drawAmount * monthlyRate

    this.availableEquityTarget.textContent = formatCurrency(availableEquity)
    this.monthlyPaymentTarget.textContent = formatCurrency(monthlyPayment)
    this.interestOnlyPaymentTarget.textContent = formatCurrency(interestOnlyPayment)
    this.totalPaidTarget.textContent = formatCurrency(totalPaid)
    this.totalInterestTarget.textContent = formatCurrency(totalInterest)
  }

  clearResults() {
    this.availableEquityTarget.textContent = "$0.00"
    this.monthlyPaymentTarget.textContent = "$0.00"
    this.interestOnlyPaymentTarget.textContent = "$0.00"
    this.totalPaidTarget.textContent = "$0.00"
    this.totalInterestTarget.textContent = "$0.00"
  }

  copy(event) {
    const text = `Available Equity: ${this.availableEquityTarget.textContent}\nMonthly Payment: ${this.monthlyPaymentTarget.textContent}\nInterest-Only Payment: ${this.interestOnlyPaymentTarget.textContent}\nTotal Interest: ${this.totalInterestTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
