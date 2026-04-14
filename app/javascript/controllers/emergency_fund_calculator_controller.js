import { Controller } from "@hotwired/stimulus"
import { formatCurrency, formatNumber } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "monthlyExpenses", "riskLevel", "currentSavings", "monthlyContribution",
    "targetFund", "monthsRecommended", "savingsGap",
    "monthsToGoal", "percentFunded"
  ]

  static riskMonths = { stable: 3, moderate: 6, high_risk: 9 }

  connect() {
    prefillFromUrl(this, { expenses: "monthlyExpenses", risk: "riskLevel", savings: "currentSavings", contribution: "monthlyContribution" })
    this.calculate()
  }

  calculate() {
    const monthlyExpenses = parseFloat(this.monthlyExpensesTarget.value) || 0
    const riskLevel = this.riskLevelTarget.value || "moderate"
    const currentSavings = parseFloat(this.currentSavingsTarget.value) || 0
    const monthlyContribution = parseFloat(this.monthlyContributionTarget.value) || 0

    if (monthlyExpenses <= 0) {
      this.clearResults()
      return
    }

    const monthsRecommended = this.constructor.riskMonths[riskLevel] || 6
    const targetFund = monthlyExpenses * monthsRecommended
    const savingsGap = Math.max(targetFund - currentSavings, 0)
    let percentFunded = targetFund > 0 ? (currentSavings / targetFund * 100) : 0
    if (currentSavings >= targetFund) percentFunded = Math.min(percentFunded, 100)

    let monthsToGoal
    if (savingsGap <= 0) {
      monthsToGoal = 0
    } else if (monthlyContribution > 0) {
      monthsToGoal = Math.ceil(savingsGap / monthlyContribution)
    } else {
      monthsToGoal = null
    }

    this.targetFundTarget.textContent = formatCurrency(targetFund)
    this.monthsRecommendedTarget.textContent = monthsRecommended
    this.savingsGapTarget.textContent = formatCurrency(savingsGap)
    this.monthsToGoalTarget.textContent = monthsToGoal !== null ? monthsToGoal : "N/A"
    this.percentFundedTarget.textContent = formatNumber(percentFunded, 1) + "%"
  }

  clearResults() {
    this.targetFundTarget.textContent = "$0.00"
    this.monthsRecommendedTarget.textContent = "0"
    this.savingsGapTarget.textContent = "$0.00"
    this.monthsToGoalTarget.textContent = "0"
    this.percentFundedTarget.textContent = "0.0%"
  }

  copy() {
    const text = `Emergency Fund Calculator Results\nTarget Fund: ${this.targetFundTarget.textContent}\nMonths Recommended: ${this.monthsRecommendedTarget.textContent}\nSavings Gap: ${this.savingsGapTarget.textContent}\nMonths to Goal: ${this.monthsToGoalTarget.textContent}\nPercent Funded: ${this.percentFundedTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
