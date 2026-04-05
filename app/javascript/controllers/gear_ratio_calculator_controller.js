import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "drivingTeeth", "drivenTeeth", "inputSpeed", "inputTorque",
    "resultRatio", "resultRatioDisplay", "resultOutputSpeed",
    "resultOutputTorque", "resultMechanicalAdvantage", "resultType",
    "resultsContainer"
  ]

  calculate() {
    const driving = parseFloat(this.drivingTeethTarget.value)
    const driven = parseFloat(this.drivenTeethTarget.value)

    if (!driving || !driven || driving <= 0 || driven <= 0) {
      this.clearResults()
      return
    }

    const ratio = driven / driving
    const speed = parseFloat(this.inputSpeedTarget.value)
    const torque = parseFloat(this.inputTorqueTarget.value)

    this.resultsContainerTarget.classList.remove("hidden")
    this.resultRatioTarget.textContent = ratio.toFixed(4)
    this.resultRatioDisplayTarget.textContent = ratio >= 1
      ? ratio.toFixed(2) + ":1"
      : "1:" + (1 / ratio).toFixed(2)
    this.resultMechanicalAdvantageTarget.textContent = ratio.toFixed(4) + "\u00D7"
    this.resultTypeTarget.textContent = ratio > 1
      ? "Speed reduction / Torque increase"
      : ratio < 1
        ? "Speed increase / Torque reduction"
        : "1:1 direct drive"

    if (!isNaN(speed) && speed >= 0) {
      this.resultOutputSpeedTarget.textContent = this.fmt(speed / ratio) + " RPM"
    } else {
      this.resultOutputSpeedTarget.textContent = "\u2014"
    }

    if (!isNaN(torque) && torque >= 0) {
      this.resultOutputTorqueTarget.textContent = this.fmt(torque * ratio) + " N\u00B7m"
    } else {
      this.resultOutputTorqueTarget.textContent = "\u2014"
    }
  }

  clearResults() {
    this.resultsContainerTarget.classList.add("hidden")
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const text = "Gear Ratio: " + this.resultRatioDisplayTarget.textContent +
      " | Output Speed: " + this.resultOutputSpeedTarget.textContent +
      " | Output Torque: " + this.resultOutputTorqueTarget.textContent
    navigator.clipboard.writeText(text)
  }
}
