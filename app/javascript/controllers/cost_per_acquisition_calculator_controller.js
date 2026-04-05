import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "totalCost", "customers", "customerLtv",
    "resultCpa", "resultLtvRatio", "resultRoi"
  ]

  calculate() {
    const totalCost = parseFloat(this.totalCostTarget.value) || 0
    const customers = parseInt(this.customersTarget.value) || 0
    const customerLtv = this.hasCustomerLtvTarget ? (parseFloat(this.customerLtvTarget.value) || 0) : 0

    if (totalCost <= 0 || customers <= 0) {
      this.clearResults()
      return
    }

    const cpa = totalCost / customers
    this.resultCpaTarget.textContent = "$" + this.formatCurrency(cpa)

    if (customerLtv > 0) {
      const ltvRatio = customerLtv / cpa
      const roi = ((customerLtv - cpa) / cpa) * 100
      this.resultLtvRatioTarget.textContent = this.fmt(ltvRatio) + ":1"
      this.resultRoiTarget.textContent = this.fmt(roi) + "%"
    } else {
      this.resultLtvRatioTarget.textContent = "\u2014"
      this.resultRoiTarget.textContent = "\u2014"
    }
  }

  clearResults() {
    this.resultCpaTarget.textContent = "\u2014"
    this.resultLtvRatioTarget.textContent = "\u2014"
    this.resultRoiTarget.textContent = "\u2014"
  }

  formatCurrency(n) {
    return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const cpa = this.resultCpaTarget.textContent
    const ltvRatio = this.resultLtvRatioTarget.textContent
    const roi = this.resultRoiTarget.textContent
    const text = `Cost Per Acquisition: ${cpa}\nLTV:CPA Ratio: ${ltvRatio}\nROI: ${roi}`
    navigator.clipboard.writeText(text)
  }
}
