import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dueDate", "lastPeriod", "cycleLength", "method",
                     "conceptionDate", "fertileStart", "fertileEnd",
                     "estimatedLmp", "estimatedDueDate", "conceptionRange"]

  connect() {
    this.updateFields()
  }

  updateFields() {
    const method = this.methodTarget.value
    if (method === "due_date") {
      this.dueDateTarget.closest(".field-group").classList.remove("hidden")
      this.lastPeriodTarget.closest(".field-group").classList.add("hidden")
    } else {
      this.dueDateTarget.closest(".field-group").classList.add("hidden")
      this.lastPeriodTarget.closest(".field-group").classList.remove("hidden")
    }
    this.calculate()
  }

  calculate() {
    const method = this.methodTarget.value
    const cycleLength = parseInt(this.cycleLengthTarget.value) || 28

    if (cycleLength < 20 || cycleLength > 45) {
      this.clearResults()
      return
    }

    if (method === "due_date") {
      this.calculateFromDueDate(cycleLength)
    } else {
      this.calculateFromLmp(cycleLength)
    }
  }

  calculateFromDueDate(cycleLength) {
    const dueDateValue = this.dueDateTarget.value
    if (!dueDateValue) {
      this.clearResults()
      return
    }

    const dueDate = new Date(dueDateValue + "T00:00:00")
    const lmp = new Date(dueDate)
    lmp.setDate(lmp.getDate() - 280)

    const ovulationDay = cycleLength - 14
    const conception = new Date(lmp)
    conception.setDate(conception.getDate() + ovulationDay)

    const fertileStart = new Date(conception)
    fertileStart.setDate(fertileStart.getDate() - 5)

    const fertileEnd = new Date(conception)
    fertileEnd.setDate(fertileEnd.getDate() + 1)

    const earliest = new Date(conception)
    earliest.setDate(earliest.getDate() - 2)
    const latest = new Date(conception)
    latest.setDate(latest.getDate() + 2)

    this.conceptionDateTarget.textContent = this.fmtDate(conception)
    this.fertileStartTarget.textContent = this.fmtDate(fertileStart)
    this.fertileEndTarget.textContent = this.fmtDate(fertileEnd)
    this.estimatedLmpTarget.textContent = this.fmtDate(lmp)
    this.estimatedDueDateTarget.textContent = this.fmtDate(dueDate)
    this.conceptionRangeTarget.textContent = `${this.fmtDate(earliest)} – ${this.fmtDate(latest)}`
  }

  calculateFromLmp(cycleLength) {
    const lmpValue = this.lastPeriodTarget.value
    if (!lmpValue) {
      this.clearResults()
      return
    }

    const lmp = new Date(lmpValue + "T00:00:00")
    const ovulationDay = cycleLength - 14
    const conception = new Date(lmp)
    conception.setDate(conception.getDate() + ovulationDay)

    const fertileStart = new Date(conception)
    fertileStart.setDate(fertileStart.getDate() - 5)

    const fertileEnd = new Date(conception)
    fertileEnd.setDate(fertileEnd.getDate() + 1)

    const dueDate = new Date(lmp)
    dueDate.setDate(dueDate.getDate() + 280)

    const earliest = new Date(conception)
    earliest.setDate(earliest.getDate() - 2)
    const latest = new Date(conception)
    latest.setDate(latest.getDate() + 2)

    this.conceptionDateTarget.textContent = this.fmtDate(conception)
    this.fertileStartTarget.textContent = this.fmtDate(fertileStart)
    this.fertileEndTarget.textContent = this.fmtDate(fertileEnd)
    this.estimatedLmpTarget.textContent = this.fmtDate(lmp)
    this.estimatedDueDateTarget.textContent = this.fmtDate(dueDate)
    this.conceptionRangeTarget.textContent = `${this.fmtDate(earliest)} – ${this.fmtDate(latest)}`
  }

  clearResults() {
    const targets = ["conceptionDate", "fertileStart", "fertileEnd", "estimatedLmp", "estimatedDueDate", "conceptionRange"]
    targets.forEach(t => this[`${t}Target`].textContent = "—")
  }

  copy() {
    const text = [
      `Estimated Conception: ${this.conceptionDateTarget.textContent}`,
      `Fertile Window: ${this.fertileStartTarget.textContent} – ${this.fertileEndTarget.textContent}`,
      `Due Date: ${this.estimatedDueDateTarget.textContent}`,
      `Conception Range: ${this.conceptionRangeTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  fmtDate(date) {
    const options = { year: "numeric", month: "long", day: "numeric" }
    return date.toLocaleDateString("en-US", options)
  }
}
