import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["conversion", "input", "result"]

  static conversions = {
    cups_ml:    { factor: 236.588, label: "mL" },
    ml_cups:    { factor: 1 / 236.588, label: "cups" },
    tbsp_ml:    { factor: 14.787, label: "mL" },
    ml_tbsp:    { factor: 1 / 14.787, label: "tbsp" },
    tsp_ml:     { factor: 4.929, label: "mL" },
    ml_tsp:     { factor: 1 / 4.929, label: "tsp" },
    oz_g:       { factor: 28.3495, label: "g" },
    g_oz:       { factor: 1 / 28.3495, label: "oz" },
    cups_tbsp:  { factor: 16, label: "tbsp" },
    tbsp_tsp:   { factor: 3, label: "tsp" }
  }

  convert() {
    const type = this.conversionTarget.value
    const input = parseFloat(this.inputTarget.value) || 0

    const conv = this.constructor.conversions[type]
    if (!conv) {
      this.resultTarget.textContent = "0.00"
      return
    }

    const result = input * conv.factor

    this.resultTarget.textContent = this.fmt(result) + " " + conv.label
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
