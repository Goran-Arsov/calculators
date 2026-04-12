import { Controller } from "@hotwired/stimulus"

const BASE = {
  uncontested: { low: 1000, mid: 2500, high: 4500 },
  mediated: { low: 3000, mid: 7500, high: 12000 },
  collaborative: { low: 7500, mid: 15000, high: 25000 },
  contested: { low: 15000, mid: 30000, high: 60000 }
}

export default class extends Controller {
  static targets = ["path", "children", "property", "business", "resultLow", "resultMid", "resultHigh"]

  connect() { this.calculate() }

  calculate() {
    const base = BASE[this.pathTarget.value]
    if (!base) { this.clear(); return }

    let extras = 0
    if (this.childrenTarget.checked) extras += 3500
    if (this.propertyTarget.checked) extras += 4500
    if (this.businessTarget.checked) extras += 8000

    this.resultLowTarget.textContent = this.money(base.low + extras)
    this.resultMidTarget.textContent = this.money(base.mid + extras)
    this.resultHighTarget.textContent = this.money(base.high + extras)
  }

  money(n) { return `$${n.toLocaleString("en-US", { maximumFractionDigits: 0 })}` }

  clear() {
    ["Low","Mid","High"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Divorce cost estimate: ${this.resultLowTarget.textContent} – ${this.resultHighTarget.textContent}`)
  }
}
