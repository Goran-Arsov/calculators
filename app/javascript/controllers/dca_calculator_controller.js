import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["monthly", "rate", "years", "resultFutureValue", "resultTotalInvested", "resultTotalReturn"]

  calculate() {
    const monthly = parseFloat(this.monthlyTarget.value) || 0
    const annualRate = parseFloat(this.rateTarget.value) / 100
    const years = parseInt(this.yearsTarget.value) || 0

    if (monthly <= 0 || years <= 0 || isNaN(annualRate)) {
      this.resultFutureValueTarget.textContent = "—"
      this.resultTotalInvestedTarget.textContent = "—"
      this.resultTotalReturnTarget.textContent = "—"
      return
    }

    const monthlyRate = annualRate / 12
    const numMonths = years * 12
    const totalInvested = monthly * numMonths
    let futureValue

    if (monthlyRate === 0) {
      futureValue = totalInvested
    } else {
      futureValue = monthly * ((Math.pow(1 + monthlyRate, numMonths) - 1) / monthlyRate)
    }

    const totalReturn = futureValue - totalInvested

    this.resultFutureValueTarget.textContent = "$" + this.fmt(futureValue)
    this.resultTotalInvestedTarget.textContent = "$" + this.fmt(totalInvested)
    this.resultTotalReturnTarget.textContent = "$" + this.fmt(totalReturn)
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
