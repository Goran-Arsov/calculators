import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "annualRevenue", "employees", "netIncome",
    "resultRpe", "resultRpeMonthly", "resultRpeQuarterly", "resultPpe"
  ]

  calculate() {
    const annualRevenue = parseFloat(this.annualRevenueTarget.value) || 0
    const employees = parseInt(this.employeesTarget.value) || 0
    const netIncome = this.hasNetIncomeTarget ? (parseFloat(this.netIncomeTarget.value) || 0) : 0

    if (annualRevenue <= 0 || employees <= 0) {
      this.clearResults()
      return
    }

    const rpe = annualRevenue / employees
    const rpeMonthly = rpe / 12
    const rpeQuarterly = rpe / 4

    this.resultRpeTarget.textContent = "$" + this.formatCurrency(rpe)
    this.resultRpeMonthlyTarget.textContent = "$" + this.formatCurrency(rpeMonthly)
    this.resultRpeQuarterlyTarget.textContent = "$" + this.formatCurrency(rpeQuarterly)

    if (netIncome !== 0) {
      const ppe = netIncome / employees
      this.resultPpeTarget.textContent = "$" + this.formatCurrency(ppe)
    } else {
      this.resultPpeTarget.textContent = "\u2014"
    }
  }

  clearResults() {
    this.resultRpeTarget.textContent = "\u2014"
    this.resultRpeMonthlyTarget.textContent = "\u2014"
    this.resultRpeQuarterlyTarget.textContent = "\u2014"
    this.resultPpeTarget.textContent = "\u2014"
  }

  formatCurrency(n) {
    return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const rpe = this.resultRpeTarget.textContent
    const monthly = this.resultRpeMonthlyTarget.textContent
    const quarterly = this.resultRpeQuarterlyTarget.textContent
    const ppe = this.resultPpeTarget.textContent
    const text = `Revenue Per Employee: ${rpe}\nMonthly: ${monthly}\nQuarterly: ${quarterly}\nProfit Per Employee: ${ppe}`
    navigator.clipboard.writeText(text)
  }
}
