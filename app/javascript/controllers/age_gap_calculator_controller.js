import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["birth1", "birth2", "resultYears", "resultMonths", "resultDays", "resultRule", "resultOlder", "resultYounger"]

  connect() { this.calculate() }

  calculate() {
    const b1 = this.parseDate(this.birth1Target.value)
    const b2 = this.parseDate(this.birth2Target.value)
    if (!b1 || !b2) { this.clear(); return }

    const [older, younger] = b1 < b2 ? [b1, b2] : [b2, b1]
    const today = new Date()

    let years = younger.getFullYear() - older.getFullYear()
    let months = younger.getMonth() - older.getMonth()
    let days = younger.getDate() - older.getDate()
    if (days < 0) {
      months -= 1
      const prev = new Date(younger.getFullYear(), younger.getMonth(), 0)
      days += prev.getDate()
    }
    if (months < 0) { years -= 1; months += 12 }

    const olderAge = this.ageAt(older, today)
    const youngerAge = this.ageAt(younger, today)
    const minOk = (olderAge / 2) + 7
    const rulePasses = youngerAge >= minOk

    this.resultYearsTarget.textContent = years
    this.resultMonthsTarget.textContent = months
    this.resultDaysTarget.textContent = days
    this.resultOlderTarget.textContent = olderAge
    this.resultYoungerTarget.textContent = youngerAge
    this.resultRuleTarget.textContent = rulePasses ? "Passes half-plus-seven rule ✓" : "Fails half-plus-seven rule"
  }

  parseDate(value) {
    if (!value) return null
    const d = new Date(value)
    return isNaN(d.getTime()) ? null : d
  }

  ageAt(birth, today) {
    let age = today.getFullYear() - birth.getFullYear()
    const m = today.getMonth() - birth.getMonth()
    if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) age -= 1
    return age
  }

  clear() {
    ["Years","Months","Days","Older","Younger","Rule"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Age gap: ${this.resultYearsTarget.textContent}y ${this.resultMonthsTarget.textContent}m ${this.resultDaysTarget.textContent}d`)
  }
}
