import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startDate", "endDate", "hoursPerDay", "daysPerWeek",
    "resultCalendarDays", "resultWeeks", "resultWorkDays", "resultTotalHours"
  ]

  calculate() {
    const startValue = this.startDateTarget.value
    const endValue = this.endDateTarget.value
    const hoursPerDay = parseFloat(this.hoursPerDayTarget.value) || 8
    const daysPerWeek = parseInt(this.daysPerWeekTarget.value) || 5

    if (!startValue || !endValue) return

    const start = new Date(startValue + "T00:00:00")
    const end_ = new Date(endValue + "T00:00:00")

    if (end_ <= start) {
      this.clearResults()
      return
    }

    const calendarDays = Math.round((end_ - start) / (1000 * 60 * 60 * 24))
    const totalWeeks = (calendarDays / 7).toFixed(1)

    // Count work days
    const workingWdays = this.getWorkingWdays(daysPerWeek)
    let workDays = 0
    const current = new Date(start)
    while (current < end_) {
      if (workingWdays.includes(current.getDay())) {
        workDays++
      }
      current.setDate(current.getDate() + 1)
    }

    const totalHours = (workDays * hoursPerDay).toFixed(1)

    this.resultCalendarDaysTarget.textContent = this.fmt(calendarDays)
    this.resultWeeksTarget.textContent = totalWeeks
    this.resultWorkDaysTarget.textContent = this.fmt(workDays)
    this.resultTotalHoursTarget.textContent = this.fmt(totalHours)
  }

  getWorkingWdays(daysPerWeek) {
    // JS getDay: 0=Sun, 1=Mon, ..., 6=Sat
    const maps = {
      7: [0, 1, 2, 3, 4, 5, 6],
      6: [1, 2, 3, 4, 5, 6],
      5: [1, 2, 3, 4, 5],
      4: [1, 2, 3, 4],
      3: [1, 2, 3],
      2: [1, 2],
      1: [1]
    }
    return maps[daysPerWeek] || maps[5]
  }

  clearResults() {
    ;["resultCalendarDays", "resultWeeks", "resultWorkDays", "resultTotalHours"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = `Calendar Days: ${this.resultCalendarDaysTarget.textContent}\nWeeks: ${this.resultWeeksTarget.textContent}\nWork Days: ${this.resultWorkDaysTarget.textContent}\nTotal Hours: ${this.resultTotalHoursTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 0, maximumFractionDigits: 1 })
  }
}
