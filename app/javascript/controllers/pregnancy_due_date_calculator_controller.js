import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lastPeriod", "dueDate", "conceptionDate", "weeksPregnant", "trimester"]

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

    this.dueDateTarget.textContent = this.fmtDate(dueDate)
    this.conceptionDateTarget.textContent = this.fmtDate(conceptionDate)
    this.weeksPregnantTarget.textContent = diffDays >= 0
      ? `${weeksPregnant} weeks, ${daysRemainder} days`
      : "—"
    this.trimesterTarget.textContent = trimester
  }

  clearResults() {
    this.dueDateTarget.textContent = "—"
    this.conceptionDateTarget.textContent = "—"
    this.weeksPregnantTarget.textContent = "—"
    this.trimesterTarget.textContent = "—"
  }

  copy() {
    const text = [
      `Due Date: ${this.dueDateTarget.textContent}`,
      `Conception Date: ${this.conceptionDateTarget.textContent}`,
      `Weeks Pregnant: ${this.weeksPregnantTarget.textContent}`,
      `Trimester: ${this.trimesterTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  fmtDate(date) {
    const options = { year: "numeric", month: "long", day: "numeric" }
    return date.toLocaleDateString("en-US", options)
  }

  fmt(n) {
    return n.toFixed(1)
  }
}
