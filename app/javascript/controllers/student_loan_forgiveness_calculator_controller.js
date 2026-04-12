import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "loanBalance", "annualRate", "monthlyIncome", "program",
    "familySize", "paymentsMade",
    "monthlyPayment", "totalPaid", "forgivenAmount", "remainingPayments",
    "monthsUntilForgiveness", "standardTotal", "savings", "taxOnForgiveness",
    "taxRow"
  ]

  calculate() {
    const loanBalance = parseFloat(this.loanBalanceTarget.value) || 0
    const annualRate = (parseFloat(this.annualRateTarget.value) || 0) / 100
    const monthlyIncome = parseFloat(this.monthlyIncomeTarget.value) || 0
    const program = this.programTarget.value || "pslf"
    const familySize = parseInt(this.familySizeTarget.value) || 1
    const paymentsMade = parseInt(this.paymentsMadeTarget.value) || 0

    if (loanBalance <= 0 || annualRate < 0 || monthlyIncome <= 0) {
      this.clearResults()
      return
    }

    const povertyGuidelines = { 1: 15060, 2: 20440, 3: 25820, 4: 31200, 5: 36580, 6: 41960, 7: 47340, 8: 52720 }
    const povertyLine = povertyGuidelines[familySize] || 15060
    const annualIncome = monthlyIncome * 12
    const discretionary = Math.max(annualIncome - povertyLine * 1.5, 0)
    const idrPayment = discretionary * 0.10 / 12

    let totalRequired
    if (program === "pslf") {
      totalRequired = 120
    } else if (program === "idr_20") {
      totalRequired = 240
    } else {
      totalRequired = 300
    }

    const remainingPayments = Math.max(totalRequired - paymentsMade, 0)
    const monthlyRate = annualRate / 12

    let balance = loanBalance
    let totalPaid = 0
    let months = 0

    for (let i = 0; i < remainingPayments; i++) {
      const interest = balance * monthlyRate
      const actual = Math.min(idrPayment, balance + interest)

      if (actual < interest) {
        balance += (interest - actual)
      } else {
        balance -= (actual - interest)
      }

      if (balance < 0.01) balance = 0
      totalPaid += actual
      months++
      if (balance <= 0.01) break
    }

    const forgiven = Math.max(balance, 0)
    const standardTotal = this.calculateStandardTotal(loanBalance, annualRate)
    const isPslf = program === "pslf"
    const taxRate = 0.22
    const taxOnForgiveness = isPslf ? 0 : forgiven * taxRate
    const savings = Math.max(standardTotal - totalPaid - taxOnForgiveness, 0)

    this.monthlyPaymentTarget.textContent = this.formatCurrency(idrPayment)
    this.totalPaidTarget.textContent = this.formatCurrency(totalPaid)
    this.forgivenAmountTarget.textContent = this.formatCurrency(forgiven)
    this.remainingPaymentsTarget.textContent = remainingPayments + " payments"
    this.monthsUntilForgivenessTarget.textContent = months + " months (" + (months / 12).toFixed(1) + " years)"
    this.standardTotalTarget.textContent = this.formatCurrency(standardTotal)
    this.savingsTarget.textContent = this.formatCurrency(savings)

    if (this.hasTaxRowTarget && this.hasTaxOnForgivenessTarget) {
      if (taxOnForgiveness > 0) {
        this.taxRowTarget.classList.remove("hidden")
        this.taxOnForgivenessTarget.textContent = this.formatCurrency(taxOnForgiveness)
      } else {
        this.taxRowTarget.classList.add("hidden")
      }
    }
  }

  calculateStandardTotal(balance, annualRate) {
    const monthlyRate = annualRate / 12
    const n = 120
    let monthlyPayment
    if (monthlyRate === 0) {
      monthlyPayment = balance / n
    } else {
      monthlyPayment = balance * (monthlyRate * Math.pow(1 + monthlyRate, n)) /
                        (Math.pow(1 + monthlyRate, n) - 1)
    }
    return monthlyPayment * n
  }

  clearResults() {
    this.monthlyPaymentTarget.textContent = "$0.00"
    this.totalPaidTarget.textContent = "$0.00"
    this.forgivenAmountTarget.textContent = "$0.00"
    this.remainingPaymentsTarget.textContent = "0 payments"
    this.monthsUntilForgivenessTarget.textContent = "0 months"
    this.standardTotalTarget.textContent = "$0.00"
    this.savingsTarget.textContent = "$0.00"
    if (this.hasTaxRowTarget) this.taxRowTarget.classList.add("hidden")
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Student Loan Forgiveness Calculator Results\nMonthly Payment: ${this.monthlyPaymentTarget.textContent}\nTotal Paid: ${this.totalPaidTarget.textContent}\nForgiven Amount: ${this.forgivenAmountTarget.textContent}\nEstimated Savings: ${this.savingsTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
