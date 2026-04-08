import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value", "unit", "resultUsCup", "resultMetricCup", "resultImperialCup", "resultMl", "resultL", "resultFlOz", "resultUsTbsp", "resultUsTsp"]

  static toMl = {
    us_cup: 236.588,
    metric_cup: 250,
    imperial_cup: 284.131,
    ml: 1,
    l: 1000,
    fl_oz: 29.5735,
    us_tbsp: 14.7868,
    us_tsp: 4.92892
  }

  calculate() {
    const val = parseFloat(this.valueTarget.value)
    const unit = this.unitTarget.value
    if (isNaN(val)) { this.clearAll(); return }

    const ml = val * this.constructor.toMl[unit]
    const tm = this.constructor.toMl

    this.resultUsCupTarget.textContent = this.fmt(ml / tm.us_cup)
    this.resultMetricCupTarget.textContent = this.fmt(ml / tm.metric_cup)
    this.resultImperialCupTarget.textContent = this.fmt(ml / tm.imperial_cup)
    this.resultMlTarget.textContent = this.fmt(ml / tm.ml)
    this.resultLTarget.textContent = this.fmt(ml / tm.l)
    this.resultFlOzTarget.textContent = this.fmt(ml / tm.fl_oz)
    this.resultUsTbspTarget.textContent = this.fmt(ml / tm.us_tbsp)
    this.resultUsTspTarget.textContent = this.fmt(ml / tm.us_tsp)
  }

  clearAll() {
    const dash = "--"
    this.resultUsCupTarget.textContent = dash
    this.resultMetricCupTarget.textContent = dash
    this.resultImperialCupTarget.textContent = dash
    this.resultMlTarget.textContent = dash
    this.resultLTarget.textContent = dash
    this.resultFlOzTarget.textContent = dash
    this.resultUsTbspTarget.textContent = dash
    this.resultUsTspTarget.textContent = dash
  }

  fmt(n) {
    if (Math.abs(n) >= 1) return parseFloat(n.toFixed(4))
    return parseFloat(n.toFixed(8))
  }

  copy() {
    const lines = [
      `US Cups: ${this.resultUsCupTarget.textContent}`,
      `Metric Cups: ${this.resultMetricCupTarget.textContent}`,
      `Imperial Cups: ${this.resultImperialCupTarget.textContent}`,
      `Milliliters: ${this.resultMlTarget.textContent}`,
      `Liters: ${this.resultLTarget.textContent}`,
      `Fluid Ounces: ${this.resultFlOzTarget.textContent}`,
      `Tablespoons: ${this.resultUsTbspTarget.textContent}`,
      `Teaspoons: ${this.resultUsTspTarget.textContent}`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
