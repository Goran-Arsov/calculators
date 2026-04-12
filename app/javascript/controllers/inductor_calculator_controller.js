import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mode",
    "inductance", "current", "resistance",
    "basicGroup", "comboGroup", "timeConstantGroup",
    "inductances",
    "basicResults", "comboResults", "tcResults",
    "resultInductance", "resultInductanceMh", "resultCurrent",
    "resultEnergy", "resultEnergyMj",
    "resultTotalInductance", "resultTotalInductanceMh", "resultCount",
    "resultTimeConstant", "resultTimeConstantMs",
    "resultTime63", "resultTime95", "resultTime99"
  ]

  connect() {
    this.updateFields()
  }

  updateFields() {
    const mode = this.modeTarget.value
    this.basicGroupTarget.classList.toggle("hidden", mode !== "basic")
    this.comboGroupTarget.classList.toggle("hidden", mode !== "series" && mode !== "parallel")
    this.timeConstantGroupTarget.classList.toggle("hidden", mode !== "time_constant")
    this.basicResultsTarget.classList.add("hidden")
    this.comboResultsTarget.classList.add("hidden")
    this.tcResultsTarget.classList.add("hidden")
  }

  calculate() {
    const mode = this.modeTarget.value
    if (mode === "basic") this.calcBasic()
    else if (mode === "series" || mode === "parallel") this.calcCombo(mode)
    else if (mode === "time_constant") this.calcTimeConstant()
  }

  calcBasic() {
    const L = parseFloat(this.inductanceTarget.value)
    const I = parseFloat(this.currentTarget.value)
    if (isNaN(L) || L <= 0 || isNaN(I)) { this.basicResultsTarget.classList.add("hidden"); return }

    const energy = 0.5 * L * I * I

    this.basicResultsTarget.classList.remove("hidden")
    this.resultInductanceTarget.textContent = this.fmtSci(L) + " H"
    this.resultInductanceMhTarget.textContent = this.fmt(L * 1e3) + " mH"
    this.resultCurrentTarget.textContent = this.fmt(I) + " A"
    this.resultEnergyTarget.textContent = this.fmtSci(energy) + " J"
    this.resultEnergyMjTarget.textContent = this.fmt(energy * 1e3) + " mJ"
  }

  calcCombo(mode) {
    const input = this.inductancesTarget.value
    const values = input.split(",").map(s => parseFloat(s.trim())).filter(n => !isNaN(n) && n > 0)
    if (values.length < 2) { this.comboResultsTarget.classList.add("hidden"); return }

    let total
    if (mode === "series") {
      total = values.reduce((sum, l) => sum + l, 0)
    } else {
      const invTotal = values.reduce((sum, l) => sum + 1/l, 0)
      total = 1 / invTotal
    }

    this.comboResultsTarget.classList.remove("hidden")
    this.resultTotalInductanceTarget.textContent = this.fmtSci(total) + " H"
    this.resultTotalInductanceMhTarget.textContent = this.fmt(total * 1e3) + " mH"
    this.resultCountTarget.textContent = values.length + " inductors"
  }

  calcTimeConstant() {
    const L = parseFloat(this.inductanceTarget.value)
    const R = parseFloat(this.resistanceTarget.value)
    if (isNaN(L) || L <= 0 || isNaN(R) || R <= 0) { this.tcResultsTarget.classList.add("hidden"); return }

    const tau = L / R

    this.tcResultsTarget.classList.remove("hidden")
    this.resultTimeConstantTarget.textContent = this.fmtSci(tau) + " s"
    this.resultTimeConstantMsTarget.textContent = this.fmt(tau * 1e3) + " ms"
    this.resultTime63Target.textContent = this.fmtSci(tau) + " s"
    this.resultTime95Target.textContent = this.fmtSci(3 * tau) + " s"
    this.resultTime99Target.textContent = this.fmtSci(5 * tau) + " s"
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
    let container
    if (mode === "basic") container = this.basicResultsTarget
    else if (mode === "time_constant") container = this.tcResultsTarget
    else container = this.comboResultsTarget
    const results = container.querySelectorAll("[data-result]")
    const lines = Array.from(results).map(el => el.textContent)
    navigator.clipboard.writeText("Inductor: " + lines.join(" | "))
  }
}
