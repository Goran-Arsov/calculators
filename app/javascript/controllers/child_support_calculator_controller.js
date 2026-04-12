import { Controller } from "@hotwired/stimulus"

const PCT = { 1: 0.17, 2: 0.25, 3: 0.29, 4: 0.31, 5: 0.33 }

export default class extends Controller {
  static targets = ["payor", "other", "kids", "resultMonthly", "resultAnnual", "resultShare"]

  connect() { this.calculate() }

  calculate() {
    const payor = parseFloat(this.payorTarget.value)
    const other = parseFloat(this.otherTarget.value) || 0
    const kids = Math.min(parseInt(this.kidsTarget.value) || 1, 5)
    if (!Number.isFinite(payor) || payor <= 0 || kids < 1) { this.clear(); return }

    const total = payor + other
    const obligation = total * PCT[kids]
    const share = payor / total
    const monthly = (obligation * share) / 12

    this.resultMonthlyTarget.textContent = this.money(monthly)
    this.resultAnnualTarget.textContent = this.money(monthly * 12)
    this.resultShareTarget.textContent = `${(share * 100).toFixed(1)}%`
  }

  money(n) { return `$${n.toLocaleString("en-US", { maximumFractionDigits: 0 })}` }

  clear() {
    ["Monthly","Annual","Share"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Child support estimate: ${this.resultMonthlyTarget.textContent}/month`)
  }
}
