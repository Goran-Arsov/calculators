import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lastPeriod", "resultDueDate", "resultConception", "resultWeeks", "resultTrimester"]

  calculate() {
    const lastPeriodValue = this.lastPeriodTarget.value
    if (!lastPeriodValue) {
      this.clearResults()
      return
    }

    const lastPeriod = new Date(lastPeriodValue)
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    const dueDate = new Date(lastPeriod)
    dueDate.setDate(dueDate.getDate() + 280)

    const conceptionDate = new Date(lastPeriod)
    conceptionDate.setDate(conceptionDate.getDate() + 14)

    const diffMs = today - lastPeriod
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))
    const weeksPregnant = Math.floor(diffDays / 7)
    const daysRemainder = diffDays % 7

    let trimester
    if (weeksPregnant < 0) {
      trimester = "Not yet pregnant"
    } else if (weeksPregnant <= 12) {
      trimester = "1st Trimester"
    } else if (weeksPregnant <= 26) {
      trimester = "2nd Trimester"
    } else if (weeksPregnant <= 42) {
      trimester = "3rd Trimester"
    } else {
      trimester = "Past due date"
    }

    this.resultDueDateTarget.textContent = this.fmtDate(dueDate)
    this.resultConceptionTarget.textContent = this.fmtDate(conceptionDate)
    this.resultWeeksTarget.textContent = diffDays >= 0
      ? `${weeksPregnant} weeks, ${daysRemainder} days`
      : "—"
    this.resultTrimesterTarget.textContent = trimester
  }

  clearResults() {
    this.resultDueDateTarget.textContent = "—"
    this.resultConceptionTarget.textContent = "—"
    this.resultWeeksTarget.textContent = "—"
    this.resultTrimesterTarget.textContent = "—"
  }

  fmtDate(date) {
    const options = { year: "numeric", month: "long", day: "numeric" }
    return date.toLocaleDateString("en-US", options)
  }

  fmt(n) {
    return n.toFixed(1)
  }
}
