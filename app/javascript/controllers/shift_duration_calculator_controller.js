import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "startTime", "endTime", "breakMinutes",
    "resultTotalHours", "resultTotalMinutes", "resultPaidHours",
    "resultPaidMinutes", "resultBreakMinutes", "resultOvernight"
  ]

  calculate() {
    const startValue = this.startTimeTarget.value
    const endValue = this.endTimeTarget.value
    const breakMinutes = parseFloat(this.breakMinutesTarget.value) || 0

    if (!startValue || !endValue) return

    const startMinutes = this.timeToMinutes(startValue)
    const endMinutes = this.timeToMinutes(endValue)

    let totalMinutes
    let overnight = false
    if (endMinutes > startMinutes) {
      totalMinutes = endMinutes - startMinutes
    } else {
      totalMinutes = (24 * 60 - startMinutes) + endMinutes
      overnight = true
    }

    const paidMinutes = Math.max(totalMinutes - breakMinutes, 0)
    const totalHours = (totalMinutes / 60).toFixed(2)
    const paidHours = (paidMinutes / 60).toFixed(2)

    this.resultTotalHoursTarget.textContent = totalHours
    this.resultTotalMinutesTarget.textContent = this.fmt(totalMinutes)
    this.resultPaidHoursTarget.textContent = paidHours
    this.resultPaidMinutesTarget.textContent = this.fmt(paidMinutes)
    this.resultBreakMinutesTarget.textContent = this.fmt(breakMinutes)
    this.resultOvernightTarget.textContent = overnight ? "Yes" : "No"
  }

  timeToMinutes(timeStr) {
    const parts = timeStr.split(":")
    return parseInt(parts[0]) * 60 + parseInt(parts[1])
  }

  clearResults() {
    ;["resultTotalHours", "resultTotalMinutes", "resultPaidHours", "resultPaidMinutes", "resultBreakMinutes", "resultOvernight"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = `Total Hours: ${this.resultTotalHoursTarget.textContent}\nTotal Minutes: ${this.resultTotalMinutesTarget.textContent}\nPaid Hours: ${this.resultPaidHoursTarget.textContent}\nPaid Minutes: ${this.resultPaidMinutesTarget.textContent}\nBreak Minutes: ${this.resultBreakMinutesTarget.textContent}\nOvernight: ${this.resultOvernightTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 0, maximumFractionDigits: 0 })
  }
}
