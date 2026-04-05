import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalCost", "servings", "markupPercent",
    "resultCostPerServing", "resultSellingPrice", "resultProfitPerServing",
    "resultTotalRevenue", "resultTotalProfit"
  ]

  calculate() {
    const totalCost = parseFloat(this.totalCostTarget.value) || 0
    const servings = parseFloat(this.servingsTarget.value) || 0
    const markupPct = parseFloat(this.markupPercentTarget.value) || 0

    if (totalCost <= 0 || servings <= 0) {
      this.clearResults()
      return
    }

    const costPerServing = totalCost / servings
    const sellingPrice = costPerServing * (1 + markupPct / 100)
    const profitPerServing = sellingPrice - costPerServing
    const totalRevenue = sellingPrice * servings
    const totalProfit = profitPerServing * servings

    this.resultCostPerServingTarget.textContent = this.formatCurrency(costPerServing)
    this.resultSellingPriceTarget.textContent = this.formatCurrency(sellingPrice)
    this.resultProfitPerServingTarget.textContent = this.formatCurrency(profitPerServing)
    this.resultTotalRevenueTarget.textContent = this.formatCurrency(totalRevenue)
    this.resultTotalProfitTarget.textContent = this.formatCurrency(totalProfit)
  }

  clearResults() {
    const targets = [
      "resultCostPerServing", "resultSellingPrice", "resultProfitPerServing",
      "resultTotalRevenue", "resultTotalProfit"
    ]
    targets.forEach(t => {
      if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) {
        this[`${t}Target`].textContent = "\u2014"
      }
    })
  }

  copy() {
    const text = [
      `Cost Per Serving: ${this.resultCostPerServingTarget.textContent}`,
      `Selling Price: ${this.resultSellingPriceTarget.textContent}`,
      `Profit Per Serving: ${this.resultProfitPerServingTarget.textContent}`,
      `Total Revenue: ${this.resultTotalRevenueTarget.textContent}`,
      `Total Profit: ${this.resultTotalProfitTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }
}
