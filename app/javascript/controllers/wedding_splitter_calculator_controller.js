import { Controller } from "@hotwired/stimulus"

const MODES = {
  traditional: { brides: 0.55, grooms: 0.15, couple: 0.30 },
  modern: { brides: 0.25, grooms: 0.25, couple: 0.50 },
  even: { brides: 1/3, grooms: 1/3, couple: 1/3 }
}

export default class extends Controller {
  static targets = ["total", "mode", "resultBrides", "resultGrooms", "resultCouple"]

  connect() { this.calculate() }

  calculate() {
    const total = parseFloat(this.totalTarget.value)
    const mode = this.modeTarget.value
    const split = MODES[mode]
    if (!Number.isFinite(total) || total <= 0 || !split) { this.clear(); return }

    this.resultBridesTarget.textContent = this.money(total * split.brides)
    this.resultGroomsTarget.textContent = this.money(total * split.grooms)
    this.resultCoupleTarget.textContent = this.money(total * split.couple)
  }

  money(n) { return `$${n.toLocaleString("en-US", { maximumFractionDigits: 0 })}` }

  clear() {
    ["Brides","Grooms","Couple"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Wedding cost split — Brides: ${this.resultBridesTarget.textContent}, Grooms: ${this.resultGroomsTarget.textContent}, Couple: ${this.resultCoupleTarget.textContent}`)
  }
}
