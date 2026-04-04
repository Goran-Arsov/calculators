import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["birthDate", "resultYears", "resultMonths", "resultDays", "resultTotalDays", "resultNextBirthday"]

  calculate() {
    const birthValue = this.birthDateTarget.value
    if (!birthValue) return

    const birth = new Date(birthValue + "T00:00:00")
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    if (birth > today) return

    let years = today.getFullYear() - birth.getFullYear()
    let months = today.getMonth() - birth.getMonth()
    let days = today.getDate() - birth.getDate()

    if (days < 0) {
      months--
      const prevMonth = new Date(today.getFullYear(), today.getMonth(), 0)
      days += prevMonth.getDate()
    }

    if (months < 0) {
      years--
      months += 12
    }

    const totalDays = Math.floor((today - birth) / (1000 * 60 * 60 * 24))

    let nextBirthday = new Date(today.getFullYear(), birth.getMonth(), birth.getDate())
    if (nextBirthday <= today) {
      nextBirthday = new Date(today.getFullYear() + 1, birth.getMonth(), birth.getDate())
    }
    const daysUntilNext = Math.ceil((nextBirthday - today) / (1000 * 60 * 60 * 24))

    this.resultYearsTarget.textContent = this.fmt(years)
    this.resultMonthsTarget.textContent = this.fmt(months)
    this.resultDaysTarget.textContent = this.fmt(days)
    this.resultTotalDaysTarget.textContent = this.fmt(totalDays)
    this.resultNextBirthdayTarget.textContent = this.fmt(daysUntilNext) + " days"
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US")
  }
}
