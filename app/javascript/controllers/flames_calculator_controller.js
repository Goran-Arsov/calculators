import { Controller } from "@hotwired/stimulus"

const OUTCOMES = ["Friends","Love","Affection","Marriage","Enemies","Siblings"]
const DESCRIPTIONS = {
  "Friends": "You make great friends who lift each other up",
  "Love": "You are meant to fall in love",
  "Affection": "You share deep affection and warmth",
  "Marriage": "You could end up married",
  "Enemies": "You clash — opposites who push each other's buttons",
  "Siblings": "You act like brother and sister"
}

export default class extends Controller {
  static targets = ["name1", "name2", "resultOutcome", "resultDescription", "resultCount"]

  connect() { this.calculate() }

  calculate() {
    const n1 = (this.name1Target.value || "").toLowerCase().replace(/[^a-z]/g, "").split("")
    const n2 = (this.name2Target.value || "").toLowerCase().replace(/[^a-z]/g, "").split("")
    if (!n1.length || !n2.length) { this.clear(); return }

    const arr1 = [...n1], arr2 = [...n2]
    for (let i = 0; i < arr1.length; i++) {
      if (arr1[i] === null) continue
      const j = arr2.indexOf(arr1[i])
      if (j >= 0) { arr2.splice(j, 1); arr1[i] = null }
    }
    const remaining = arr1.filter(c => c !== null).length + arr2.length
    const count = remaining || 1

    const flames = [...OUTCOMES]
    let idx = 0
    while (flames.length > 1) {
      idx = (idx + count - 1) % flames.length
      flames.splice(idx, 1)
    }
    const outcome = flames[0]

    this.resultOutcomeTarget.textContent = outcome
    this.resultDescriptionTarget.textContent = DESCRIPTIONS[outcome]
    this.resultCountTarget.textContent = count
  }

  clear() {
    this.resultOutcomeTarget.textContent = "—"
    this.resultDescriptionTarget.textContent = "—"
    this.resultCountTarget.textContent = "—"
  }

  copy() {
    navigator.clipboard.writeText(`FLAMES: ${this.resultOutcomeTarget.textContent} — ${this.resultDescriptionTarget.textContent}`)
  }
}
