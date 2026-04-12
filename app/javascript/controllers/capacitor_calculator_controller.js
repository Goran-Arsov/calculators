import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mode",
    "capacitance", "voltage", "charge",
    "basicGroup", "comboGroup",
    "capacitances",
    "basicResults", "comboResults",
    "resultCapacitance", "resultCapacitanceUf", "resultVoltage",
    "resultCharge", "resultChargeUc", "resultEnergy", "resultEnergyUj",
    "resultTotalCapacitance", "resultTotalCapacitanceUf", "resultCount"
  ]

  connect() {
    this.updateFields()
  }

  updateFields() {
    const mode = this.modeTarget.value
    const isBasic = mode === "basic"
    this.basicGroupTarget.classList.toggle("hidden", !isBasic)
    this.comboGroupTarget.classList.toggle("hidden", isBasic)
    this.basicResultsTarget.classList.add("hidden")
    this.comboResultsTarget.classList.add("hidden")
  }

  calculate() {
    const mode = this.modeTarget.value
    if (mode === "basic") {
      this.calcBasic()
    } else {
      this.calcCombo(mode)
    }
  }

  calcBasic() {
    const C = parseFloat(this.capacitanceTarget.value) || null
    const V = parseFloat(this.voltageTarget.value) || null
    const Q = parseFloat(this.chargeTarget.value) || null

    let cap, volt, charge, energy
    const provided = [C, V, Q].filter(x => x !== null && !isNaN(x)).length
    if (provided < 2) { this.basicResultsTarget.classList.add("hidden"); return }

    if (C && V) {
      cap = C; volt = V; charge = C * V; energy = 0.5 * C * V * V
    } else if (Q && V) {
      charge = Q; volt = V; cap = Q / V; energy = 0.5 * cap * V * V
    } else if (Q && C) {
      charge = Q; cap = C; volt = Q / C; energy = 0.5 * C * volt * volt
    }

    this.basicResultsTarget.classList.remove("hidden")
    this.resultCapacitanceTarget.textContent = this.fmtSci(cap) + " F"
    this.resultCapacitanceUfTarget.textContent = this.fmt(cap * 1e6) + " \u00B5F"
    this.resultVoltageTarget.textContent = this.fmt(volt) + " V"
    this.resultChargeTarget.textContent = this.fmtSci(charge) + " C"
    this.resultChargeUcTarget.textContent = this.fmt(charge * 1e6) + " \u00B5C"
    this.resultEnergyTarget.textContent = this.fmtSci(energy) + " J"
    this.resultEnergyUjTarget.textContent = this.fmt(energy * 1e6) + " \u00B5J"
  }

  calcCombo(mode) {
    const input = this.capacitancesTarget.value
    const values = input.split(",").map(s => parseFloat(s.trim())).filter(n => !isNaN(n) && n > 0)
    if (values.length < 2) { this.comboResultsTarget.classList.add("hidden"); return }

    let total
    if (mode === "series") {
      const invTotal = values.reduce((sum, c) => sum + 1/c, 0)
      total = 1 / invTotal
    } else {
      total = values.reduce((sum, c) => sum + c, 0)
    }

    this.comboResultsTarget.classList.remove("hidden")
    this.resultTotalCapacitanceTarget.textContent = this.fmtSci(total) + " F"
    this.resultTotalCapacitanceUfTarget.textContent = this.fmt(total * 1e6) + " \u00B5F"
    this.resultCountTarget.textContent = values.length + " capacitors"
  }

  fmt(n) {
    const abs = Math.abs(n)
    if (abs >= 1e6) return n.toExponential(4)
    if (abs >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  fmtSci(n) {
    const abs = Math.abs(n)
    if (abs < 0.001 || abs >= 1e6) return n.toExponential(4)
    return n.toFixed(6).replace(/\.?0+$/, "")
  }

  copy() {
    const mode = this.modeTarget.value
    const container = mode === "basic" ? this.basicResultsTarget : this.comboResultsTarget
    const results = container.querySelectorAll("[data-result]")
    const lines = Array.from(results).map(el => el.textContent)
    navigator.clipboard.writeText("Capacitor: " + lines.join(" | "))
  }
}
