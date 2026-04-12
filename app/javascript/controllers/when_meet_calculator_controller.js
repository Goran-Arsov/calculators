import { Controller } from "@hotwired/stimulus"

const CITY = { small: 0.4, medium: 1.0, large: 2.0, metro: 3.0 }
const EFFORT = { low: 1, medium: 3, high: 6 }
const SELECTIVITY = { very_picky: 0.04, picky: 0.08, average: 0.15, open: 0.30 }

export default class extends Controller {
  static targets = ["city", "effort", "selectivity", "resultMonths", "resultWeeks", "resultDates", "resultHit"]

  connect() { this.calculate() }

  calculate() {
    const cityFactor = CITY[this.cityTarget.value]
    const datesPerMonth = EFFORT[this.effortTarget.value]
    const hitRate = SELECTIVITY[this.selectivityTarget.value]
    if (!cityFactor || !datesPerMonth || !hitRate) { this.clear(); return }

    const datesNeeded = (1 / hitRate) / cityFactor
    let months = datesNeeded / datesPerMonth
    months = Math.max(1, Math.min(60, months))

    this.resultMonthsTarget.textContent = `${months.toFixed(1)} months`
    this.resultWeeksTarget.textContent = `${Math.round(months * 4.33)} weeks`
    this.resultDatesTarget.textContent = `~${Math.round(datesNeeded)} dates`
    this.resultHitTarget.textContent = `${(hitRate * 100).toFixed(1)}%`
  }

  clear() {
    ["Months","Weeks","Dates","Hit"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Estimated time to meet someone: ${this.resultMonthsTarget.textContent}`)
  }
}
