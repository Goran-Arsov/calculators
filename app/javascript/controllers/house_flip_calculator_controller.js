import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "purchasePrice", "renovationCost", "afterRepairValue",
    "holdingMonths", "holdingCostMonthly",
    "closingCostBuyPercent", "closingCostSellPercent",
    "closingCostsBuy", "closingCostsSell", "totalHoldingCosts",
    "totalInvestment", "totalCosts", "netProfit", "roi",
    "annualizedRoi", "maxPurchase70Rule"
  ]

  calculate() {
    const purchasePrice = parseFloat(this.purchasePriceTarget.value) || 0
    const renovationCost = parseFloat(this.renovationCostTarget.value) || 0
    const arv = parseFloat(this.afterRepairValueTarget.value) || 0
    const holdingMonths = parseInt(this.holdingMonthsTarget.value) || 6
    const holdingCostMonthly = parseFloat(this.holdingCostMonthlyTarget.value) || 0
    const closingBuyPct = (parseFloat(this.closingCostBuyPercentTarget.value) || 2) / 100
    const closingSellPct = (parseFloat(this.closingCostSellPercentTarget.value) || 6) / 100

    if (purchasePrice <= 0 || arv <= 0) {
      this.clearResults()
      return
    }

    const closingCostsBuy = purchasePrice * closingBuyPct
    const closingCostsSell = arv * closingSellPct
    const totalHoldingCosts = holdingCostMonthly * holdingMonths
    const totalInvestment = purchasePrice + renovationCost + closingCostsBuy + totalHoldingCosts
    const totalCosts = totalInvestment + closingCostsSell
    const netProfit = arv - totalCosts
    const roi = totalInvestment > 0 ? (netProfit / totalInvestment * 100) : 0
    const annualizedRoi = holdingMonths > 0 ? roi * (12 / holdingMonths) : 0
    const maxPurchase70Rule = arv * 0.70 - renovationCost

    this.closingCostsBuyTarget.textContent = this.formatCurrency(closingCostsBuy)
    this.closingCostsSellTarget.textContent = this.formatCurrency(closingCostsSell)
    this.totalHoldingCostsTarget.textContent = this.formatCurrency(totalHoldingCosts)
    this.totalInvestmentTarget.textContent = this.formatCurrency(totalInvestment)
    this.totalCostsTarget.textContent = this.formatCurrency(totalCosts)
    this.netProfitTarget.textContent = this.formatCurrency(netProfit)
    this.netProfitTarget.className = netProfit >= 0
      ? "text-xl font-bold text-green-600 dark:text-green-400"
      : "text-xl font-bold text-red-600 dark:text-red-400"
    this.roiTarget.textContent = roi.toFixed(2) + "%"
    this.annualizedRoiTarget.textContent = annualizedRoi.toFixed(2) + "%"
    this.maxPurchase70RuleTarget.textContent = this.formatCurrency(maxPurchase70Rule)
  }

  clearResults() {
    this.closingCostsBuyTarget.textContent = "$0.00"
    this.closingCostsSellTarget.textContent = "$0.00"
    this.totalHoldingCostsTarget.textContent = "$0.00"
    this.totalInvestmentTarget.textContent = "$0.00"
    this.totalCostsTarget.textContent = "$0.00"
    this.netProfitTarget.textContent = "$0.00"
    this.roiTarget.textContent = "0.00%"
    this.annualizedRoiTarget.textContent = "0.00%"
    this.maxPurchase70RuleTarget.textContent = "$0.00"
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  copy() {
    const text = `House Flip Calculator Results\nTotal Investment: ${this.totalInvestmentTarget.textContent}\nNet Profit: ${this.netProfitTarget.textContent}\nROI: ${this.roiTarget.textContent}\nAnnualized ROI: ${this.annualizedRoiTarget.textContent}\n70% Rule Max Purchase: ${this.maxPurchase70RuleTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
