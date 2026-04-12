import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["target", "current", "months", "resultGap", "resultMonthly", "resultWeekly", "resultDaily", "resultStatus"]

  connect() { this.calculate() }

  calculate() {
    const target = parseFloat(this.targetTarget.value)
    const current = parseFloat(this.currentTarget.value)
    const months = parseInt(this.monthsTarget.value)
    if (!Number.isFinite(target) || target <= 0 || !Number.isFinite(current) || current < 0 || !Number.isFinite(months) || months <= 0) { this.clear(); return }

    const gap = Math.max(target - current, 0)
    const monthly = gap / months
    const weekly = monthly / 4.33
    const daily = monthly / 30

    this.resultGapTarget.textContent = this.money(gap)
    this.resultMonthlyTarget.textContent = this.money(monthly)
    this.resultWeeklyTarget.textContent = this.money(weekly)
    this.resultDailyTarget.textContent = this.money(daily)
    this.resultStatusTarget.textContent = current >= target ? "Already saved! 🎉" : "Saving on track"
  }

  money(n) { return `$${n.toLocaleString("en-US", { maximumFractionDigits: 0 })}` }

  clear() {
    ["Gap","Monthly","Weekly","Daily","Status"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Honeymoon savings: ${this.resultMonthlyTarget.textContent}/month`)
  }
}
