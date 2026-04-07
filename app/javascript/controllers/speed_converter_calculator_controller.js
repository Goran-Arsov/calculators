import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value", "unit", "resultMps", "resultKmh", "resultMph", "resultKnots", "resultFps"]

  static toMps = {
    "m/s": 1,
    "km/h": 1 / 3.6,
    "mph": 0.44704,
    "knots": 0.514444,
    "ft/s": 0.3048
  }

  calculate() {
    const val = parseFloat(this.valueTarget.value)
    const unit = this.unitTarget.value
    if (isNaN(val)) { this.clearAll(); return }

    const mps = val * this.constructor.toMps[unit]
    const tm = this.constructor.toMps

    this.resultMpsTarget.textContent = this.fmt(mps / tm["m/s"])
    this.resultKmhTarget.textContent = this.fmt(mps / tm["km/h"])
    this.resultMphTarget.textContent = this.fmt(mps / tm["mph"])
    this.resultKnotsTarget.textContent = this.fmt(mps / tm["knots"])
    this.resultFpsTarget.textContent = this.fmt(mps / tm["ft/s"])
  }

  clearAll() {
    const dash = "--"
    this.resultMpsTarget.textContent = dash
    this.resultKmhTarget.textContent = dash
    this.resultMphTarget.textContent = dash
    this.resultKnotsTarget.textContent = dash
    this.resultFpsTarget.textContent = dash
  }

  fmt(n) {
    if (Math.abs(n) >= 1) return parseFloat(n.toFixed(4))
    return parseFloat(n.toFixed(8))
  }

  copy() {
    const lines = [
      `m/s: ${this.resultMpsTarget.textContent}`,
      `km/h: ${this.resultKmhTarget.textContent}`,
      `mph: ${this.resultMphTarget.textContent}`,
      `knots: ${this.resultKnotsTarget.textContent}`,
      `ft/s: ${this.resultFpsTarget.textContent}`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
