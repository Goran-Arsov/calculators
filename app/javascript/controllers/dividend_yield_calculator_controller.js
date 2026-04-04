import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "priceForYield", "dividendForYield", "resultYield",
    "yieldForDividend", "priceForDividend", "resultDividend",
    "yieldForPrice", "dividendForPrice", "resultPrice"
  ]

  calcYield() {
    const price = parseFloat(this.priceForYieldTarget.value)
    const dividend = parseFloat(this.dividendForYieldTarget.value)
    if (price > 0 && !isNaN(dividend)) {
      this.resultYieldTarget.textContent = this.fmt((dividend / price) * 100) + "%"
    } else {
      this.resultYieldTarget.textContent = "—"
    }
  }

  calcDividend() {
    const yld = parseFloat(this.yieldForDividendTarget.value)
    const price = parseFloat(this.priceForDividendTarget.value)
    if (!isNaN(yld) && price > 0) {
      this.resultDividendTarget.textContent = "$" + this.fmt((yld / 100) * price)
    } else {
      this.resultDividendTarget.textContent = "—"
    }
  }

  calcPrice() {
    const yld = parseFloat(this.yieldForPriceTarget.value)
    const dividend = parseFloat(this.dividendForPriceTarget.value)
    if (yld > 0 && !isNaN(dividend)) {
      this.resultPriceTarget.textContent = "$" + this.fmt(dividend / (yld / 100))
    } else {
      this.resultPriceTarget.textContent = "—"
    }
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy(event) {
    const card = event.target.closest("[data-card]")
    const result = card.querySelector("[data-result]")
    navigator.clipboard.writeText(`${card.dataset.card}: ${result.textContent}`)
  }
}
