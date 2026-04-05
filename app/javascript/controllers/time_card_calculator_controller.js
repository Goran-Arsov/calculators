import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "clockIn", "clockOut", "breakMinutes", "hourlyRate",
    "resultHoursWorked", "resultGrossPay", "resultWeeklyHours",
    "resultWeeklyPay", "resultOvernight", "resultTotalMinutes"
  ]

  calculate() {
    const clockInValue = this.clockInTarget.value
    const clockOutValue = this.clockOutTarget.value
    const breakMinutes = parseFloat(this.breakMinutesTarget.value) || 0
    const hourlyRate = parseFloat(this.hourlyRateTarget.value) || 0

    if (!clockInValue || !clockOutValue) return

    const inMinutes = this.timeToMinutes(clockInValue)
    const outMinutes = this.timeToMinutes(clockOutValue)

    let totalMinutes
    let overnight = false
    if (outMinutes > inMinutes) {
      totalMinutes = outMinutes - inMinutes
    } else {
      totalMinutes = (24 * 60 - inMinutes) + outMinutes
      overnight = true
    }

    const workedMinutes = Math.max(totalMinutes - breakMinutes, 0)
    const hoursWorked = workedMinutes / 60
    const grossPay = hoursWorked * hourlyRate
    const weeklyHours = hoursWorked * 5
    const weeklyPay = grossPay * 5

    this.resultHoursWorkedTarget.textContent = hoursWorked.toFixed(2)
    this.resultGrossPayTarget.textContent = this.formatCurrency(grossPay)
    this.resultWeeklyHoursTarget.textContent = weeklyHours.toFixed(1)
    this.resultWeeklyPayTarget.textContent = this.formatCurrency(weeklyPay)
    this.resultOvernightTarget.textContent = overnight ? "Yes" : "No"
    this.resultTotalMinutesTarget.textContent = this.fmt(totalMinutes)
  }

  timeToMinutes(timeStr) {
    const parts = timeStr.split(":")
    return parseInt(parts[0]) * 60 + parseInt(parts[1])
  }

  clearResults() {
    ;["resultHoursWorked", "resultGrossPay", "resultWeeklyHours", "resultWeeklyPay", "resultOvernight", "resultTotalMinutes"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = `Hours Worked: ${this.resultHoursWorkedTarget.textContent}\nGross Pay: ${this.resultGrossPayTarget.textContent}\nWeekly Hours: ${this.resultWeeklyHoursTarget.textContent}\nWeekly Pay: ${this.resultWeeklyPayTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 0, maximumFractionDigits: 0 })
  }
}
