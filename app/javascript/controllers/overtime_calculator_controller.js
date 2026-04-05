import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "hourlyRate", "regularHours", "overtimeHours", "otMultiplier",
    "resultRegularPay", "resultOvertimePay", "resultTotalPay",
    "resultOvertimeRate", "resultTotalHours", "resultEffectiveRate"
  ]

  calculate() {
    const hourlyRate = parseFloat(this.hourlyRateTarget.value) || 0
    const regularHours = parseFloat(this.regularHoursTarget.value) || 0
    const overtimeHours = parseFloat(this.overtimeHoursTarget.value) || 0
    const otMultiplier = parseFloat(this.otMultiplierTarget.value) || 1.5

    if (hourlyRate <= 0) {
      this.clearResults()
      return
    }

    const regularPay = hourlyRate * regularHours
    const overtimeRate = hourlyRate * otMultiplier
    const overtimePay = overtimeRate * overtimeHours
    const totalPay = regularPay + overtimePay
    const totalHours = regularHours + overtimeHours
    const effectiveRate = totalHours > 0 ? totalPay / totalHours : 0

    this.resultRegularPayTarget.textContent = this.formatCurrency(regularPay)
    this.resultOvertimePayTarget.textContent = this.formatCurrency(overtimePay)
    this.resultTotalPayTarget.textContent = this.formatCurrency(totalPay)
    this.resultOvertimeRateTarget.textContent = this.formatCurrency(overtimeRate)
    this.resultTotalHoursTarget.textContent = totalHours.toFixed(1)
    this.resultEffectiveRateTarget.textContent = this.formatCurrency(effectiveRate)
  }

  clearResults() {
    ;["resultRegularPay", "resultOvertimePay", "resultTotalPay", "resultOvertimeRate", "resultTotalHours", "resultEffectiveRate"].forEach(t => {
      this[`${t}Target`].textContent = "\u2014"
    })
  }

  copy() {
    const text = `Regular Pay: ${this.resultRegularPayTarget.textContent}\nOvertime Pay: ${this.resultOvertimePayTarget.textContent}\nTotal Pay: ${this.resultTotalPayTarget.textContent}\nOvertime Rate: ${this.resultOvertimeRateTarget.textContent}\nTotal Hours: ${this.resultTotalHoursTarget.textContent}\nEffective Hourly Rate: ${this.resultEffectiveRateTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(value)
  }
}
