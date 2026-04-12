import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mode", "torque", "rpm", "horsepowerInput",
    "resultHp", "resultTorque", "resultKw", "resultNm",
    "torqueGroup", "hpGroup"
  ]

  connect() {
    this.updateMode()
  }

  updateMode() {
    const mode = this.modeTarget.value
    if (mode === "hp_from_torque") {
      this.torqueGroupTarget.classList.remove("hidden")
      this.hpGroupTarget.classList.add("hidden")
    } else {
      this.torqueGroupTarget.classList.add("hidden")
      this.hpGroupTarget.classList.remove("hidden")
    }
    this.calculate()
  }

  calculate() {
    const mode = this.modeTarget.value
    const rpm = parseFloat(this.rpmTarget.value) || 0

    if (rpm <= 0) {
      this.clearResults()
      return
    }

    let hp, torque

    if (mode === "hp_from_torque") {
      torque = parseFloat(this.torqueTarget.value) || 0
      if (torque <= 0) { this.clearResults(); return }
      hp = (torque * rpm) / 5252
    } else {
      hp = parseFloat(this.horsepowerInputTarget.value) || 0
      if (hp <= 0) { this.clearResults(); return }
      torque = (hp * 5252) / rpm
    }

    const kw = hp * 0.7457
    const nm = torque * 1.3558

    this.resultHpTarget.textContent = hp.toFixed(2) + " HP"
    this.resultTorqueTarget.textContent = torque.toFixed(2) + " lb-ft"
    this.resultKwTarget.textContent = kw.toFixed(2) + " kW"
    this.resultNmTarget.textContent = nm.toFixed(2) + " Nm"
  }

  clearResults() {
    this.resultHpTarget.textContent = "0.00 HP"
    this.resultTorqueTarget.textContent = "0.00 lb-ft"
    this.resultKwTarget.textContent = "0.00 kW"
    this.resultNmTarget.textContent = "0.00 Nm"
  }

  copy() {
    const text = `Horsepower: ${this.resultHpTarget.textContent}\nTorque: ${this.resultTorqueTarget.textContent}\nKilowatts: ${this.resultKwTarget.textContent}\nNewton-meters: ${this.resultNmTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
