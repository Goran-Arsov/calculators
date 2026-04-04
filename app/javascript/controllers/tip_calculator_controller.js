import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bill", "tipPct", "split", "resultTip", "resultTotal", "resultPerPerson"]

  calculate() {
    const bill = parseFloat(this.billTarget.value) || 0
    const tipPct = parseFloat(this.tipPctTarget.value) || 18
    const split = parseInt(this.splitTarget.value) || 1

    const tip = bill * tipPct / 100
    const total = bill + tip
    const perPerson = split > 0 ? total / split : total

    this.resultTipTarget.textContent = this.fmt(tip)
    this.resultTotalTarget.textContent = this.fmt(total)
    this.resultPerPersonTarget.textContent = this.fmt(perPerson)
  }

  fmt(n) {
    return "$" + Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
