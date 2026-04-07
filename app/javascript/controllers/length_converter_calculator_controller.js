import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value", "unit", "resultMm", "resultCm", "resultM", "resultKm", "resultInch", "resultFoot", "resultYard", "resultMile"]

  static toMeters = {
    mm: 0.001,
    cm: 0.01,
    m: 1,
    km: 1000,
    inch: 0.0254,
    foot: 0.3048,
    yard: 0.9144,
    mile: 1609.344
  }

  calculate() {
    const val = parseFloat(this.valueTarget.value)
    const unit = this.unitTarget.value
    if (isNaN(val)) { this.clearAll(); return }

    const meters = val * this.constructor.toMeters[unit]
    const tm = this.constructor.toMeters

    this.resultMmTarget.textContent = this.fmt(meters / tm.mm)
    this.resultCmTarget.textContent = this.fmt(meters / tm.cm)
    this.resultMTarget.textContent = this.fmt(meters / tm.m)
    this.resultKmTarget.textContent = this.fmt(meters / tm.km)
    this.resultInchTarget.textContent = this.fmt(meters / tm.inch)
    this.resultFootTarget.textContent = this.fmt(meters / tm.foot)
    this.resultYardTarget.textContent = this.fmt(meters / tm.yard)
    this.resultMileTarget.textContent = this.fmt(meters / tm.mile)
  }

  clearAll() {
    const dash = "--"
    this.resultMmTarget.textContent = dash
    this.resultCmTarget.textContent = dash
    this.resultMTarget.textContent = dash
    this.resultKmTarget.textContent = dash
    this.resultInchTarget.textContent = dash
    this.resultFootTarget.textContent = dash
    this.resultYardTarget.textContent = dash
    this.resultMileTarget.textContent = dash
  }

  fmt(n) {
    if (Math.abs(n) >= 1) return parseFloat(n.toFixed(4))
    return parseFloat(n.toFixed(8))
  }

  copy() {
    const lines = [
      `mm: ${this.resultMmTarget.textContent}`,
      `cm: ${this.resultCmTarget.textContent}`,
      `m: ${this.resultMTarget.textContent}`,
      `km: ${this.resultKmTarget.textContent}`,
      `inch: ${this.resultInchTarget.textContent}`,
      `foot: ${this.resultFootTarget.textContent}`,
      `yard: ${this.resultYardTarget.textContent}`,
      `mile: ${this.resultMileTarget.textContent}`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
