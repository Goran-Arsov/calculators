import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["presentValue", "rate", "years", "resultFutureValue", "resultLoss"]

  calculate() {
    const pv = parseFloat(this.presentValueTarget.value) || 0
    const rate = parseFloat(this.rateTarget.value) / 100
    const years = parseInt(this.yearsTarget.value) || 0

    if (pv <= 0 || years <= 0 || isNaN(rate)) {
      this.resultFutureValueTarget.textContent = "—"
      this.resultLossTarget.textContent = "—"
      return
    }

    const futureValue = pv * Math.pow(1 + rate, years)
    const loss = futureValue - pv

    this.resultFutureValueTarget.textContent = "$" + this.fmt(futureValue)
    this.resultLossTarget.textContent = "$" + this.fmt(loss)
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
