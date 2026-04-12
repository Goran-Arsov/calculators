import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wedding", "resultDays", "resultWeeks", "resultMonths", "resultHours", "resultMilestone"]

  connect() { this.calculate() }

  calculate() {
    if (!this.weddingTarget.value) { this.clear(); return }
    const w = new Date(this.weddingTarget.value)
    const now = new Date()
    if (isNaN(w.getTime())) { this.clear(); return }

    const days = Math.ceil((w - now) / 86400000)
    const hours = Math.ceil((w - now) / 3600000)
    const weeks = Math.floor(days / 7)
    const months = Math.floor(days / 30.4375)

    this.resultDaysTarget.textContent = days < 0 ? "Already married! 🎉" : days.toLocaleString()
    this.resultWeeksTarget.textContent = weeks
    this.resultMonthsTarget.textContent = months
    this.resultHoursTarget.textContent = hours.toLocaleString()
    this.resultMilestoneTarget.textContent = this.milestone(days)
  }

  milestone(d) {
    if (d < 0) return "Already married — congrats!"
    if (d <= 14) return "Final week: confirm vendors, seating, speeches"
    if (d <= 30) return "One month out: rehearsal dinner, final dress fitting"
    if (d <= 60) return "Two months out: finalize guest count, send final payments"
    if (d <= 90) return "Three months out: mail invitations, book honeymoon flights"
    if (d <= 180) return "Six months out: book florist, officiant, finalize menu"
    if (d <= 365) return "One year out: book venue, photographer, and DJ"
    return "More than a year out: set the date and start a budget"
  }

  clear() {
    ["Days","Weeks","Months","Hours","Milestone"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Days until wedding: ${this.resultDaysTarget.textContent}`)
  }
}
