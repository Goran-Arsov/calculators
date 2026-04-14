import { Controller } from "@hotwired/stimulus"
import { formatCurrency } from "utils/formatting"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = [
    "grossRevenue", "businessExpenses", "taxRate", "hoursPerWeek",
    "netProfit", "selfEmploymentTax", "incomeTaxEstimate",
    "annualTakeHome", "monthlyTakeHome", "effectiveHourlyRate"
  ]

  static SE_TAX_FACTOR = 0.9235
  static SE_TAX_RATE = 0.153

  connect() {
    prefillFromUrl(this, { gross_revenue: "grossRevenue", business_expenses: "businessExpenses", tax_rate: "taxRate", hours: "hoursPerWeek" })
    this.calculate()
  }

  calculate() {
    const grossRevenue = parseFloat(this.grossRevenueTarget.value) || 0
    const businessExpenses = parseFloat(this.businessExpensesTarget.value) || 0
    const taxRatePercent = parseFloat(this.taxRateTarget.value) || 0
    const hoursPerWeek = parseFloat(this.hoursPerWeekTarget.value) || 0

    if (hoursPerWeek <= 0) {
      this.clearResults()
      return
    }

    const netProfit = grossRevenue - businessExpenses
    const seTaxable = netProfit * this.constructor.SE_TAX_FACTOR
    const selfEmploymentTax = Math.max(seTaxable * this.constructor.SE_TAX_RATE, 0)
    const incomeTax = Math.max(netProfit * (taxRatePercent / 100), 0)
    const annualTakeHome = netProfit - selfEmploymentTax - incomeTax
    const monthlyTakeHome = annualTakeHome / 12
    const annualHours = hoursPerWeek * 52
    const effectiveHourlyRate = annualHours > 0 ? annualTakeHome / annualHours : 0

    this.netProfitTarget.textContent = formatCurrency(netProfit)
    this.selfEmploymentTaxTarget.textContent = formatCurrency(selfEmploymentTax)
    this.incomeTaxEstimateTarget.textContent = formatCurrency(incomeTax)
    this.annualTakeHomeTarget.textContent = formatCurrency(annualTakeHome)
    this.monthlyTakeHomeTarget.textContent = formatCurrency(monthlyTakeHome)
    this.effectiveHourlyRateTarget.textContent = formatCurrency(effectiveHourlyRate)
  }

  clearResults() {
    this.netProfitTarget.textContent = "$0.00"
    this.selfEmploymentTaxTarget.textContent = "$0.00"
    this.incomeTaxEstimateTarget.textContent = "$0.00"
    this.annualTakeHomeTarget.textContent = "$0.00"
    this.monthlyTakeHomeTarget.textContent = "$0.00"
    this.effectiveHourlyRateTarget.textContent = "$0.00"
  }

  copy() {
    const text = `Side Hustle Calculator Results\nNet Profit: ${this.netProfitTarget.textContent}\nSelf-Employment Tax: ${this.selfEmploymentTaxTarget.textContent}\nIncome Tax Estimate: ${this.incomeTaxEstimateTarget.textContent}\nAnnual Take-Home: ${this.annualTakeHomeTarget.textContent}\nMonthly Take-Home: ${this.monthlyTakeHomeTarget.textContent}\nEffective Hourly Rate: ${this.effectiveHourlyRateTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
