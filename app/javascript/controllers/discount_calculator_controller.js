import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "priceA", "discountPercent", "resultSalePrice", "resultSavingsA",
    "originalB", "salePriceB", "resultDiscountPercent", "resultSavingsB"
  ]

  calcSalePrice() {
    const price = parseFloat(this.priceATarget.value) || 0
    const discount = parseFloat(this.discountPercentTarget.value) || 0

    const salePrice = price * (1 - discount / 100)
    const savings = price - salePrice

    this.resultSalePriceTarget.textContent = this.fmt(salePrice)
    this.resultSavingsATarget.textContent = this.fmt(savings)
  }

  calcDiscountPercent() {
    const orig = parseFloat(this.originalBTarget.value) || 0
    const sale = parseFloat(this.salePriceBTarget.value) || 0

    const discountPct = orig > 0 ? ((orig - sale) / orig) * 100 : 0
    const savingsAmt = orig - sale

    this.resultDiscountPercentTarget.textContent = this.fmt(discountPct) + "%"
    this.resultSavingsBTarget.textContent = this.fmt(savingsAmt)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
