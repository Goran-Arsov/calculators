import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "buyPrice", "sellPrice", "shares", "buyCommission", "sellCommission", "holdingPeriod",
    "totalCost", "totalRevenue", "profit", "roi", "percentChange",
    "totalFees", "capitalGainsTax", "afterTaxProfit", "breakEvenPrice"
  ]

  calculate() {
    const buyPrice = parseFloat(this.buyPriceTarget.value) || 0
    const sellPrice = parseFloat(this.sellPriceTarget.value) || 0
    const shares = parseFloat(this.sharesTarget.value) || 0
    const buyCommission = parseFloat(this.buyCommissionTarget.value) || 0
    const sellCommission = parseFloat(this.sellCommissionTarget.value) || 0
    const holdingPeriod = this.holdingPeriodTarget.value || "long"

    if (buyPrice <= 0 || sellPrice <= 0 || shares <= 0) {
      this.clearResults()
      return
    }

    const totalCost = (buyPrice * shares) + buyCommission
    const totalRevenue = (sellPrice * shares) - sellCommission
    const totalFees = buyCommission + sellCommission
    const profit = totalRevenue - totalCost
    const roi = totalCost > 0 ? (profit / totalCost * 100) : 0
    const percentChange = buyPrice > 0 ? ((sellPrice - buyPrice) / buyPrice * 100) : 0

    const cgRate = holdingPeriod === "short" ? 0.24 : 0.15
    const capitalGainsTax = profit > 0 ? profit * cgRate : 0
    const afterTaxProfit = profit - capitalGainsTax
    const breakEvenPrice = shares > 0 ? (totalCost + sellCommission) / shares : 0

    this.totalCostTarget.textContent = this.formatCurrency(totalCost)
    this.totalRevenueTarget.textContent = this.formatCurrency(totalRevenue)
    this.profitTarget.textContent = this.formatCurrency(profit)
    this.profitTarget.className = profit >= 0
      ? "text-xl font-bold text-green-600 dark:text-green-400"
      : "text-xl font-bold text-red-600 dark:text-red-400"
    this.roiTarget.textContent = roi.toFixed(2) + "%"
    this.percentChangeTarget.textContent = percentChange.toFixed(2) + "%"
    this.totalFeesTarget.textContent = this.formatCurrency(totalFees)
    this.capitalGainsTaxTarget.textContent = this.formatCurrency(capitalGainsTax)
    this.afterTaxProfitTarget.textContent = this.formatCurrency(afterTaxProfit)
    this.breakEvenPriceTarget.textContent = this.formatCurrency(breakEvenPrice)
  }

  clearResults() {
    this.totalCostTarget.textContent = "$0.00"
    this.totalRevenueTarget.textContent = "$0.00"
    this.profitTarget.textContent = "$0.00"
    this.roiTarget.textContent = "0.00%"
    this.percentChangeTarget.textContent = "0.00%"
    this.totalFeesTarget.textContent = "$0.00"
    this.capitalGainsTaxTarget.textContent = "$0.00"
    this.afterTaxProfitTarget.textContent = "$0.00"
    this.breakEvenPriceTarget.textContent = "$0.00"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `Stock Profit Calculator Results\nTotal Cost: ${this.totalCostTarget.textContent}\nTotal Revenue: ${this.totalRevenueTarget.textContent}\nProfit/Loss: ${this.profitTarget.textContent}\nROI: ${this.roiTarget.textContent}\nCapital Gains Tax: ${this.capitalGainsTaxTarget.textContent}\nAfter-Tax Profit: ${this.afterTaxProfitTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
