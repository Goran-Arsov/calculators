import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["value", "roundTo", "sigFigs", "scientific", "rounded"]

  calculate() {
    const val = this.valueTarget.value.trim()
    const roundTo = parseInt(this.roundToTarget.value)

    if (!val) {
      this.clearResults()
      return
    }

    const numericVal = parseFloat(val)
    if (isNaN(numericVal)) {
      this.sigFigsTarget.textContent = "Invalid number"
      this.scientificTarget.textContent = "—"
      this.roundedTarget.textContent = "—"
      return
    }

    const sigFigCount = this.countSigFigs(val)
    this.sigFigsTarget.textContent = sigFigCount

    this.scientificTarget.textContent = numericVal.toExponential(6)

    if (!isNaN(roundTo) && roundTo > 0) {
      const rounded = this.roundToSigFigs(numericVal, roundTo)
      this.roundedTarget.textContent = rounded
    } else {
      this.roundedTarget.textContent = "—"
    }
  }

  countSigFigs(str) {
    let s = str.trim().replace(/^[+-]/, "")

    // Handle scientific notation
    const eMatch = s.match(/^([^eE]+)[eE]/)
    if (eMatch) s = eMatch[1]

    if (s === "0") return 1

    if (s.includes(".")) {
      const [intPart, decPart] = s.split(".")
      const cleanInt = (intPart || "0").replace(/^0+/, "")
      if (cleanInt === "" || cleanInt === "0") {
        // 0.00xyz
        const stripped = decPart.replace(/^0*/, "")
        return stripped.length || 1
      } else {
        const allDigits = (intPart + decPart).replace(/^0+/, "")
        return allDigits.length || 1
      }
    } else {
      const stripped = s.replace(/^0+/, "")
      if (stripped === "") return 1
      const noTrailing = stripped.replace(/0+$/, "")
      return noTrailing.length || 1
    }
  }

  roundToSigFigs(value, sigFigs) {
    if (value === 0) return "0"
    const d = Math.floor(Math.log10(Math.abs(value))) + 1
    const power = sigFigs - d
    const magnitude = Math.pow(10, power)
    const result = Math.round(value * magnitude) / magnitude
    return result.toString()
  }

  clearResults() {
    this.sigFigsTarget.textContent = "—"
    this.scientificTarget.textContent = "—"
    this.roundedTarget.textContent = "—"
  }

  copy() {
    const sf = this.sigFigsTarget.textContent
    const sci = this.scientificTarget.textContent
    const rnd = this.roundedTarget.textContent
    navigator.clipboard.writeText(`Significant Figures: ${sf}\nScientific Notation: ${sci}\nRounded: ${rnd}`)
  }
}
