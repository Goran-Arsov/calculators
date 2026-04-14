import { Controller } from "@hotwired/stimulus"
import { formatCurrency } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "monthlyIncome", "monthlyDebts", "savingsGoalPercent",
    "maxRent30Rule", "maxRentAdjusted", "needsBudget", "wantsBudget", "savingsBudget"
  ]

  connect() {
    prefillFromUrl(this, {
      income: "monthlyIncome",
      debts: "monthlyDebts",
      savings_pct: "savingsGoalPercent"
    })
    this.calculate()
  }

  calculate() {
    const income = parseFloat(this.monthlyIncomeTarget.value) || 0
    const debts = parseFloat(this.monthlyDebtsTarget.value) || 0
    const savingsPct = parseFloat(this.savingsGoalPercentTarget.value) || 0

    if (income <= 0) {
      this.clearResults()
      return
    }

    const maxRent30 = income * 0.30
    const needsBudget = income * 0.50
    const wantsBudget = income * 0.30
    const savingsBudget = income * 0.20

    const savingsAmount = income * (savingsPct / 100)
    let maxRentAdjusted = income - debts - savingsAmount
    if (maxRentAdjusted < 0) maxRentAdjusted = 0

    this.maxRent30RuleTarget.textContent = formatCurrency(maxRent30)
    this.maxRentAdjustedTarget.textContent = formatCurrency(maxRentAdjusted)
    this.needsBudgetTarget.textContent = formatCurrency(needsBudget)
    this.wantsBudgetTarget.textContent = formatCurrency(wantsBudget)
    this.savingsBudgetTarget.textContent = formatCurrency(savingsBudget)
  }

  clearResults() {
    this.maxRent30RuleTarget.textContent = "$0.00"
    this.maxRentAdjustedTarget.textContent = "$0.00"
    this.needsBudgetTarget.textContent = "$0.00"
    this.wantsBudgetTarget.textContent = "$0.00"
    this.savingsBudgetTarget.textContent = "$0.00"
  }

  copy(event) {
    const text = `Max Rent (30% Rule): ${this.maxRent30RuleTarget.textContent}\nMax Rent (Adjusted): ${this.maxRentAdjustedTarget.textContent}\nNeeds Budget: ${this.needsBudgetTarget.textContent}\nWants Budget: ${this.wantsBudgetTarget.textContent}\nSavings Budget: ${this.savingsBudgetTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
