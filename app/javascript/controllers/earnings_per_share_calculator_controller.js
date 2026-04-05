import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "netIncome", "preferredDividends", "sharesOutstanding", "stockPrice",
    "resultEps", "resultEarningsAvailable", "resultPeRatio", "resultEarningsYield"
  ]

  calculate() {
    const netIncome = parseFloat(this.netIncomeTarget.value) || 0
    const preferredDividends = parseFloat(this.preferredDividendsTarget.value) || 0
    const sharesOutstanding = parseInt(this.sharesOutstandingTarget.value) || 0
    const stockPrice = this.hasStockPriceTarget ? (parseFloat(this.stockPriceTarget.value) || 0) : 0

    if (sharesOutstanding <= 0) {
      this.clearResults()
      return
    }

    const earningsAvailable = netIncome - preferredDividends
    const eps = earningsAvailable / sharesOutstanding

    this.resultEpsTarget.textContent = "$" + this.fmt(eps)
    this.resultEarningsAvailableTarget.textContent = "$" + this.formatCurrency(earningsAvailable)

    if (stockPrice > 0 && eps > 0) {
      const peRatio = stockPrice / eps
      const earningsYield = (eps / stockPrice) * 100
      this.resultPeRatioTarget.textContent = this.fmt(peRatio) + "x"
      this.resultEarningsYieldTarget.textContent = this.fmt(earningsYield) + "%"
    } else {
      this.resultPeRatioTarget.textContent = "\u2014"
      this.resultEarningsYieldTarget.textContent = "\u2014"
    }
  }

  clearResults() {
    this.resultEpsTarget.textContent = "\u2014"
    this.resultEarningsAvailableTarget.textContent = "\u2014"
    this.resultPeRatioTarget.textContent = "\u2014"
    this.resultEarningsYieldTarget.textContent = "\u2014"
  }

  formatCurrency(n) {
    return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const eps = this.resultEpsTarget.textContent
    const earnings = this.resultEarningsAvailableTarget.textContent
    const pe = this.resultPeRatioTarget.textContent
    const ey = this.resultEarningsYieldTarget.textContent
    const text = `Basic EPS: ${eps}\nEarnings Available: ${earnings}\nP/E Ratio: ${pe}\nEarnings Yield: ${ey}`
    navigator.clipboard.writeText(text)
  }
}
