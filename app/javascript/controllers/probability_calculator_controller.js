import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["favorable", "total", "probability", "percentage", "complementary", "complementaryPct", "oddsFor", "oddsAgainst", "oddsRatio"]

  calculate() {
    const favorable = parseFloat(this.favorableTarget.value)
    const total = parseFloat(this.totalTarget.value)

    if (isNaN(favorable) || isNaN(total) || total <= 0 || favorable < 0 || favorable > total || favorable === 0) {
      this.clearResults()
      return
    }

    const probability = favorable / total
    const complementary = 1 - probability
    const oddsFor = favorable / (total - favorable)
    const oddsAgainst = (total - favorable) / favorable

    this.probabilityTarget.textContent = this.fmt8(probability)
    this.percentageTarget.textContent = this.fmt(probability * 100) + "%"
    this.complementaryTarget.textContent = this.fmt8(complementary)
    this.complementaryPctTarget.textContent = this.fmt(complementary * 100) + "%"
    this.oddsForTarget.textContent = this.fmt(oddsFor)
    this.oddsAgainstTarget.textContent = this.fmt(oddsAgainst)
    this.oddsRatioTarget.textContent = `${Math.round(favorable)}:${Math.round(total - favorable)}`
  }

  clearResults() {
    this.probabilityTarget.textContent = "—"
    this.percentageTarget.textContent = "—"
    this.complementaryTarget.textContent = "—"
    this.complementaryPctTarget.textContent = "—"
    this.oddsForTarget.textContent = "—"
    this.oddsAgainstTarget.textContent = "—"
    this.oddsRatioTarget.textContent = "—"
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  fmt8(n) {
    return n.toFixed(8).replace(/\.?0+$/, "")
  }

  copy() {
    const p = this.probabilityTarget.textContent
    const pct = this.percentageTarget.textContent
    const c = this.complementaryTarget.textContent
    const of = this.oddsForTarget.textContent
    const oa = this.oddsAgainstTarget.textContent
    navigator.clipboard.writeText(`Probability: ${p}\nPercentage: ${pct}\nComplementary: ${c}\nOdds For: ${of}\nOdds Against: ${oa}`)
  }
}
