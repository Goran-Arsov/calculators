import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "currentForV", "resistanceForV", "resultVoltage", "powerForV",
    "voltageForI", "resistanceForI", "resultCurrent", "powerForI",
    "voltageForR", "currentForR", "resultResistance", "powerForR"
  ]

  calcVoltage() {
    const i = parseFloat(this.currentForVTarget.value)
    const r = parseFloat(this.resistanceForVTarget.value)
    if (!isNaN(i) && r > 0) {
      const v = i * r
      this.resultVoltageTarget.textContent = this.fmt(v) + " V"
      this.powerForVTarget.textContent = this.fmt(v * i) + " W"
    } else {
      this.resultVoltageTarget.textContent = "—"
      this.powerForVTarget.textContent = "—"
    }
  }

  calcCurrent() {
    const v = parseFloat(this.voltageForITarget.value)
    const r = parseFloat(this.resistanceForITarget.value)
    if (!isNaN(v) && r > 0) {
      const i = v / r
      this.resultCurrentTarget.textContent = this.fmt(i) + " A"
      this.powerForITarget.textContent = this.fmt(v * i) + " W"
    } else {
      this.resultCurrentTarget.textContent = "—"
      this.powerForITarget.textContent = "—"
    }
  }

  calcResistance() {
    const v = parseFloat(this.voltageForRTarget.value)
    const i = parseFloat(this.currentForRTarget.value)
    if (!isNaN(v) && i !== 0 && !isNaN(i)) {
      const r = v / i
      this.resultResistanceTarget.textContent = this.fmt(r) + " \u03A9"
      this.powerForRTarget.textContent = this.fmt(v * i) + " W"
    } else {
      this.resultResistanceTarget.textContent = "—"
      this.powerForRTarget.textContent = "—"
    }
  }

  fmt(n) {
    if (Math.abs(n) >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy(event) {
    const card = event.target.closest("[data-card]")
    const result = card.querySelector("[data-result]")
    navigator.clipboard.writeText(`${card.dataset.card}: ${result.textContent}`)
  }
}
