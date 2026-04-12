import { Controller } from "@hotwired/stimulus"

const SIGNS = ["aries","taurus","gemini","cancer","leo","virgo","libra","scorpio","sagittarius","capricorn","aquarius","pisces"]
const ELEMENTS = { aries:"fire", leo:"fire", sagittarius:"fire", taurus:"earth", virgo:"earth", capricorn:"earth", gemini:"air", libra:"air", aquarius:"air", cancer:"water", scorpio:"water", pisces:"water" }
const COMPAT = { fire:"air", air:"fire", earth:"water", water:"earth" }

export default class extends Controller {
  static targets = ["sign1", "sign2", "resultOverall", "resultLove", "resultFriendship", "resultCommunication", "resultLabel"]

  connect() { this.calculate() }

  calculate() {
    const s1 = this.sign1Target.value
    const s2 = this.sign2Target.value
    const e1 = ELEMENTS[s1]
    const e2 = ELEMENTS[s2]

    const base = e1 === e2 ? 85 : (COMPAT[e1] === e2 ? 90 : 55)
    const sameBonus = s1 === s2 ? 5 : 0
    const oppositeBonus = Math.abs((SIGNS.indexOf(s1) - SIGNS.indexOf(s2)) % 12) === 6 ? 10 : 0
    const overall = Math.min(base + sameBonus + oppositeBonus, 99)

    const love = Math.min(overall + 2, 99)
    const friendship = Math.min(base + 5, 99)
    const communication = (e1 === "air" || e2 === "air") ? 92 : (e1 === e2 ? 78 : 65)

    this.resultOverallTarget.textContent = `${overall}%`
    this.resultLoveTarget.textContent = `${love}%`
    this.resultFriendshipTarget.textContent = `${friendship}%`
    this.resultCommunicationTarget.textContent = `${communication}%`
    this.resultLabelTarget.textContent = this.label(overall)
  }

  label(v) {
    if (v >= 85) return "Cosmic match"
    if (v >= 70) return "Strong compatibility"
    if (v >= 55) return "Workable pairing"
    return "Opposites attract"
  }

  copy() {
    navigator.clipboard.writeText(`Zodiac match ${this.sign1Target.value} & ${this.sign2Target.value}: ${this.resultOverallTarget.textContent} (${this.resultLabelTarget.textContent})`)
  }
}
