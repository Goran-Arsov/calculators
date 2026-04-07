import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value", "unit", "resultMg", "resultG", "resultKg", "resultTonne", "resultOunce", "resultPound", "resultStone"]

  static toGrams = {
    mg: 0.001,
    g: 1,
    kg: 1000,
    tonne: 1000000,
    ounce: 28.3495,
    pound: 453.592,
    stone: 6350.29
  }

  calculate() {
    const val = parseFloat(this.valueTarget.value)
    const unit = this.unitTarget.value
    if (isNaN(val)) { this.clearAll(); return }

    const grams = val * this.constructor.toGrams[unit]
    const tg = this.constructor.toGrams

    this.resultMgTarget.textContent = this.fmt(grams / tg.mg)
    this.resultGTarget.textContent = this.fmt(grams / tg.g)
    this.resultKgTarget.textContent = this.fmt(grams / tg.kg)
    this.resultTonneTarget.textContent = this.fmt(grams / tg.tonne)
    this.resultOunceTarget.textContent = this.fmt(grams / tg.ounce)
    this.resultPoundTarget.textContent = this.fmt(grams / tg.pound)
    this.resultStoneTarget.textContent = this.fmt(grams / tg.stone)
  }

  clearAll() {
    const dash = "--"
    this.resultMgTarget.textContent = dash
    this.resultGTarget.textContent = dash
    this.resultKgTarget.textContent = dash
    this.resultTonneTarget.textContent = dash
    this.resultOunceTarget.textContent = dash
    this.resultPoundTarget.textContent = dash
    this.resultStoneTarget.textContent = dash
  }

  fmt(n) {
    if (Math.abs(n) >= 1) return parseFloat(n.toFixed(4))
    return parseFloat(n.toFixed(8))
  }

  copy() {
    const lines = [
      `mg: ${this.resultMgTarget.textContent}`,
      `g: ${this.resultGTarget.textContent}`,
      `kg: ${this.resultKgTarget.textContent}`,
      `tonne: ${this.resultTonneTarget.textContent}`,
      `ounce: ${this.resultOunceTarget.textContent}`,
      `pound: ${this.resultPoundTarget.textContent}`,
      `stone: ${this.resultStoneTarget.textContent}`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
