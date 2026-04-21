import { Controller } from "@hotwired/stimulus"
import { formatCurrency } from "utils/formatting"
import { toRealValue, applyInflationToggle } from "utils/inflation"

export default class extends Controller {
  static targets = [
    "goal", "years", "rate", "currentSavings",
    "monthlySavings", "totalContributions", "totalInterest",
    "inflationEnabled", "inflationField", "inflationRate",
    "realResults", "realGoal", "realTotalInterest"
  ]

  calculate() {
    const goal = parseFloat(this.goalTarget.value) || 0
    const years = parseInt(this.yearsTarget.value) || 0
    const annualRate = parseFloat(this.rateTarget.value) / 100
    const currentSavings = parseFloat(this.currentSavingsTarget.value) || 0

    if (goal <= 0 || years <= 0 || annualRate < 0) {
      this.clearResults()
      return
    }

    const monthlyRate = annualRate / 12
    const numMonths = years * 12
    let monthlySavings

    if (monthlyRate === 0) {
      monthlySavings = (goal - currentSavings) / numMonths
    } else {
      const futureCurrent = currentSavings * Math.pow(1 + monthlyRate, numMonths)
      const remaining = goal - futureCurrent
      monthlySavings = remaining * monthlyRate / (Math.pow(1 + monthlyRate, numMonths) - 1)
    }

    monthlySavings = Math.max(monthlySavings, 0)
    const totalContributions = monthlySavings * numMonths + currentSavings
    const totalInterest = goal - totalContributions

    this.monthlySavingsTarget.textContent = formatCurrency(monthlySavings)
    this.totalContributionsTarget.textContent = formatCurrency(totalContributions)
    this.totalInterestTarget.textContent = formatCurrency(totalInterest)

    const { enabled, rate } = applyInflationToggle(this)
    if (enabled) {
      if (this.hasRealGoalTarget) this.realGoalTarget.textContent = formatCurrency(toRealValue(goal, rate, years))
      if (this.hasRealTotalInterestTarget) this.realTotalInterestTarget.textContent = formatCurrency(toRealValue(totalInterest, rate, years))
    }
  }

  clearResults() {
    this.monthlySavingsTarget.textContent = "$0.00"
    this.totalContributionsTarget.textContent = "$0.00"
    this.totalInterestTarget.textContent = "$0.00"
    if (this.hasRealGoalTarget) this.realGoalTarget.textContent = "$0.00"
    if (this.hasRealTotalInterestTarget) this.realTotalInterestTarget.textContent = "$0.00"
    applyInflationToggle(this)
  }

  copy(event) {
    const text = `Monthly Savings Needed: ${this.monthlySavingsTarget.textContent}\nTotal Contributions: ${this.totalContributionsTarget.textContent}\nTotal Interest Earned: ${this.totalInterestTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
