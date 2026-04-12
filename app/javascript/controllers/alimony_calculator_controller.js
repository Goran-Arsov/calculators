import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["payor", "recipient", "years", "resultMonthly", "resultAnnual", "resultDuration", "resultTotal"]

  connect() { this.calculate() }

  calculate() {
    const payor = parseFloat(this.payorTarget.value)
    const recipient = parseFloat(this.recipientTarget.value) || 0
    const years = parseFloat(this.yearsTarget.value)
    if (!Number.isFinite(payor) || payor <= 0 || !Number.isFinite(years) || years <= 0 || payor <= recipient) { this.clear(); return }

    let annual = (payor * 0.30) - (recipient * 0.20)
    const cap = (payor + recipient) * 0.40 - recipient
    annual = Math.max(0, Math.min(annual, cap))

    const monthly = annual / 12
    let duration
    if (years <= 5) duration = years * 0.25
    else if (years <= 10) duration = years * 0.40
    else if (years <= 20) duration = years * 0.60
    else duration = years * 0.80

    this.resultMonthlyTarget.textContent = this.money(monthly)
    this.resultAnnualTarget.textContent = this.money(annual)
    this.resultDurationTarget.textContent = `${duration.toFixed(1)} years`
    this.resultTotalTarget.textContent = this.money(annual * duration)
  }

  money(n) { return `$${n.toLocaleString("en-US", { maximumFractionDigits: 0 })}` }

  clear() {
    ["Monthly","Annual","Duration","Total"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Alimony estimate: ${this.resultMonthlyTarget.textContent}/month for ${this.resultDurationTarget.textContent}`)
  }
}
