import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["transferDate", "embryoType",
                     "dueDate", "gestationalAge", "daysRemaining",
                     "trimester", "equivalentLmp", "milestones"]

  static GESTATION_DAYS = 280
  static offsets = { day_3: 17, day_5: 19 }

  calculate() {
    const dateVal = this.transferDateTarget.value
    const embryoType = this.embryoTypeTarget.value

    if (!dateVal) { this.clearResults(); return }

    const transferDate = new Date(dateVal + "T00:00:00")
    const offset = this.constructor.offsets[embryoType]
    if (!offset) { this.clearResults(); return }

    const lmp = new Date(transferDate)
    lmp.setDate(lmp.getDate() - offset)

    const dueDate = new Date(lmp)
    dueDate.setDate(dueDate.getDate() + this.constructor.GESTATION_DAYS)

    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const daysSinceLmp = Math.floor((today - lmp) / (1000 * 60 * 60 * 24))
    const weeks = Math.max(0, Math.floor(daysSinceLmp / 7))
    const days = Math.max(0, daysSinceLmp % 7)
    const daysRemaining = Math.max(0, Math.floor((dueDate - today) / (1000 * 60 * 60 * 24)))

    let trimester
    if (weeks < 13) trimester = "First Trimester"
    else if (weeks < 27) trimester = "Second Trimester"
    else trimester = "Third Trimester"

    this.dueDateTarget.textContent = this.formatDate(dueDate)
    this.gestationalAgeTarget.textContent = `${weeks} weeks, ${days} days`
    this.daysRemainingTarget.textContent = `${daysRemaining} days`
    this.trimesterTarget.textContent = trimester
    this.equivalentLmpTarget.textContent = this.formatDate(lmp)

    this.buildMilestones(lmp)
  }

  buildMilestones(lmp) {
    const milestones = [
      { week: 6, name: "Heartbeat detectable" },
      { week: 8, name: "First prenatal visit" },
      { week: 12, name: "End of first trimester" },
      { week: 20, name: "Anatomy scan" },
      { week: 24, name: "Viability milestone" },
      { week: 27, name: "Third trimester begins" },
      { week: 37, name: "Full term begins" },
      { week: 40, name: "Due date" }
    ]

    const today = new Date()
    today.setHours(0, 0, 0, 0)

    let html = ""
    milestones.forEach(m => {
      const date = new Date(lmp)
      date.setDate(date.getDate() + m.week * 7)
      const isPast = date <= today
      const cls = isPast ? "text-green-600 dark:text-green-400" : "text-gray-600 dark:text-gray-400"
      const icon = isPast ? "\u2713" : "\u25CB"
      html += `<div class="flex items-center gap-3 py-1.5 text-sm ${cls}">
        <span class="w-5 text-center">${icon}</span>
        <span class="font-semibold">Week ${m.week}</span>
        <span class="flex-1">${m.name}</span>
        <span class="text-xs">${this.formatDate(date)}</span>
      </div>`
    })
    this.milestonesTarget.innerHTML = html
  }

  formatDate(date) {
    return date.toLocaleDateString("en-US", { year: "numeric", month: "short", day: "numeric" })
  }

  clearResults() {
    this.dueDateTarget.textContent = "\u2014"
    this.gestationalAgeTarget.textContent = "\u2014"
    this.daysRemainingTarget.textContent = "\u2014"
    this.trimesterTarget.textContent = "\u2014"
    this.equivalentLmpTarget.textContent = "\u2014"
    this.milestonesTarget.innerHTML = ""
  }

  copy() {
    const text = [
      `Due Date: ${this.dueDateTarget.textContent}`,
      `Gestational Age: ${this.gestationalAgeTarget.textContent}`,
      `Days Remaining: ${this.daysRemainingTarget.textContent}`,
      `Trimester: ${this.trimesterTarget.textContent}`,
      `Equivalent LMP: ${this.equivalentLmpTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
