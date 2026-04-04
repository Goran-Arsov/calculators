import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "priceForSale", "discountPct", "resultSalePrice", "resultSavings",
    "origPrice", "salePrice", "resultDiscountPct", "resultSavingsAmt"
  ]

  calcSalePrice() {
    const price = parseFloat(this.priceForSaleTarget.value) || 0
    const discount = parseFloat(this.discountPctTarget.value) || 0

    const salePrice = price * (1 - discount / 100)
    const savings = price - salePrice

    this.resultSalePriceTarget.textContent = this.fmt(salePrice)
    this.resultSavingsTarget.textContent = this.fmt(savings)
  }

  calcDiscountPct() {
    const orig = parseFloat(this.origPriceTarget.value) || 0
    const sale = parseFloat(this.salePriceTarget.value) || 0

    const discountPct = orig > 0 ? ((orig - sale) / orig) * 100 : 0
    const savingsAmt = orig - sale

    this.resultDiscountPctTarget.textContent = this.fmt(discountPct) + "%"
    this.resultSavingsAmtTarget.textContent = this.fmt(savingsAmt)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
