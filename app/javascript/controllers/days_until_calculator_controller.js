import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "targetDate",
    "resultDays", "resultWeeks", "resultMonths",
    "resultHours", "resultMinutes", "resultBusinessDays", "resultDirection"
  ]

  calculate() {
    const targetValue = this.targetDateTarget.value
    if (!targetValue) return

    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const target = new Date(targetValue + "T00:00:00")

    const diffMs = target - today
    const totalDays = Math.round(diffMs / (1000 * 60 * 60 * 24))
    const absDays = Math.abs(totalDays)
    const past = totalDays < 0

    const weeks = Math.floor(absDays / 7)
    const totalHours = absDays * 24
    const totalMinutes = totalHours * 60

    // Month difference
    const earlier = past ? target : today
    const later = past ? today : target
    const months = (later.getFullYear() - earlier.getFullYear()) * 12 + (later.getMonth() - earlier.getMonth())

    // Business days
    let businessDays = 0
    const start = past ? target : new Date(today)
    const end = past ? new Date(today) : target
    const current = new Date(start)
    while (current < end) {
      const day = current.getDay()
      if (day !== 0 && day !== 6) businessDays++
      current.setDate(current.getDate() + 1)
    }

    this.resultDaysTarget.textContent = this.fmt(absDays)
    this.resultWeeksTarget.textContent = `${this.fmt(weeks)} weeks, ${absDays % 7} days`
    this.resultMonthsTarget.textContent = this.fmt(months)
    this.resultHoursTarget.textContent = this.fmt(totalHours)
    this.resultMinutesTarget.textContent = this.fmt(totalMinutes)
    this.resultBusinessDaysTarget.textContent = this.fmt(businessDays)
    this.resultDirectionTarget.textContent = past ? `${this.fmt(absDays)} days ago` : `${this.fmt(absDays)} days from now`
  }

  clearResults() {
    ;["resultDays", "resultWeeks", "resultMonths", "resultHours", "resultMinutes", "resultBusinessDays", "resultDirection"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = `Days: ${this.resultDaysTarget.textContent}\nWeeks: ${this.resultWeeksTarget.textContent}\nMonths: ${this.resultMonthsTarget.textContent}\nHours: ${this.resultHoursTarget.textContent}\nMinutes: ${this.resultMinutesTarget.textContent}\nBusiness Days: ${this.resultBusinessDaysTarget.textContent}\n${this.resultDirectionTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 0, maximumFractionDigits: 0 })
  }
}
