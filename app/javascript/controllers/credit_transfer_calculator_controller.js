import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalCreditsEarned", "transferableCredits", "degreeCreditsRequired",
    "costPerCreditOld", "costPerCreditNew", "creditsPerSemester",
    "creditsLost", "transferRate", "remainingCredits",
    "remainingSemesters", "remainingYears",
    "costOfRemaining", "costIfNoTransfer", "costSavings",
    "timeSavedSemesters", "valueOfLostCredits"
  ]

  calculate() {
    const totalEarned = parseInt(this.totalCreditsEarnedTarget.value) || 0
    const transferable = parseInt(this.transferableCreditsTarget.value) || 0
    const required = parseInt(this.degreeCreditsRequiredTarget.value) || 120
    const costOld = parseFloat(this.costPerCreditOldTarget.value) || 0
    const costNew = parseFloat(this.costPerCreditNewTarget.value) || 0
    const perSemester = parseInt(this.creditsPerSemesterTarget.value) || 15

    if (totalEarned <= 0 || costNew <= 0) {
      this.clearResults()
      return
    }

    const creditsLost = totalEarned - transferable
    const transferRate = totalEarned > 0 ? (transferable / totalEarned * 100) : 0
    const remaining = Math.max(required - transferable, 0)
    const remainingSemesters = perSemester > 0 ? Math.ceil(remaining / perSemester) : 0
    const remainingYears = Math.ceil(remainingSemesters / 2)
    const costOfRemaining = remaining * costNew
    const costIfNoTransfer = required * costNew
    const costSavings = costIfNoTransfer - costOfRemaining
    const timeSaved = perSemester > 0 ? Math.floor(transferable / perSemester) : 0
    const lostValue = creditsLost * costOld

    this.creditsLostTarget.textContent = creditsLost
    this.transferRateTarget.textContent = transferRate.toFixed(1) + "%"
    this.remainingCreditsTarget.textContent = remaining
    this.remainingSemestersTarget.textContent = remainingSemesters
    this.remainingYearsTarget.textContent = remainingYears + (remainingYears === 1 ? " year" : " years")
    this.costOfRemainingTarget.textContent = this.formatCurrency(costOfRemaining)
    this.costIfNoTransferTarget.textContent = this.formatCurrency(costIfNoTransfer)
    this.costSavingsTarget.textContent = this.formatCurrency(costSavings)
    this.timeSavedSemestersTarget.textContent = timeSaved + (timeSaved === 1 ? " semester" : " semesters")
    this.valueOfLostCreditsTarget.textContent = this.formatCurrency(lostValue)
  }

  clearResults() {
    this.creditsLostTarget.textContent = "0"
    this.transferRateTarget.textContent = "0%"
    this.remainingCreditsTarget.textContent = "0"
    this.remainingSemestersTarget.textContent = "0"
    this.remainingYearsTarget.textContent = "0 years"
    this.costOfRemainingTarget.textContent = "$0.00"
    this.costIfNoTransferTarget.textContent = "$0.00"
    this.costSavingsTarget.textContent = "$0.00"
    this.timeSavedSemestersTarget.textContent = "0 semesters"
    this.valueOfLostCreditsTarget.textContent = "$0.00"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Credit Transfer Calculator Results\nTransfer Rate: ${this.transferRateTarget.textContent}\nRemaining Credits: ${this.remainingCreditsTarget.textContent}\nRemaining Time: ${this.remainingYearsTarget.textContent}\nCost Savings: ${this.costSavingsTarget.textContent}\nTime Saved: ${this.timeSavedSemestersTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
