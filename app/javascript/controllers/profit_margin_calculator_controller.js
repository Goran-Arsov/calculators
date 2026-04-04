import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["revenue", "cost", "resultMargin", "resultProfit"]

  calculate() {
    const revenue = parseFloat(this.revenueTarget.value) || 0
    const cost = parseFloat(this.costTarget.value) || 0

    if (revenue <= 0) {
      this.resultMarginTarget.textContent = "—"
      this.resultProfitTarget.textContent = "—"
      return
    }

    const profit = revenue - cost
    const margin = (profit / revenue) * 100

    this.resultMarginTarget.textContent = this.fmt(margin) + "%"
    this.resultProfitTarget.textContent = "$" + this.fmt(profit)
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
