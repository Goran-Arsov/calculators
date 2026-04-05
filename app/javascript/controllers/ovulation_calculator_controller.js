import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lastPeriod", "cycleLength",
                     "ovulationDate", "fertileStart", "fertileEnd",
                     "nextPeriod", "cycles"]

  calculate() {
    const lmpValue = this.lastPeriodTarget.value
    const cycleLength = parseInt(this.cycleLengthTarget.value) || 28

    if (!lmpValue || cycleLength < 20 || cycleLength > 45) {
      this.clearResults()
      return
    }

    const lmp = new Date(lmpValue + "T00:00:00")
    const ovulationDay = cycleLength - 14

    const ovulationDate = new Date(lmp)
    ovulationDate.setDate(ovulationDate.getDate() + ovulationDay)

    const fertileStart = new Date(ovulationDate)
    fertileStart.setDate(fertileStart.getDate() - 5)

    const fertileEnd = new Date(ovulationDate)
    fertileEnd.setDate(fertileEnd.getDate() + 1)

    const nextPeriod = new Date(lmp)
    nextPeriod.setDate(nextPeriod.getDate() + cycleLength)

    this.ovulationDateTarget.textContent = this.fmtDate(ovulationDate)
    this.fertileStartTarget.textContent = this.fmtDate(fertileStart)
    this.fertileEndTarget.textContent = this.fmtDate(fertileEnd)
    this.nextPeriodTarget.textContent = this.fmtDate(nextPeriod)

    this.buildCycles(lmp, cycleLength)
  }

  buildCycles(lmp, cycleLength) {
    const rows = []
    for (let i = 0; i < 3; i++) {
      const cycleStart = new Date(lmp)
      cycleStart.setDate(cycleStart.getDate() + cycleLength * i)

      const ovDay = cycleLength - 14
      const ovDate = new Date(cycleStart)
      ovDate.setDate(ovDate.getDate() + ovDay)

      const fStart = new Date(ovDate)
      fStart.setDate(fStart.getDate() - 5)

      const fEnd = new Date(ovDate)
      fEnd.setDate(fEnd.getDate() + 1)

      const nPeriod = new Date(cycleStart)
      nPeriod.setDate(nPeriod.getDate() + cycleLength)

      rows.push(`<div class="grid grid-cols-4 gap-2 py-2 text-sm ${i > 0 ? 'border-t border-gray-200 dark:border-gray-700' : ''}">
        <span class="font-semibold text-gray-900 dark:text-white">Cycle ${i + 1}</span>
        <span class="text-gray-600 dark:text-gray-400">${this.fmtShort(ovDate)}</span>
        <span class="text-green-600 dark:text-green-400">${this.fmtShort(fStart)} – ${this.fmtShort(fEnd)}</span>
        <span class="text-gray-600 dark:text-gray-400">${this.fmtShort(nPeriod)}</span>
      </div>`)
    }

    this.cyclesTarget.innerHTML = `<div class="grid grid-cols-4 gap-2 py-2 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase border-b border-gray-200 dark:border-gray-700">
      <span>Cycle</span><span>Ovulation</span><span>Fertile Window</span><span>Next Period</span>
    </div>` + rows.join("")
  }

  clearResults() {
    const targets = ["ovulationDate", "fertileStart", "fertileEnd", "nextPeriod"]
    targets.forEach(t => this[`${t}Target`].textContent = "—")
    this.cyclesTarget.innerHTML = '<p class="text-gray-400 dark:text-gray-500 text-sm">Enter your last period date to see upcoming cycles</p>'
  }

  copy() {
    const text = [
      `Ovulation Date: ${this.ovulationDateTarget.textContent}`,
      `Fertile Window: ${this.fertileStartTarget.textContent} – ${this.fertileEndTarget.textContent}`,
      `Next Period: ${this.nextPeriodTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }

  fmtDate(date) {
    const options = { year: "numeric", month: "long", day: "numeric" }
    return date.toLocaleDateString("en-US", options)
  }

  fmtShort(date) {
    const options = { month: "short", day: "numeric" }
    return date.toLocaleDateString("en-US", options)
  }
}
