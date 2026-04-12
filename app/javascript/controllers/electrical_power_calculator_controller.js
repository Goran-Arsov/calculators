import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mode",
    "voltage", "current", "resistance", "power",
    "voltageGroup", "currentGroup", "resistanceGroup", "powerGroup",
    "results",
    "resultPower", "resultPowerKw", "resultVoltage",
    "resultCurrent", "resultResistance", "resultEnergyKwh"
  ]

  connect() {
    this.updateFields()
  }

  updateFields() {
    const mode = this.modeTarget.value
    // Show/hide input groups based on mode
    this.powerGroupTarget.classList.toggle("hidden", ["p_iv", "p_i2r", "p_v2r"].includes(mode))
    this.voltageGroupTarget.classList.toggle("hidden", mode === "find_voltage")
    this.currentGroupTarget.classList.toggle("hidden", mode === "find_current")
    this.resistanceGroupTarget.classList.toggle("hidden", ["p_iv", "find_current", "find_voltage"].includes(mode))

    // For p_iv: need V, I
    // For p_i2r: need I, R
    // For p_v2r: need V, R
    // For find_current: need P, V
    // For find_voltage: need P, I
    // For find_resistance: need P, V

    if (mode === "p_iv") {
      this.voltageGroupTarget.classList.remove("hidden")
      this.currentGroupTarget.classList.remove("hidden")
    } else if (mode === "p_i2r") {
      this.currentGroupTarget.classList.remove("hidden")
      this.resistanceGroupTarget.classList.remove("hidden")
    } else if (mode === "p_v2r") {
      this.voltageGroupTarget.classList.remove("hidden")
      this.resistanceGroupTarget.classList.remove("hidden")
    } else if (mode === "find_current") {
      this.powerGroupTarget.classList.remove("hidden")
      this.voltageGroupTarget.classList.remove("hidden")
    } else if (mode === "find_voltage") {
      this.powerGroupTarget.classList.remove("hidden")
      this.currentGroupTarget.classList.remove("hidden")
    } else if (mode === "find_resistance") {
      this.powerGroupTarget.classList.remove("hidden")
      this.voltageGroupTarget.classList.remove("hidden")
    }

    this.resultsTarget.classList.add("hidden")
  }

  calculate() {
    const mode = this.modeTarget.value
    let P, V, I, R

    if (mode === "p_iv") {
      V = parseFloat(this.voltageTarget.value)
      I = parseFloat(this.currentTarget.value)
      if (isNaN(V) || isNaN(I) || I === 0) { this.resultsTarget.classList.add("hidden"); return }
      P = I * V
      R = V / I
    } else if (mode === "p_i2r") {
      I = parseFloat(this.currentTarget.value)
      R = parseFloat(this.resistanceTarget.value)
      if (isNaN(I) || isNaN(R) || R <= 0) { this.resultsTarget.classList.add("hidden"); return }
      P = I * I * R
      V = I * R
    } else if (mode === "p_v2r") {
      V = parseFloat(this.voltageTarget.value)
      R = parseFloat(this.resistanceTarget.value)
      if (isNaN(V) || isNaN(R) || R <= 0) { this.resultsTarget.classList.add("hidden"); return }
      P = V * V / R
      I = V / R
    } else if (mode === "find_current") {
      P = parseFloat(this.powerTarget.value)
      V = parseFloat(this.voltageTarget.value)
      if (isNaN(P) || isNaN(V) || V === 0) { this.resultsTarget.classList.add("hidden"); return }
      I = P / V
      R = V / I
    } else if (mode === "find_voltage") {
      P = parseFloat(this.powerTarget.value)
      I = parseFloat(this.currentTarget.value)
      if (isNaN(P) || isNaN(I) || I === 0) { this.resultsTarget.classList.add("hidden"); return }
      V = P / I
      R = V / I
    } else if (mode === "find_resistance") {
      P = parseFloat(this.powerTarget.value)
      V = parseFloat(this.voltageTarget.value)
      if (isNaN(P) || P === 0 || isNaN(V)) { this.resultsTarget.classList.add("hidden"); return }
      R = V * V / P
      I = P / V
    }

    const kw = P / 1000

    this.resultsTarget.classList.remove("hidden")
    this.resultPowerTarget.textContent = this.fmt(P) + " W"
    this.resultPowerKwTarget.textContent = this.fmt(kw) + " kW"
    this.resultVoltageTarget.textContent = this.fmt(V) + " V"
    this.resultCurrentTarget.textContent = this.fmt(I) + " A"
    this.resultResistanceTarget.textContent = this.fmt(R) + " \u03A9"
    this.resultEnergyKwhTarget.textContent = this.fmt(kw) + " kWh"
  }

  fmt(n) {
    const abs = Math.abs(n)
    if (abs >= 1e6) return n.toExponential(4)
    if (abs >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const results = this.resultsTarget.querySelectorAll("[data-result]")
    const lines = Array.from(results).map(el => el.textContent)
    navigator.clipboard.writeText("Electrical Power: " + lines.join(" | "))
  }
}
