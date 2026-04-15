import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "battery", "load", "dod", "efficiency",
    "resultUsable", "resultRuntime", "resultDisplay"
  ]

  connect() { this.calculate() }

  calculate() {
    const battery = parseFloat(this.batteryTarget.value) || 0
    const load = parseFloat(this.loadTarget.value) || 0
    const dod = parseFloat(this.dodTarget.value) || 0
    const eff = parseFloat(this.efficiencyTarget.value) || 0

    if (battery <= 0 || load <= 0 || dod < 10 || dod > 100 || eff < 70 || eff > 100) {
      this.clear()
      return
    }

    const usableWh = battery * 1000 * (dod / 100) * (eff / 100)
    const runtimeHours = usableWh / load
    const runtimeMinutes = runtimeHours * 60
    const hours = Math.floor(runtimeHours)
    const minutes = Math.round(runtimeMinutes - hours * 60)

    this.resultUsableTarget.textContent = `${(usableWh / 1000).toFixed(2)} kWh usable`
    this.resultRuntimeTarget.textContent = `${runtimeHours.toFixed(2)} hours`
    this.resultDisplayTarget.textContent = `${hours} h ${minutes} min`
  }

  clear() {
    ["Usable","Runtime","Display"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Battery backup runtime:",
      `Usable energy: ${this.resultUsableTarget.textContent}`,
      `Runtime: ${this.resultRuntimeTarget.textContent}`,
      `Time: ${this.resultDisplayTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
