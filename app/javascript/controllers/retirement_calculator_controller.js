import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["currentAge", "retirementAge", "currentSavings", "monthlyContribution", "rate", "projectedSavings", "monthlyIncome", "yearsToRetire"]

  connect() {
    prefillFromUrl(this, { age: "currentAge", retireAge: "retirementAge", savings: "currentSavings", monthly: "monthlyContribution", rate: "rate" })
    this.calculate()
  }

  calculate() {
    const currentAge = parseInt(this.currentAgeTarget.value) || 0
    const retirementAge = parseInt(this.retirementAgeTarget.value) || 0
    const currentSavings = parseFloat(this.currentSavingsTarget.value) || 0
    const monthly = parseFloat(this.monthlyContributionTarget.value) || 0
    const annualRate = parseFloat(this.rateTarget.value) / 100

    if (currentAge <= 0 || retirementAge <= currentAge || annualRate < 0) {
      this.clearResults()
      return
    }

    const yearsToRetire = retirementAge - currentAge
    const monthlyRate = annualRate / 12
    const numMonths = yearsToRetire * 12
    let projectedSavings

    if (monthlyRate === 0) {
      projectedSavings = currentSavings + monthly * numMonths
    } else {
      projectedSavings = currentSavings * Math.pow(1 + monthlyRate, numMonths) +
                          monthly * (Math.pow(1 + monthlyRate, numMonths) - 1) / monthlyRate
    }

    const monthlyIncome = projectedSavings * 0.04 / 12

    this.projectedSavingsTarget.textContent = this.formatCurrency(projectedSavings)
    this.monthlyIncomeTarget.textContent = this.formatCurrency(monthlyIncome)
    this.yearsToRetireTarget.textContent = yearsToRetire
  }

  clearResults() {
    this.projectedSavingsTarget.textContent = "$0.00"
    this.monthlyIncomeTarget.textContent = "$0.00"
    this.yearsToRetireTarget.textContent = "0"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Projected Savings: ${this.projectedSavingsTarget.textContent}\nMonthly Retirement Income: ${this.monthlyIncomeTarget.textContent}\nYears to Retire: ${this.yearsToRetireTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
