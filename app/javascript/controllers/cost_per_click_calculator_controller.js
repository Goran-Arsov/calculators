import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalSpend", "clicks", "impressions",
    "resultCpc", "resultCpm", "resultCtr"
  ]

  calculate() {
    const totalSpend = parseFloat(this.totalSpendTarget.value) || 0
    const clicks = parseInt(this.clicksTarget.value) || 0
    const impressions = this.hasImpressionsTarget ? (parseInt(this.impressionsTarget.value) || 0) : 0

    if (totalSpend <= 0 || clicks <= 0) {
      this.clearResults()
      return
    }

    const cpc = totalSpend / clicks
    this.resultCpcTarget.textContent = "$" + this.formatCurrency(cpc)

    if (impressions > 0) {
      const cpm = (totalSpend / impressions) * 1000
      const ctr = (clicks / impressions) * 100
      this.resultCpmTarget.textContent = "$" + this.formatCurrency(cpm)
      this.resultCtrTarget.textContent = this.fmt(ctr) + "%"
    } else {
      this.resultCpmTarget.textContent = "\u2014"
      this.resultCtrTarget.textContent = "\u2014"
    }
  }

  clearResults() {
    this.resultCpcTarget.textContent = "\u2014"
    this.resultCpmTarget.textContent = "\u2014"
    this.resultCtrTarget.textContent = "\u2014"
  }

  formatCurrency(n) {
    return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const cpc = this.resultCpcTarget.textContent
    const cpm = this.resultCpmTarget.textContent
    const ctr = this.resultCtrTarget.textContent
    const text = `Cost Per Click: ${cpc}\nCPM: ${cpm}\nClick-Through Rate: ${ctr}`
    navigator.clipboard.writeText(text)
  }
}
