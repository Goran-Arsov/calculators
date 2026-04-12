import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "responseRate", "dateRate", "relRate", "resultResponses", "resultDates", "resultWeeks", "resultMessages", "resultHours"]

  connect() { this.calculate() }

  calculate() {
    const msgs = parseInt(this.messagesTarget.value)
    const respRate = parseFloat(this.responseRateTarget.value) / 100
    const dateRate = parseFloat(this.dateRateTarget.value) / 100
    const relRate = parseFloat(this.relRateTarget.value) / 100
    if (!Number.isFinite(msgs) || msgs < 1 || respRate <= 0 || dateRate <= 0 || relRate <= 0) { this.clear(); return }

    const responses = msgs * respRate
    const dates = responses * dateRate
    let weeks = 1 / (dates * relRate)
    weeks = Math.min(weeks, 520)
    const messagesNeeded = Math.round(msgs * weeks)
    const hours = (messagesNeeded * 3) / 60

    this.resultResponsesTarget.textContent = responses.toFixed(1)
    this.resultDatesTarget.textContent = dates.toFixed(2)
    this.resultWeeksTarget.textContent = `${weeks.toFixed(1)} wk (${(weeks/4.33).toFixed(1)} mo)`
    this.resultMessagesTarget.textContent = messagesNeeded.toLocaleString()
    this.resultHoursTarget.textContent = `${hours.toFixed(1)} hr`
  }

  clear() {
    ["Responses","Dates","Weeks","Messages","Hours"].forEach(k => { this[`result${k}Target`].textContent = "—" })
  }

  copy() {
    navigator.clipboard.writeText(`Online dating ROI: ${this.resultMessagesTarget.textContent} messages, ${this.resultHoursTarget.textContent}`)
  }
}
