import { Controller } from "@hotwired/stimulus"

const INTENSITY = { casual: 0.5, serious: 1.0, engaged: 1.4, married: 1.8 }
const WHO = { you: 0.7, mutual: 1.0, them: 1.3 }

export default class extends Controller {
  static targets = ["months", "intensity", "who", "firstLove", "resultWeeks", "resultMonths", "stagesList"]

  connect() { this.calculate() }

  calculate() {
    const months = parseFloat(this.monthsTarget.value)
    const intensity = INTENSITY[this.intensityTarget.value]
    const who = WHO[this.whoTarget.value]
    const firstLove = this.firstLoveTarget.checked
    if (!Number.isFinite(months) || months <= 0 || !intensity || !who) { this.clear(); return }

    let weeks = Math.max(11, months * 2) * intensity * who
    if (firstLove) weeks *= 1.2

    this.resultWeeksTarget.textContent = `${weeks.toFixed(1)} weeks`
    this.resultMonthsTarget.textContent = `${(weeks / 4.33).toFixed(1)} months`

    const stages = [
      ["Denial & shock", 0.10],
      ["Pain & grief", 0.30],
      ["Anger & bargaining", 0.20],
      ["Acceptance", 0.25],
      ["Moving on", 0.15]
    ]
    this.stagesListTarget.innerHTML = stages.map(([name, pct]) =>
      `<li class="flex justify-between"><span>${name}</span><span class="font-bold">${(weeks * pct).toFixed(1)} wk</span></li>`
    ).join("")
  }

  clear() {
    this.resultWeeksTarget.textContent = "—"
    this.resultMonthsTarget.textContent = "—"
    this.stagesListTarget.innerHTML = ""
  }

  copy() {
    navigator.clipboard.writeText(`Estimated breakup recovery: ${this.resultWeeksTarget.textContent}`)
  }
}
