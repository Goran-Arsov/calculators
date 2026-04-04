import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "vehiclePrice", "downPayment", "tradeInValue", "salesTaxRate", "rate", "termMonths",
    "loanAmount", "salesTax", "monthlyPayment", "totalInterest", "totalCost"
  ]

  calculate() {
    const vehiclePrice = parseFloat(this.vehiclePriceTarget.value) || 0
    const downPayment = parseFloat(this.downPaymentTarget.value) || 0
    const tradeInValue = parseFloat(this.tradeInValueTarget.value) || 0
    const salesTaxRate = parseFloat(this.salesTaxRateTarget.value) / 100 || 0
    const annualRate = parseFloat(this.rateTarget.value) / 100 || 0
    const termMonths = parseInt(this.termMonthsTarget.value) || 0

    if (vehiclePrice <= 0 || termMonths <= 0 || annualRate < 0) {
      this.clearResults()
      return
    }

    const taxableAmount = vehiclePrice - tradeInValue
    const salesTax = Math.max(taxableAmount * salesTaxRate, 0)
    const loanAmount = vehiclePrice + salesTax - downPayment - tradeInValue

    if (loanAmount <= 0) {
      this.clearResults()
      return
    }

    const monthlyRate = annualRate / 12
    let monthlyPayment

    if (monthlyRate === 0) {
      monthlyPayment = loanAmount / termMonths
    } else {
      monthlyPayment = loanAmount * (monthlyRate * Math.pow(1 + monthlyRate, termMonths)) /
                        (Math.pow(1 + monthlyRate, termMonths) - 1)
    }

    const totalPaid = monthlyPayment * termMonths
    const totalInterest = totalPaid - loanAmount
    const totalCost = totalPaid + downPayment + tradeInValue

    this.loanAmountTarget.textContent = this.formatCurrency(loanAmount)
    this.salesTaxTarget.textContent = this.formatCurrency(salesTax)
    this.monthlyPaymentTarget.textContent = this.formatCurrency(monthlyPayment)
    this.totalInterestTarget.textContent = this.formatCurrency(totalInterest)
    this.totalCostTarget.textContent = this.formatCurrency(totalCost)
  }

  clearResults() {
    this.loanAmountTarget.textContent = "$0.00"
    this.salesTaxTarget.textContent = "$0.00"
    this.monthlyPaymentTarget.textContent = "$0.00"
    this.totalInterestTarget.textContent = "$0.00"
    this.totalCostTarget.textContent = "$0.00"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Loan Amount: ${this.loanAmountTarget.textContent}\nSales Tax: ${this.salesTaxTarget.textContent}\nMonthly Payment: ${this.monthlyPaymentTarget.textContent}\nTotal Interest: ${this.totalInterestTarget.textContent}\nTotal Cost: ${this.totalCostTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
