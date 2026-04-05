import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "balance", "annualRate", "loanTermYears", "planType", "monthlyIncome",
    "incomeField", "monthlyPayment", "totalPaid", "totalInterest",
    "payoffMonths", "payoffDate", "forgivenAmount", "forgivenRow"
  ]

  calculate() {
    const balance = parseFloat(this.balanceTarget.value) || 0
    const annualRate = (parseFloat(this.annualRateTarget.value) || 0) / 100
    const loanTermYears = parseInt(this.loanTermYearsTarget.value) || 10
    const planType = this.planTypeTarget.value || "standard"
    const monthlyIncome = parseFloat(this.monthlyIncomeTarget.value) || 0

    // Show/hide income field based on plan type
    if (this.hasIncomeFieldTarget) {
      this.incomeFieldTarget.classList.toggle("hidden", planType !== "income_driven")
    }

    if (balance <= 0 || annualRate < 0 || loanTermYears <= 0) {
      this.clearResults()
      return
    }

    if (planType === "income_driven" && monthlyIncome <= 0) {
      this.clearResults()
      return
    }

    let result
    switch (planType) {
      case "graduated":
        result = this.calculateGraduated(balance, annualRate, loanTermYears)
        break
      case "extended":
        result = this.calculateExtended(balance, annualRate)
        break
      case "income_driven":
        result = this.calculateIncomeDriven(balance, annualRate, monthlyIncome)
        break
      default:
        result = this.calculateStandard(balance, annualRate, loanTermYears)
    }

    this.monthlyPaymentTarget.textContent = this.formatCurrency(result.monthlyPayment)
    this.totalPaidTarget.textContent = this.formatCurrency(result.totalPaid)
    this.totalInterestTarget.textContent = this.formatCurrency(result.totalInterest)
    this.payoffMonthsTarget.textContent = result.payoffMonths + " months"

    // Calculate payoff date
    const payoffDate = new Date()
    payoffDate.setMonth(payoffDate.getMonth() + result.payoffMonths)
    this.payoffDateTarget.textContent = payoffDate.toLocaleDateString("en-US", { month: "long", year: "numeric" })

    if (this.hasForgivenRowTarget && this.hasForgivenAmountTarget) {
      if (result.forgiven > 0) {
        this.forgivenRowTarget.classList.remove("hidden")
        this.forgivenAmountTarget.textContent = this.formatCurrency(result.forgiven)
      } else {
        this.forgivenRowTarget.classList.add("hidden")
      }
    }
  }

  calculateStandard(balance, annualRate, years) {
    const monthlyRate = annualRate / 12
    const n = years * 12
    let monthlyPayment
    if (monthlyRate === 0) {
      monthlyPayment = balance / n
    } else {
      monthlyPayment = balance * (monthlyRate * Math.pow(1 + monthlyRate, n)) /
                        (Math.pow(1 + monthlyRate, n) - 1)
    }
    const totalPaid = monthlyPayment * n
    return { monthlyPayment, totalPaid, totalInterest: totalPaid - balance, payoffMonths: n, forgiven: 0 }
  }

  calculateGraduated(balance, annualRate, years) {
    const monthlyRate = annualRate / 12
    const n = years * 12
    let standardPayment
    if (monthlyRate === 0) {
      standardPayment = balance / n
    } else {
      standardPayment = balance * (monthlyRate * Math.pow(1 + monthlyRate, n)) /
                          (Math.pow(1 + monthlyRate, n) - 1)
    }
    let payment = standardPayment * 0.60
    let bal = balance
    let totalPaid = 0
    let month = 0

    while (bal > 0.01 && month < n * 2) {
      if (month > 0 && month % 24 === 0) payment *= 1.10
      const interest = bal * monthlyRate
      const actual = Math.min(payment, bal + interest)
      bal -= (actual - interest)
      if (bal < 0.01) bal = 0
      totalPaid += actual
      month++
    }
    return { monthlyPayment: standardPayment * 0.60, totalPaid, totalInterest: totalPaid - balance, payoffMonths: month, forgiven: 0 }
  }

  calculateExtended(balance, annualRate) {
    const monthlyRate = annualRate / 12
    const n = 25 * 12
    let monthlyPayment
    if (monthlyRate === 0) {
      monthlyPayment = balance / n
    } else {
      monthlyPayment = balance * (monthlyRate * Math.pow(1 + monthlyRate, n)) /
                        (Math.pow(1 + monthlyRate, n) - 1)
    }
    const totalPaid = monthlyPayment * n
    return { monthlyPayment, totalPaid, totalInterest: totalPaid - balance, payoffMonths: n, forgiven: 0 }
  }

  calculateIncomeDriven(balance, annualRate, monthlyIncome) {
    const monthlyRate = annualRate / 12
    const annualIncome = monthlyIncome * 12
    const povertyLine = 22590
    const discretionary = Math.max(annualIncome - povertyLine * 1.5, 0)
    const payment = discretionary * 0.10 / 12
    const maxMonths = 240
    let bal = balance
    let totalPaid = 0
    let month = 0

    while (bal > 0.01 && month < maxMonths) {
      const interest = bal * monthlyRate
      const actual = Math.min(payment, bal + interest)
      if (actual < interest) {
        bal += (interest - actual)
      } else {
        bal -= (actual - interest)
      }
      if (bal < 0.01) bal = 0
      totalPaid += actual
      month++
    }

    return { monthlyPayment: payment, totalPaid, totalInterest: totalPaid - balance + Math.max(bal, 0), payoffMonths: month, forgiven: Math.max(bal, 0) }
  }

  clearResults() {
    this.monthlyPaymentTarget.textContent = "$0.00"
    this.totalPaidTarget.textContent = "$0.00"
    this.totalInterestTarget.textContent = "$0.00"
    this.payoffMonthsTarget.textContent = "0 months"
    this.payoffDateTarget.textContent = "N/A"
    if (this.hasForgivenRowTarget) this.forgivenRowTarget.classList.add("hidden")
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Student Loan Calculator Results\nMonthly Payment: ${this.monthlyPaymentTarget.textContent}\nTotal Paid: ${this.totalPaidTarget.textContent}\nTotal Interest: ${this.totalInterestTarget.textContent}\nPayoff: ${this.payoffMonthsTarget.textContent} (${this.payoffDateTarget.textContent})`
    navigator.clipboard.writeText(text)
  }
}
