import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "currentBalance", "monthlyContribution", "annualReturn",
    "yearsUntilCollege", "stateTaxRate",
    "finalBalance", "totalContributions", "totalEarnings",
    "taxFreeEarnings", "taxDeduction",
    "projected4YearCost", "coveragePercentage",
    "projectionTable"
  ]

  calculate() {
    const currentBalance = parseFloat(this.currentBalanceTarget.value) || 0
    const monthly = parseFloat(this.monthlyContributionTarget.value) || 0
    const annualReturn = (parseFloat(this.annualReturnTarget.value) || 0) / 100
    const years = parseInt(this.yearsUntilCollegeTarget.value) || 0
    const stateTax = (parseFloat(this.stateTaxRateTarget.value) || 0) / 100

    if (monthly <= 0 || years <= 0) {
      this.clearResults()
      return
    }

    const monthlyRate = annualReturn / 12
    let balance = currentBalance
    let totalContributions = currentBalance
    let totalEarnings = 0
    const rows = []

    for (let y = 0; y < years; y++) {
      const startBalance = balance
      let yearContributions = 0
      let yearEarnings = 0

      for (let m = 0; m < 12; m++) {
        const interest = balance * monthlyRate
        balance += interest + monthly
        yearContributions += monthly
        yearEarnings += interest
      }

      totalContributions += yearContributions
      totalEarnings += yearEarnings

      rows.push({
        year: y + 1,
        start: startBalance,
        contributions: yearContributions,
        earnings: yearEarnings,
        end: balance
      })
    }

    const annualContribution = monthly * 12
    const totalTaxDeduction = annualContribution * stateTax * years

    // Projected college cost
    const avgAnnualCost = 25000
    const collegeInflation = 0.05
    const projectedAnnualCost = avgAnnualCost * Math.pow(1 + collegeInflation, years)
    const projected4Year = projectedAnnualCost * 4
    const coverage = projected4Year > 0 ? (balance / projected4Year) * 100 : 0

    this.finalBalanceTarget.textContent = this.formatCurrency(balance)
    this.totalContributionsTarget.textContent = this.formatCurrency(totalContributions)
    this.totalEarningsTarget.textContent = this.formatCurrency(totalEarnings)
    this.taxFreeEarningsTarget.textContent = this.formatCurrency(totalEarnings)
    this.taxDeductionTarget.textContent = this.formatCurrency(totalTaxDeduction)
    this.projected4YearCostTarget.textContent = this.formatCurrency(projected4Year)
    this.coveragePercentageTarget.textContent = coverage.toFixed(1) + "%"

    // Build projection table
    if (this.hasProjectionTableTarget) {
      let tableHtml = ""
      for (const row of rows) {
        tableHtml += `<tr class="border-t border-gray-200 dark:border-gray-700">
          <td class="py-2 px-3 text-sm text-gray-700 dark:text-gray-300">${row.year}</td>
          <td class="py-2 px-3 text-sm text-gray-700 dark:text-gray-300">${this.formatCurrency(row.contributions)}</td>
          <td class="py-2 px-3 text-sm text-gray-700 dark:text-gray-300">${this.formatCurrency(row.earnings)}</td>
          <td class="py-2 px-3 text-sm font-semibold text-gray-900 dark:text-white">${this.formatCurrency(row.end)}</td>
        </tr>`
      }
      this.projectionTableTarget.innerHTML = tableHtml
    }
  }

  clearResults() {
    this.finalBalanceTarget.textContent = "$0.00"
    this.totalContributionsTarget.textContent = "$0.00"
    this.totalEarningsTarget.textContent = "$0.00"
    this.taxFreeEarningsTarget.textContent = "$0.00"
    this.taxDeductionTarget.textContent = "$0.00"
    this.projected4YearCostTarget.textContent = "$0.00"
    this.coveragePercentageTarget.textContent = "0%"
    if (this.hasProjectionTableTarget) this.projectionTableTarget.innerHTML = ""
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `529 Tuition Savings Calculator Results\nFinal Balance: ${this.finalBalanceTarget.textContent}\nTotal Contributions: ${this.totalContributionsTarget.textContent}\nTax-Free Earnings: ${this.taxFreeEarningsTarget.textContent}\nState Tax Deduction: ${this.taxDeductionTarget.textContent}\nCoverage: ${this.coveragePercentageTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
