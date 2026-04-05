import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startDate", "endDate",
    "resultBusinessDays", "resultCalendarDays", "resultWeekendDays", "resultWeeks"
  ]

  calculate() {
    const startValue = this.startDateTarget.value
    const endValue = this.endDateTarget.value

    if (!startValue || !endValue) return

    const start = new Date(startValue + "T00:00:00")
    const end_ = new Date(endValue + "T00:00:00")

    if (end_ <= start) {
      this.clearResults()
      return
    }

    const calendarDays = Math.round((end_ - start) / (1000 * 60 * 60 * 24))
    const totalWeeks = (calendarDays / 7).toFixed(1)

    let businessDays = 0
    let weekendDays = 0
    const current = new Date(start)
    while (current < end_) {
      const day = current.getDay()
      if (day === 0 || day === 6) {
        weekendDays++
      } else {
        businessDays++
      }
      current.setDate(current.getDate() + 1)
    }

    this.resultBusinessDaysTarget.textContent = this.fmt(businessDays)
    this.resultCalendarDaysTarget.textContent = this.fmt(calendarDays)
    this.resultWeekendDaysTarget.textContent = this.fmt(weekendDays)
    this.resultWeeksTarget.textContent = totalWeeks
  }

  clearResults() {
    ;["resultBusinessDays", "resultCalendarDays", "resultWeekendDays", "resultWeeks"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = `Business Days: ${this.resultBusinessDaysTarget.textContent}\nCalendar Days: ${this.resultCalendarDaysTarget.textContent}\nWeekend Days: ${this.resultWeekendDaysTarget.textContent}\nWeeks: ${this.resultWeeksTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 0, maximumFractionDigits: 1 })
  }
}
