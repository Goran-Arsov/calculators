import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["voltage", "current", "resistance", "mode",
                     "resultVoltage", "resultCurrent", "resultResistance", "resultPower"]

  calculate() {
    const mode = this.modeTarget.value
    const v = parseFloat(this.voltageTarget.value)
    const i = parseFloat(this.currentTarget.value)
    const r = parseFloat(this.resistanceTarget.value)

    if (mode === "voltage" && !isNaN(i) && r > 0) {
      const voltage = i * r
      this.resultVoltageTarget.textContent = this.fmt(voltage)
      this.resultCurrentTarget.textContent = this.fmt(i)
      this.resultResistanceTarget.textContent = this.fmt(r)
      this.resultPowerTarget.textContent = this.fmt(voltage * i)
    } else if (mode === "current" && !isNaN(v) && r > 0) {
      const current = v / r
      this.resultVoltageTarget.textContent = this.fmt(v)
      this.resultCurrentTarget.textContent = this.fmt(current)
      this.resultResistanceTarget.textContent = this.fmt(r)
      this.resultPowerTarget.textContent = this.fmt(v * current)
    } else if (mode === "resistance" && !isNaN(v) && i !== 0 && !isNaN(i)) {
      const resistance = v / i
      this.resultVoltageTarget.textContent = this.fmt(v)
      this.resultCurrentTarget.textContent = this.fmt(i)
      this.resultResistanceTarget.textContent = this.fmt(resistance)
      this.resultPowerTarget.textContent = this.fmt(v * i)
    } else {
      this.clearResults()
    }
  }

  clearResults() {
    this.resultVoltageTarget.textContent = "—"
    this.resultCurrentTarget.textContent = "—"
    this.resultResistanceTarget.textContent = "—"
    this.resultPowerTarget.textContent = "—"
  }

  fmt(n) { return n.toFixed(4).replace(/\.?0+$/, "") }

  copy() {
    const text = `Voltage: ${this.resultVoltageTarget.textContent} V\nCurrent: ${this.resultCurrentTarget.textContent} A\nResistance: ${this.resultResistanceTarget.textContent} Ω\nPower: ${this.resultPowerTarget.textContent} W`
    navigator.clipboard.writeText(text)
  }
}
