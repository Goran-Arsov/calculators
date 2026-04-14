import { Controller } from "@hotwired/stimulus"
import { formatCurrency } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "targetIncome", "annualExpenses", "billableHours", "weeksVacation",
    "taxRate", "profitMargin",
    "hourlyRate", "dailyRate", "weeklyRate", "monthlyRate",
    "annualRevenue", "billableHoursTotal", "estimatedTaxes"
  ]

  connect() {
    prefillFromUrl(this, {
      targetIncome: "targetIncome", annualExpenses: "annualExpenses",
      billableHours: "billableHours", weeksVacation: "weeksVacation",
      taxRate: "taxRate", profitMargin: "profitMargin"
    })
    this.calculate()
  }

  calculate() {
    const targetIncome = parseFloat(this.targetIncomeTarget.value) || 0
    const expenses = parseFloat(this.annualExpensesTarget.value) || 0
    const billableHours = parseFloat(this.billableHoursTarget.value) || 0
    const weeksVacation = parseInt(this.weeksVacationTarget.value) || 0
    const taxRate = parseFloat(this.taxRateTarget.value) / 100 || 0
    const profitMarginPct = parseFloat(this.profitMarginTarget.value) / 100 || 0

    if (targetIncome <= 0 || billableHours <= 0 || weeksVacation >= 52) {
      this.clearResults()
      return
    }

    const workingWeeks = 52 - weeksVacation
    const annualBillableHours = billableHours * workingWeeks

    const preTaxIncome = taxRate < 1 ? targetIncome / (1 - taxRate) : targetIncome
    const totalNeeded = preTaxIncome + expenses
    const totalWithMargin = totalNeeded * (1 + profitMarginPct)

    const hourlyRate = totalWithMargin / annualBillableHours
    const dailyRate = hourlyRate * 8
    const weeklyRate = hourlyRate * billableHours
    const monthlyRate = totalWithMargin / 12

    const estimatedTaxes = preTaxIncome * taxRate

    this.hourlyRateTarget.textContent = formatCurrency(hourlyRate)
    this.dailyRateTarget.textContent = formatCurrency(dailyRate)
    this.weeklyRateTarget.textContent = formatCurrency(weeklyRate)
    this.monthlyRateTarget.textContent = formatCurrency(monthlyRate)
    this.annualRevenueTarget.textContent = formatCurrency(totalWithMargin)
    this.billableHoursTotalTarget.textContent = Math.round(annualBillableHours)
    this.estimatedTaxesTarget.textContent = formatCurrency(estimatedTaxes)
  }

  clearResults() {
    this.hourlyRateTarget.textContent = "$0.00"
    this.dailyRateTarget.textContent = "$0.00"
    this.weeklyRateTarget.textContent = "$0.00"
    this.monthlyRateTarget.textContent = "$0.00"
    this.annualRevenueTarget.textContent = "$0.00"
    this.billableHoursTotalTarget.textContent = "0"
    this.estimatedTaxesTarget.textContent = "$0.00"
  }

  copy(event) {
    const text = `Hourly Rate: ${this.hourlyRateTarget.textContent}\nDaily Rate: ${this.dailyRateTarget.textContent}\nMonthly Rate: ${this.monthlyRateTarget.textContent}\nAnnual Revenue: ${this.annualRevenueTarget.textContent}`
    navigator.clipboard.writeText(text).then(() => {
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 2000)
    })
  }
}
