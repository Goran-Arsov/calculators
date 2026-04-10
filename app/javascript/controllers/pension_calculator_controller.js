import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "currentAge", "retirementAge", "currentSavings", "monthlyContribution",
    "returnRate", "inflationRate", "yearsInRetirement",
    "yearsToRetire", "nominalPot", "realPot", "totalContributions",
    "nominalMonthlyIncome", "realMonthlyIncome"
  ]

  connect() {
    if (prefillFromUrl(this, {
      age: "currentAge", retireAge: "retirementAge", savings: "currentSavings",
      monthly: "monthlyContribution", rate: "returnRate", inflation: "inflationRate",
      years: "yearsInRetirement"
    })) {
      this.calculate()
    } else {
      this.calculate()
    }
  }

  calculate() {
    const currentAge = parseInt(this.currentAgeTarget.value) || 0
    const retirementAge = parseInt(this.retirementAgeTarget.value) || 0
    const currentSavings = parseFloat(this.currentSavingsTarget.value) || 0
    const monthly = parseFloat(this.monthlyContributionTarget.value) || 0
    const annualReturn = parseFloat(this.returnRateTarget.value) / 100
    const annualInflation = parseFloat(this.inflationRateTarget.value) / 100
    const yearsInRetirement = parseInt(this.yearsInRetirementTarget.value) || 0

    if (currentAge <= 0 || retirementAge <= currentAge || annualReturn < 0 ||
        annualInflation < 0 || yearsInRetirement <= 0) {
      this.clearResults()
      return
    }

    const yearsToRetire = retirementAge - currentAge
    const monthsToRetire = yearsToRetire * 12
    const monthlyReturn = annualReturn / 12

    let nominalPot
    if (monthlyReturn === 0) {
      nominalPot = currentSavings + monthly * monthsToRetire
    } else {
      nominalPot = currentSavings * Math.pow(1 + monthlyReturn, monthsToRetire) +
                   monthly * (Math.pow(1 + monthlyReturn, monthsToRetire) - 1) / monthlyReturn
    }

    const inflationFactor = Math.pow(1 + annualInflation, yearsToRetire)
    const realPot = nominalPot / inflationFactor

    const retirementMonths = yearsInRetirement * 12
    const nominalMonthlyIncome = this.annuityPayment(nominalPot, monthlyReturn, retirementMonths)
    const realMonthlyIncome = nominalMonthlyIncome / inflationFactor

    const totalContributions = currentSavings + monthly * monthsToRetire

    this.yearsToRetireTarget.textContent = yearsToRetire
    this.nominalPotTarget.textContent = this.formatCurrency(nominalPot)
    this.realPotTarget.textContent = this.formatCurrency(realPot)
    this.totalContributionsTarget.textContent = this.formatCurrency(totalContributions)
    this.nominalMonthlyIncomeTarget.textContent = this.formatCurrency(nominalMonthlyIncome)
    this.realMonthlyIncomeTarget.textContent = this.formatCurrency(realMonthlyIncome)
  }

  annuityPayment(principal, monthlyRate, numMonths) {
    if (numMonths <= 0) return 0
    if (monthlyRate === 0) return principal / numMonths
    return principal * monthlyRate / (1 - Math.pow(1 + monthlyRate, -numMonths))
  }

  clearResults() {
    this.yearsToRetireTarget.textContent = "0"
    this.nominalPotTarget.textContent = "$0.00"
    this.realPotTarget.textContent = "$0.00"
    this.totalContributionsTarget.textContent = "$0.00"
    this.nominalMonthlyIncomeTarget.textContent = "$0.00"
    this.realMonthlyIncomeTarget.textContent = "$0.00"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Years to Retire: ${this.yearsToRetireTarget.textContent}
Projected Pension Pot (Nominal): ${this.nominalPotTarget.textContent}
Projected Pension Pot (Today's Money): ${this.realPotTarget.textContent}
Total Contributions: ${this.totalContributionsTarget.textContent}
Monthly Income (Nominal): ${this.nominalMonthlyIncomeTarget.textContent}
Monthly Income (Today's Money): ${this.realMonthlyIncomeTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
