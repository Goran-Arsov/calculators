import { Controller } from "@hotwired/stimulus"

// NEC Chapter 9 Table 5 — THWN-2 conductor area sq in
const WIRE_AREA = {
  "14": 0.0097, "12": 0.0133, "10": 0.0211, "8": 0.0366, "6": 0.0507,
  "4": 0.0824, "3": 0.0973, "2": 0.1158, "1": 0.1562,
  "1/0": 0.1855, "2/0": 0.2223, "3/0": 0.2679, "4/0": 0.3237,
  "250": 0.3970, "350": 0.5242, "500": 0.7073
}

// NEC Chapter 9 Table 4 — conduit total internal area sq in
const CONDUIT_AREA = {
  emt: { "1/2": 0.304, "3/4": 0.533, "1": 0.864, "1-1/4": 1.496, "1-1/2": 2.036, "2": 3.356, "2-1/2": 5.858, "3": 8.846, "4": 14.753 },
  imc: { "1/2": 0.342, "3/4": 0.586, "1": 0.959, "1-1/4": 1.647, "1-1/2": 2.225, "2": 3.630, "2-1/2": 5.135, "3": 7.922, "4": 12.692 },
  rmc: { "1/2": 0.314, "3/4": 0.549, "1": 0.887, "1-1/4": 1.526, "1-1/2": 2.071, "2": 3.408, "2-1/2": 4.866, "3": 7.499, "4": 12.554 },
  pvc40: { "1/2": 0.285, "3/4": 0.508, "1": 0.832, "1-1/4": 1.453, "1-1/2": 1.986, "2": 3.291, "2-1/2": 4.695, "3": 7.268, "4": 12.554 }
}

// NEC Chapter 9 Table 1 — max fill percent by wire count
const FILL_PCT = { 1: 53, 2: 31 } // 3+ defaults to 40
const SQIN_TO_MM2 = 645.16

export default class extends Controller {
  static targets = ["conduit", "size", "awg", "count",
                    "resultUsed", "resultUsedPct", "resultMaxPct", "resultMaxWires", "resultOk"]

  connect() { this.calculate() }

  calculate() {
    const conduitType = this.conduitTarget.value
    const size = this.sizeTarget.value
    const awg = this.awgTarget.value
    const count = parseInt(this.countTarget.value, 10) || 0

    const conduitArea = (CONDUIT_AREA[conduitType] || {})[size]
    const wireArea = WIRE_AREA[awg]
    if (!conduitArea || !wireArea || count < 1) {
      this.clear()
      return
    }

    const fillAllowed = FILL_PCT[count] || 40
    const usedArea = wireArea * count
    const usedPct = (usedArea / conduitArea) * 100
    const maxFillArea = conduitArea * fillAllowed / 100
    const maxWires = Math.floor(maxFillArea / wireArea)
    const withinCode = usedPct <= fillAllowed

    this.resultUsedTarget.textContent = `${usedArea.toFixed(4)} sq in (${(usedArea * SQIN_TO_MM2).toFixed(0)} mm²)`
    this.resultUsedPctTarget.textContent = `${usedPct.toFixed(1)}%`
    this.resultMaxPctTarget.textContent = `${fillAllowed}% fill allowed`
    this.resultMaxWiresTarget.textContent = maxWires
    this.resultOkTarget.textContent = withinCode ? "✓ Within NEC fill limit" : "✗ Exceeds NEC fill limit"
    this.resultOkTarget.className = withinCode
      ? "text-base font-bold text-green-600 dark:text-green-400"
      : "text-base font-bold text-red-600 dark:text-red-400"
  }

  clear() {
    ["Used", "UsedPct", "MaxPct", "MaxWires", "Ok"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Conduit fill:",
      `Used area: ${this.resultUsedTarget.textContent}`,
      `Used %: ${this.resultUsedPctTarget.textContent}`,
      `NEC: ${this.resultMaxPctTarget.textContent}`,
      `Max wires (this AWG): ${this.resultMaxWiresTarget.textContent}`,
      this.resultOkTarget.textContent
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
