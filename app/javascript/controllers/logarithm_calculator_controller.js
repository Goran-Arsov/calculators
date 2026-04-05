import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value", "base", "result", "ln", "log10", "log2"]

  calculate() {
    const val = parseFloat(this.valueTarget.value)
    const baseStr = this.baseTarget.value.trim() || "e"

    if (isNaN(val) || val <= 0) {
      this.clearResults()
      return
    }

    const lnVal = Math.log(val)
    const log10Val = Math.log10(val)
    const log2Val = Math.log2(val)

    let customResult
    if (baseStr === "e") {
      customResult = lnVal
    } else if (baseStr === "10") {
      customResult = log10Val
    } else {
      const base = parseFloat(baseStr)
      if (isNaN(base) || base <= 0 || base === 1) {
        this.resultTarget.textContent = "Invalid base"
        this.lnTarget.textContent = this.fmt(lnVal)
        this.log10Target.textContent = this.fmt(log10Val)
        this.log2Target.textContent = this.fmt(log2Val)
        return
      }
      customResult = Math.log(val) / Math.log(base)
    }

    this.resultTarget.textContent = this.fmt(customResult)
    this.lnTarget.textContent = this.fmt(lnVal)
    this.log10Target.textContent = this.fmt(log10Val)
    this.log2Target.textContent = this.fmt(log2Val)
  }

  clearResults() {
    this.resultTarget.textContent = "—"
    this.lnTarget.textContent = "—"
    this.log10Target.textContent = "—"
    this.log2Target.textContent = "—"
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(8).replace(/\.?0+$/, "")
  }

  copy() {
    const r = this.resultTarget.textContent
    const ln = this.lnTarget.textContent
    const l10 = this.log10Target.textContent
    const l2 = this.log2Target.textContent
    navigator.clipboard.writeText(`Result: ${r}\nln: ${ln}\nlog10: ${l10}\nlog2: ${l2}`)
  }
}
