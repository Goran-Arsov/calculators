import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "thickness", "width", "length", "quantity", "pricePerBf",
    "resultBfEach", "resultTotalBf", "resultLinearFt",
    "resultCostEach", "resultTotalCost"
  ]

  calculate() {
    const thickness = parseFloat(this.thicknessTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const length = parseFloat(this.lengthTarget.value) || 0
    const quantity = parseInt(this.quantityTarget.value) || 1
    const pricePerBf = parseFloat(this.pricePerBfTarget.value) || 0

    if (thickness <= 0 || width <= 0 || length <= 0) {
      this.clearResults()
      return
    }

    const bfEach = (thickness * width * length) / 12
    const totalBf = bfEach * quantity
    const linearFt = length * quantity
    const costEach = bfEach * pricePerBf
    const totalCost = totalBf * pricePerBf

    this.resultBfEachTarget.textContent = bfEach.toFixed(4)
    this.resultTotalBfTarget.textContent = totalBf.toFixed(4)
    this.resultLinearFtTarget.textContent = `${this.fmt(linearFt)} ft`
    this.resultCostEachTarget.textContent = this.currency(costEach)
    this.resultTotalCostTarget.textContent = this.currency(totalCost)
  }

  clearResults() {
    this.resultBfEachTarget.textContent = "0"
    this.resultTotalBfTarget.textContent = "0"
    this.resultLinearFtTarget.textContent = "0 ft"
    this.resultCostEachTarget.textContent = "$0.00"
    this.resultTotalCostTarget.textContent = "$0.00"
  }

  copy() {
    const text = `Lumber Estimate:\nBoard Feet (each): ${this.resultBfEachTarget.textContent}\nTotal Board Feet: ${this.resultTotalBfTarget.textContent}\nTotal Linear Feet: ${this.resultLinearFtTarget.textContent}\nCost per Piece: ${this.resultCostEachTarget.textContent}\nTotal Cost: ${this.resultTotalCostTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }

  currency(n) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(n)
  }
}
