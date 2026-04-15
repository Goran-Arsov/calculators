import { Controller } from "@hotwired/stimulus"
import { FT_TO_M } from "utils/units"

// NEC Chapter 9 Table 8 — resistance in ohms/1000 ft at 75 °C.
const R_PER_1000FT = {
  "14":  { cu: 3.140, al: 5.060 },
  "12":  { cu: 1.980, al: 3.180 },
  "10":  { cu: 1.240, al: 2.000 },
  "8":   { cu: 0.778, al: 1.260 },
  "6":   { cu: 0.491, al: 0.808 },
  "4":   { cu: 0.308, al: 0.508 },
  "3":   { cu: 0.245, al: 0.403 },
  "2":   { cu: 0.194, al: 0.319 },
  "1":   { cu: 0.154, al: 0.253 },
  "1/0": { cu: 0.122, al: 0.201 },
  "2/0": { cu: 0.0967, al: 0.159 },
  "3/0": { cu: 0.0766, al: 0.126 },
  "4/0": { cu: 0.0608, al: 0.100 },
  "250": { cu: 0.0515, al: 0.0847 },
  "350": { cu: 0.0367, al: 0.0605 },
  "500": { cu: 0.0258, al: 0.0424 }
}

export default class extends Controller {
  static targets = [
    "awg", "length", "amps", "voltage", "phase", "material",
    "unitSystem", "lengthLabel",
    "resultVdVolts", "resultVdPct", "resultEndVolts", "resultBranch", "resultTotal"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const n = parseFloat(this.lengthTarget.value)
    if (Number.isFinite(n)) this.lengthTarget.value = (toMetric ? n * FT_TO_M : n / FT_TO_M).toFixed(2)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "One-way length (m)" : "One-way length (ft)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const awg = this.awgTarget.value
    const lengthInput = parseFloat(this.lengthTarget.value) || 0
    const amps = parseFloat(this.ampsTarget.value) || 0
    const voltage = parseFloat(this.voltageTarget.value) || 0
    const phase = this.phaseTarget.value
    const material = this.materialTarget.value

    if (!R_PER_1000FT[awg] || lengthInput <= 0 || amps <= 0 || voltage <= 0) {
      this.clear()
      return
    }

    const lengthFt = metric ? lengthInput / FT_TO_M : lengthInput
    const r = R_PER_1000FT[awg][material]
    const k = phase === "three" ? Math.sqrt(3) : 2
    const vdVolts = (k * lengthFt * amps * r) / 1000
    const vdPct = (vdVolts / voltage) * 100
    const endVolts = voltage - vdVolts
    const withinBranch = vdPct <= 3
    const withinTotal = vdPct <= 5

    this.resultVdVoltsTarget.textContent = `${vdVolts.toFixed(3)} V`
    this.resultVdPctTarget.textContent = `${vdPct.toFixed(2)}%`
    this.resultEndVoltsTarget.textContent = `${endVolts.toFixed(2)} V`
    this.resultBranchTarget.textContent = withinBranch ? "✓ Within 3% (branch)" : "✗ Exceeds 3% (branch)"
    this.resultTotalTarget.textContent = withinTotal ? "✓ Within 5% (feeder + branch)" : "✗ Exceeds 5% (feeder + branch)"
    this.resultBranchTarget.className = withinBranch
      ? "text-base font-bold text-green-600 dark:text-green-400"
      : "text-base font-bold text-red-600 dark:text-red-400"
    this.resultTotalTarget.className = withinTotal
      ? "text-base font-bold text-green-600 dark:text-green-400"
      : "text-base font-bold text-red-600 dark:text-red-400"
  }

  clear() {
    ["VdVolts","VdPct","EndVolts","Branch","Total"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Voltage drop:",
      `Voltage drop: ${this.resultVdVoltsTarget.textContent} (${this.resultVdPctTarget.textContent})`,
      `End voltage: ${this.resultEndVoltsTarget.textContent}`,
      this.resultBranchTarget.textContent,
      this.resultTotalTarget.textContent
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
