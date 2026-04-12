import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mode",
    "primaryVoltage", "secondaryVoltage", "primaryCurrent",
    "primaryTurns", "secondaryTurns", "efficiency",
    "primaryVoltageGroup", "secondaryVoltageGroup", "primaryCurrentGroup",
    "primaryTurnsGroup", "secondaryTurnsGroup",
    "results",
    "resultSecondaryVoltage", "resultTurnsRatio", "resultType",
    "resultPrimaryCurrent", "resultSecondaryCurrent",
    "resultPrimaryPower", "resultSecondaryPower",
    "resultSecondaryTurns"
  ]

  connect() {
    this.updateFields()
  }

  updateFields() {
    const mode = this.modeTarget.value
    // Show all by default, then hide based on mode
    this.primaryVoltageGroupTarget.classList.remove("hidden")
    this.secondaryVoltageGroupTarget.classList.remove("hidden")
    this.primaryCurrentGroupTarget.classList.remove("hidden")
    this.primaryTurnsGroupTarget.classList.remove("hidden")
    this.secondaryTurnsGroupTarget.classList.remove("hidden")

    if (mode === "find_output_voltage") {
      this.secondaryVoltageGroupTarget.classList.add("hidden")
    } else if (mode === "find_output_current") {
      this.primaryTurnsGroupTarget.classList.add("hidden")
      this.secondaryTurnsGroupTarget.classList.add("hidden")
    } else if (mode === "find_turns_ratio") {
      this.primaryTurnsGroupTarget.classList.add("hidden")
      this.secondaryTurnsGroupTarget.classList.add("hidden")
    } else if (mode === "find_turns") {
      this.secondaryTurnsGroupTarget.classList.add("hidden")
    }

    this.resultsTarget.classList.add("hidden")
  }

  calculate() {
    const mode = this.modeTarget.value
    const eff = (parseFloat(this.efficiencyTarget.value) || 100) / 100

    let V1, V2, I1, I2, N1, N2, ratio, P1, P2

    if (mode === "find_output_voltage") {
      V1 = parseFloat(this.primaryVoltageTarget.value)
      N1 = parseFloat(this.primaryTurnsTarget.value)
      N2 = parseFloat(this.secondaryTurnsTarget.value)
      if (isNaN(V1) || V1 <= 0 || isNaN(N1) || N1 <= 0 || isNaN(N2) || N2 <= 0) { this.resultsTarget.classList.add("hidden"); return }
      ratio = N1 / N2
      V2 = V1 / ratio
      I1 = parseFloat(this.primaryCurrentTarget.value) || null
      if (I1) { P1 = V1 * I1; P2 = P1 * eff; I2 = P2 / V2 }
    } else if (mode === "find_output_current") {
      V1 = parseFloat(this.primaryVoltageTarget.value)
      V2 = parseFloat(this.secondaryVoltageTarget.value)
      I1 = parseFloat(this.primaryCurrentTarget.value)
      if (isNaN(V1) || V1 <= 0 || isNaN(V2) || V2 <= 0 || isNaN(I1) || I1 <= 0) { this.resultsTarget.classList.add("hidden"); return }
      ratio = V1 / V2
      P1 = V1 * I1; P2 = P1 * eff; I2 = P2 / V2
    } else if (mode === "find_turns_ratio") {
      V1 = parseFloat(this.primaryVoltageTarget.value)
      V2 = parseFloat(this.secondaryVoltageTarget.value)
      if (isNaN(V1) || V1 <= 0 || isNaN(V2) || V2 <= 0) { this.resultsTarget.classList.add("hidden"); return }
      ratio = V1 / V2
      I1 = parseFloat(this.primaryCurrentTarget.value) || null
      if (I1) { P1 = V1 * I1; P2 = P1 * eff; I2 = P2 / V2 }
    } else if (mode === "find_turns") {
      V1 = parseFloat(this.primaryVoltageTarget.value)
      V2 = parseFloat(this.secondaryVoltageTarget.value)
      N1 = parseFloat(this.primaryTurnsTarget.value)
      if (isNaN(V1) || V1 <= 0 || isNaN(V2) || V2 <= 0 || isNaN(N1) || N1 <= 0) { this.resultsTarget.classList.add("hidden"); return }
      ratio = V1 / V2
      N2 = N1 * V2 / V1
      I1 = parseFloat(this.primaryCurrentTarget.value) || null
      if (I1) { P1 = V1 * I1; P2 = P1 * eff; I2 = P2 / V2 }
    }

    let type
    if (ratio > 1.001) type = "Step-down"
    else if (ratio < 0.999) type = "Step-up"
    else type = "Isolation (1:1)"

    const ratioDisplay = ratio >= 1 ? ratio.toFixed(2) + ":1" : "1:" + (1/ratio).toFixed(2)

    this.resultsTarget.classList.remove("hidden")
    this.resultSecondaryVoltageTarget.textContent = V2 ? this.fmt(V2) + " V" : "\u2014"
    this.resultTurnsRatioTarget.textContent = ratioDisplay
    this.resultTypeTarget.textContent = type
    this.resultPrimaryCurrentTarget.textContent = I1 ? this.fmt(I1) + " A" : "\u2014"
    this.resultSecondaryCurrentTarget.textContent = I2 ? this.fmt(I2) + " A" : "\u2014"
    this.resultPrimaryPowerTarget.textContent = P1 ? this.fmt(P1) + " W" : "\u2014"
    this.resultSecondaryPowerTarget.textContent = P2 ? this.fmt(P2) + " W" : "\u2014"
    this.resultSecondaryTurnsTarget.textContent = N2 ? Math.round(N2) + " turns" : "\u2014"
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
    navigator.clipboard.writeText("Transformer: " + lines.join(" | "))
  }
}
