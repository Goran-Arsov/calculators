import { Controller } from "@hotwired/stimulus"
import { prefillFromUrl } from "utils/url_prefill"

export default class extends Controller {
  static targets = ["subtotal", "tipPercent", "taxPercent", "numPeople",
                     "resultTip", "resultTax", "resultTotal", "resultPerPerson"]

  connect() {
    if (prefillFromUrl(this, { subtotal: "subtotal", tipPercent: "tipPercent", taxPercent: "taxPercent", numPeople: "numPeople" })) {
      this.calculate()
    }
  }

  calculate() {
    const subtotal = parseFloat(this.subtotalTarget.value) || 0
    const tipPct = parseFloat(this.tipPercentTarget.value) || 0
    const taxPct = parseFloat(this.taxPercentTarget.value) || 0
    const numPeople = parseInt(this.numPeopleTarget.value) || 1

    const tip = subtotal * tipPct / 100
    const tax = subtotal * taxPct / 100
    const total = subtotal + tip + tax
    const perPerson = numPeople > 0 ? total / numPeople : total

    this.resultTipTarget.textContent = this.fmt(tip)
    this.resultTaxTarget.textContent = this.fmt(tax)
    this.resultTotalTarget.textContent = this.fmt(total)
    this.resultPerPersonTarget.textContent = this.fmt(perPerson)
  }

  fmt(n) {
    return "$" + Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }

  copy() {
    const tip = this.resultTipTarget.textContent
    const tax = this.resultTaxTarget.textContent
    const total = this.resultTotalTarget.textContent
    const perPerson = this.resultPerPersonTarget.textContent
    const text = `Tip: ${tip}\nTax: ${tax}\nTotal: ${total}\nPer Person: ${perPerson}`
    navigator.clipboard.writeText(text)
  }
}
