import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startDate", "endDate", "resultDays", "resultWeeks", "resultMonths", "resultYears"]

  calculate() {
    const startValue = this.startDateTarget.value
    const endValue = this.endDateTarget.value
    if (!startValue || !endValue) return

    const start = new Date(startValue + "T00:00:00")
    const end = new Date(endValue + "T00:00:00")

    const diffMs = Math.abs(end - start)
    const days = Math.floor(diffMs / (1000 * 60 * 60 * 24))
    const weeks = (days / 7)

    let years = end.getFullYear() - start.getFullYear()
    let months = end.getMonth() - start.getMonth()
    if (end.getDate() < start.getDate()) {
      months--
    }
    if (months < 0) {
      years--
      months += 12
    }
    const totalMonths = years * 12 + months

    this.resultDaysTarget.textContent = this.fmt(days)
    this.resultWeeksTarget.textContent = this.fmt(weeks)
    this.resultMonthsTarget.textContent = this.fmt(totalMonths)
    this.resultYearsTarget.textContent = this.fmt(Math.abs(years))
  }

  copy() {
    const days = this.resultDaysTarget.textContent
    const weeks = this.resultWeeksTarget.textContent
    const months = this.resultMonthsTarget.textContent
    const years = this.resultYearsTarget.textContent

    const text = `Days: ${days}\nWeeks: ${weeks}\nMonths: ${months}\nYears: ${years}`

    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 0, maximumFractionDigits: 2 })
  }
}
