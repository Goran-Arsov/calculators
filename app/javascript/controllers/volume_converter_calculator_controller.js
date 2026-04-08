import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value", "unit", "resultCubicMeter", "resultCubicFoot", "resultCubicInch", "resultCubicYard", "resultLiter", "resultGallonUs", "resultGallonUk"]

  static toCubicMeters = {
    cubic_meter: 1,
    cubic_foot: 0.0283168,
    cubic_inch: 0.0000163871,
    cubic_yard: 0.764555,
    liter: 0.001,
    gallon_us: 0.00378541,
    gallon_uk: 0.00454609
  }

  calculate() {
    const val = parseFloat(this.valueTarget.value)
    const unit = this.unitTarget.value
    if (isNaN(val)) { this.clearAll(); return }

    const m3 = val * this.constructor.toCubicMeters[unit]
    const tc = this.constructor.toCubicMeters

    this.resultCubicMeterTarget.textContent = this.fmt(m3 / tc.cubic_meter)
    this.resultCubicFootTarget.textContent = this.fmt(m3 / tc.cubic_foot)
    this.resultCubicInchTarget.textContent = this.fmt(m3 / tc.cubic_inch)
    this.resultCubicYardTarget.textContent = this.fmt(m3 / tc.cubic_yard)
    this.resultLiterTarget.textContent = this.fmt(m3 / tc.liter)
    this.resultGallonUsTarget.textContent = this.fmt(m3 / tc.gallon_us)
    this.resultGallonUkTarget.textContent = this.fmt(m3 / tc.gallon_uk)
  }

  clearAll() {
    const dash = "--"
    this.resultCubicMeterTarget.textContent = dash
    this.resultCubicFootTarget.textContent = dash
    this.resultCubicInchTarget.textContent = dash
    this.resultCubicYardTarget.textContent = dash
    this.resultLiterTarget.textContent = dash
    this.resultGallonUsTarget.textContent = dash
    this.resultGallonUkTarget.textContent = dash
  }

  fmt(n) {
    if (Math.abs(n) >= 1) return parseFloat(n.toFixed(4))
    return parseFloat(n.toFixed(8))
  }

  copy() {
    const lines = [
      `Cubic Meters (m³): ${this.resultCubicMeterTarget.textContent}`,
      `Cubic Feet (ft³): ${this.resultCubicFootTarget.textContent}`,
      `Cubic Inches (in³): ${this.resultCubicInchTarget.textContent}`,
      `Cubic Yards (yd³): ${this.resultCubicYardTarget.textContent}`,
      `Liters (L): ${this.resultLiterTarget.textContent}`,
      `US Gallons: ${this.resultGallonUsTarget.textContent}`,
      `UK Gallons: ${this.resultGallonUkTarget.textContent}`
    ]
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
