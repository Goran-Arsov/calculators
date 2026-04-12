import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["start", "resultYears", "resultMonths", "resultWeeks", "resultDays", "resultHours", "resultMinutes"]

  connect() { this.calculate() }

  calculate() {
    if (!this.startTarget.value) { this.clear(); return }
    const start = new Date(this.startTarget.value)
    const now = new Date()
    if (isNaN(start.getTime()) || start > now) { this.clear(); return }

    const totalMs = now - start
    const days = Math.floor(totalMs / 86400000)
    const hours = Math.floor(totalMs / 3600000)
    const minutes = Math.floor(totalMs / 60000)
    const weeks = Math.floor(days / 7)
    const months = Math.floor(days / 30.4375)
    const years = (days / 365.25).toFixed(2)

    this.resultYearsTarget.textContent = years
    this.resultMonthsTarget.textContent = months.toLocaleString()
    this.resultWeeksTarget.textContent = weeks.toLocaleString()
    this.resultDaysTarget.textContent = days.toLocaleString()
    this.resultHoursTarget.textContent = hours.toLocaleString()
    this.resultMinutesTarget.textContent = minutes.toLocaleString()
  }

  clear() {
    ["Years","Months","Weeks","Days","Hours","Minutes"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Dating duration: ${this.resultDaysTarget.textContent} days`)
  }
}
