import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "annualIncome", "monthlyDebts", "downPayment", "interestRate", "loanTerm",
    "propertyTaxRate", "annualInsurance",
    "maxHomePrice", "maxLoanAmount", "monthlyPI", "monthlyTax", "monthlyInsurance",
    "totalMonthlyPayment", "frontEndDTI", "backEndDTI"
  ]

  calculate() {
    const annualIncome = parseFloat(this.annualIncomeTarget.value) || 0
    const monthlyDebts = parseFloat(this.monthlyDebtsTarget.value) || 0
    const downPayment = parseFloat(this.downPaymentTarget.value) || 0
    const annualRate = parseFloat(this.interestRateTarget.value) / 100 || 0
    const loanTerm = parseInt(this.loanTermTarget.value) || 0
    const propertyTaxRate = parseFloat(this.propertyTaxRateTarget.value) / 100 || 0
    const annualInsurance = parseFloat(this.annualInsuranceTarget.value) || 0

    if (annualIncome <= 0 || loanTerm <= 0) {
      this.clearResults()
      return
    }

    const grossMonthlyIncome = annualIncome / 12

    // Front-end DTI: max 28% for housing
    const maxHousingPayment = grossMonthlyIncome * 0.28
    // Back-end DTI: max 36% for all debts
    const maxTotalDebtPayment = grossMonthlyIncome * 0.36
    const maxHousingFromBackend = maxTotalDebtPayment - monthlyDebts

    let availableForHousing = Math.min(maxHousingPayment, maxHousingFromBackend)
    if (availableForHousing < 0) availableForHousing = 0

    const monthlyRate = annualRate / 12
    const numPayments = loanTerm * 12
    const monthlyInsurance = annualInsurance / 12

    let pvFactor
    if (monthlyRate === 0) {
      pvFactor = numPayments
    } else {
      pvFactor = (1 - Math.pow(1 + monthlyRate, -numPayments)) / monthlyRate
    }

    const monthlyTaxRate = propertyTaxRate / 12
    const numerator = availableForHousing - monthlyInsurance - downPayment * monthlyTaxRate
    const denominator = 1 + pvFactor * monthlyTaxRate

    let availableForPI = 0
    if (denominator > 0 && numerator > 0) {
      availableForPI = numerator / denominator
    }

    let maxLoan = availableForPI * pvFactor
    if (maxLoan < 0) maxLoan = 0

    const maxHomePrice = maxLoan + downPayment
    const monthlyTax = maxHomePrice * monthlyTaxRate
    const totalMonthlyPayment = availableForPI + monthlyTax + monthlyInsurance

    const frontEndDTI = grossMonthlyIncome > 0 ? (totalMonthlyPayment / grossMonthlyIncome * 100).toFixed(1) : "0.0"
    const backEndDTI = grossMonthlyIncome > 0 ? ((totalMonthlyPayment + monthlyDebts) / grossMonthlyIncome * 100).toFixed(1) : "0.0"

    this.maxHomePriceTarget.textContent = this.formatCurrency(maxHomePrice)
    this.maxLoanAmountTarget.textContent = this.formatCurrency(maxLoan)
    this.monthlyPITarget.textContent = this.formatCurrency(availableForPI)
    this.monthlyTaxTarget.textContent = this.formatCurrency(monthlyTax)
    this.monthlyInsuranceTarget.textContent = this.formatCurrency(monthlyInsurance)
    this.totalMonthlyPaymentTarget.textContent = this.formatCurrency(totalMonthlyPayment)
    this.frontEndDTITarget.textContent = `${frontEndDTI}%`
    this.backEndDTITarget.textContent = `${backEndDTI}%`
  }

  clearResults() {
    this.maxHomePriceTarget.textContent = "$0.00"
    this.maxLoanAmountTarget.textContent = "$0.00"
    this.monthlyPITarget.textContent = "$0.00"
    this.monthlyTaxTarget.textContent = "$0.00"
    this.monthlyInsuranceTarget.textContent = "$0.00"
    this.totalMonthlyPaymentTarget.textContent = "$0.00"
    this.frontEndDTITarget.textContent = "0.0%"
    this.backEndDTITarget.textContent = "0.0%"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Max Home Price: ${this.maxHomePriceTarget.textContent}\nMax Loan Amount: ${this.maxLoanAmountTarget.textContent}\nMonthly P&I: ${this.monthlyPITarget.textContent}\nMonthly Tax: ${this.monthlyTaxTarget.textContent}\nMonthly Insurance: ${this.monthlyInsuranceTarget.textContent}\nTotal Monthly Payment: ${this.totalMonthlyPaymentTarget.textContent}\nFront-End DTI: ${this.frontEndDTITarget.textContent}\nBack-End DTI: ${this.backEndDTITarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
