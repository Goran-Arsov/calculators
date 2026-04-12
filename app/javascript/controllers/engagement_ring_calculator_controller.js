import { Controller } from "@hotwired/stimulus"

const RULE_MONTHS = { one: 1, two: 2, three: 3 }

export default class extends Controller {
  static targets = ["salary", "rule", "resultTarget", "resultLow", "resultHigh", "resultPercent"]

  connect() { this.calculate() }

  calculate() {
    const salary = parseFloat(this.salaryTarget.value)
    const months = RULE_MONTHS[this.ruleTarget.value]
    if (!Number.isFinite(salary) || salary <= 0 || !months) { this.clear(); return }

    const target = (salary / 12) * months
    this.resultTargetTarget.textContent = this.money(target)
    this.resultLowTarget.textContent = this.money(target * 0.7)
    this.resultHighTarget.textContent = this.money(target * 1.3)
    this.resultPercentTarget.textContent = `${((target / salary) * 100).toFixed(1)}%`
  }

  money(n) { return `$${n.toLocaleString("en-US", { maximumFractionDigits: 0 })}` }

  clear() {
    ["Target","Low","High","Percent"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Engagement ring budget: ${this.resultTargetTarget.textContent}`)
  }
}
