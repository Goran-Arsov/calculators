import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "buyPrice", "sellPrice", "quantity", "buyFeePercent", "sellFeePercent", "holdingPeriod",
    "costBasis", "totalCost", "grossRevenue", "netRevenue",
    "profit", "roi", "percentChange", "totalFees",
    "capitalGainsTax", "afterTaxProfit", "breakEvenPrice"
  ]

  calculate() {
    const buyPrice = parseFloat(this.buyPriceTarget.value) || 0
    const sellPrice = parseFloat(this.sellPriceTarget.value) || 0
    const quantity = parseFloat(this.quantityTarget.value) || 0
    const buyFeePct = (parseFloat(this.buyFeePercentTarget.value) || 0) / 100
    const sellFeePct = (parseFloat(this.sellFeePercentTarget.value) || 0) / 100
    const holdingPeriod = this.holdingPeriodTarget.value || "long"

    if (buyPrice <= 0 || sellPrice <= 0 || quantity <= 0) {
      this.clearResults()
      return
    }

    const costBasis = buyPrice * quantity
    const buyFee = costBasis * buyFeePct
    const totalCost = costBasis + buyFee

    const grossRevenue = sellPrice * quantity
    const sellFee = grossRevenue * sellFeePct
    const netRevenue = grossRevenue - sellFee

    const totalFees = buyFee + sellFee
    const profit = netRevenue - totalCost
    const roi = totalCost > 0 ? (profit / totalCost * 100) : 0
    const percentChange = buyPrice > 0 ? ((sellPrice - buyPrice) / buyPrice * 100) : 0

    const taxRate = holdingPeriod === "short" ? 0.24 : 0.15
    const capitalGainsTax = profit > 0 ? profit * taxRate : 0
    const afterTaxProfit = profit - capitalGainsTax
    const breakEvenPrice = quantity > 0 ? (totalCost + totalCost * sellFeePct) / quantity : 0

    this.costBasisTarget.textContent = this.formatCurrency(costBasis)
    this.totalCostTarget.textContent = this.formatCurrency(totalCost)
    this.grossRevenueTarget.textContent = this.formatCurrency(grossRevenue)
    this.netRevenueTarget.textContent = this.formatCurrency(netRevenue)
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
    this.costBasisTarget.textContent = "$0.00"
    this.totalCostTarget.textContent = "$0.00"
    this.grossRevenueTarget.textContent = "$0.00"
    this.netRevenueTarget.textContent = "$0.00"
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
    const text = `Crypto Profit Calculator Results\nCost Basis: ${this.costBasisTarget.textContent}\nTotal Cost (incl. fees): ${this.totalCostTarget.textContent}\nNet Revenue: ${this.netRevenueTarget.textContent}\nProfit/Loss: ${this.profitTarget.textContent}\nROI: ${this.roiTarget.textContent}\nCapital Gains Tax: ${this.capitalGainsTaxTarget.textContent}\nAfter-Tax Profit: ${this.afterTaxProfitTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
