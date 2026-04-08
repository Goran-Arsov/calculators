import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value", "percentage", "mode", "result"]

  calculate() {
    const value = parseFloat(this.valueTarget.value) || 0
    const percentage = parseFloat(this.percentageTarget.value) || 0
    const mode = this.modeTarget.value

    let result
    switch (mode) {
      case "of":
        result = value * percentage / 100
        this.resultTarget.textContent = `${value}% of ${percentage} = ${this.formatNumber(result)}`
        break
      case "is_what_percent":
        if (percentage === 0) { this.resultTarget.textContent = "Cannot divide by zero"; return }
        result = (value / percentage) * 100
        this.resultTarget.textContent = `${value} is ${this.formatNumber(result)}% of ${percentage}`
        break
      case "change":
        if (value === 0) { this.resultTarget.textContent = "Original value cannot be zero"; return }
        result = ((percentage - value) / Math.abs(value)) * 100
        this.resultTarget.textContent = `Change from ${value} to ${percentage} = ${this.formatNumber(result)}%`
        break
    }
  }

  formatNumber(value) {
    return Number.isInteger(value) ? value : value.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    navigator.clipboard.writeText(this.resultTarget.textContent)
  }
}
