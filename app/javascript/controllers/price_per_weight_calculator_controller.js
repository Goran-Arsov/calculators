import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "price", "weight", "unit",
    "pricePerKg", "pricePerLb", "pricePerGram", "pricePer100g"
  ]

  static GRAMS_PER = { g: 1, kg: 1000, oz: 28.3495, lb: 453.592 }

  calculate() {
    const price = parseFloat(this.priceTarget.value) || 0
    const weight = parseFloat(this.weightTarget.value) || 0
    const unit = this.unitTarget.value

    if (price <= 0 || weight <= 0) {
      this.clearResults()
      return
    }

    const gramsPerUnit = { g: 1, kg: 1000, oz: 28.3495, lb: 453.592 }
    const factor = gramsPerUnit[unit] || 1
    const weightInGrams = weight * factor
    const pricePerGram = price / weightInGrams

    this.pricePerKgTarget.textContent = this.formatCurrency(pricePerGram * 1000)
    this.pricePerLbTarget.textContent = this.formatCurrency(pricePerGram * 453.592)
    this.pricePerGramTarget.textContent = this.formatCurrency(pricePerGram)
    this.pricePer100gTarget.textContent = this.formatCurrency(pricePerGram * 100)
  }

  clearResults() {
    ;["pricePerKg", "pricePerLb", "pricePerGram", "pricePer100g"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = `Price per kg: ${this.pricePerKgTarget.textContent}\nPrice per lb: ${this.pricePerLbTarget.textContent}\nPrice per 100g: ${this.pricePer100gTarget.textContent}\nPrice per gram: ${this.pricePerGramTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }
}
