import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["conversion", "input", "result", "fromUnit", "toUnit"]

  static conversions = {
    cups_ml:    { factor: 236.588, from: "cups", to: "mL" },
    ml_cups:    { factor: 1 / 236.588, from: "mL", to: "cups" },
    tbsp_ml:    { factor: 14.787, from: "tbsp", to: "mL" },
    ml_tbsp:    { factor: 1 / 14.787, from: "mL", to: "tbsp" },
    tsp_ml:     { factor: 4.929, from: "tsp", to: "mL" },
    ml_tsp:     { factor: 1 / 4.929, from: "mL", to: "tsp" },
    oz_g:       { factor: 28.3495, from: "oz", to: "g" },
    g_oz:       { factor: 1 / 28.3495, from: "g", to: "oz" },
    cups_tbsp:  { factor: 16, from: "cups", to: "tbsp" },
    tbsp_tsp:   { factor: 3, from: "tbsp", to: "tsp" },
    lb_kg:      { factor: 0.453592, from: "lb", to: "kg" },
    kg_lb:      { factor: 2.20462, from: "kg", to: "lb" }
  }

  convert() {
    const type = this.conversionTarget.value
    const input = parseFloat(this.inputTarget.value) || 0

    const conv = this.constructor.conversions[type]
    if (!conv) {
      this.resultTarget.textContent = "0.00"
      return
    }

    if (this.hasFromUnitTarget) this.fromUnitTarget.textContent = conv.from
    if (this.hasToUnitTarget) this.toUnitTarget.textContent = conv.to

    const result = input * conv.factor

    this.resultTarget.textContent = this.fmt(result) + " " + conv.to
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
