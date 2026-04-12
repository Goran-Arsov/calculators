import { Controller } from "@hotwired/stimulus"

const MINIMUM_SLOPES = {
  2: { slopeInPerFt: 0.25, slopePct: 2.08 },
  3: { slopeInPerFt: 0.25, slopePct: 2.08 },
  4: { slopeInPerFt: 0.125, slopePct: 1.04 },
  6: { slopeInPerFt: 0.125, slopePct: 1.04 },
  8: { slopeInPerFt: 0.0625, slopePct: 0.52 }
}

export default class extends Controller {
  static targets = ["runLength", "pipeDiameter", "slopePct",
    "resultSlopePct", "resultSlopeInPerFt", "resultTotalDropIn",
    "resultTotalDropFt", "resultMeetsMinimum", "resultMinSlope",
    "resultVelocity"]

  calculate() {
    const runLength = parseFloat(this.runLengthTarget.value) || 0
    const pipeDiameter = parseInt(this.pipeDiameterTarget.value) || 4
    const customSlopePct = this.slopePctTarget.value.trim() !== "" ? parseFloat(this.slopePctTarget.value) : null

    if (runLength <= 0 || !MINIMUM_SLOPES[pipeDiameter]) {
      this.clearResults()
      return
    }

    const pipeSpec = MINIMUM_SLOPES[pipeDiameter]
    const slopePct = customSlopePct !== null && customSlopePct > 0 ? customSlopePct : pipeSpec.slopePct
    const slopeInPerFt = (slopePct / 100) * 12
    const totalDropIn = (slopeInPerFt * runLength).toFixed(2)
    const totalDropFt = (totalDropIn / 12).toFixed(3)
    const meetsMinimum = slopePct >= pipeSpec.slopePct

    // Manning's equation simplified for velocity
    const n = 0.013
    const radiusFt = (pipeDiameter / 2) / 12
    const hydraulicRadius = radiusFt / 2
    const slopeDecimal = slopePct / 100
    const velocity = ((1.486 / n) * Math.pow(hydraulicRadius, 2/3) * Math.pow(slopeDecimal, 0.5)).toFixed(2)

    this.resultSlopePctTarget.textContent = `${slopePct.toFixed(2)}%`
    this.resultSlopeInPerFtTarget.textContent = `${slopeInPerFt.toFixed(3)}"/ft`
    this.resultTotalDropInTarget.textContent = `${totalDropIn}"`
    this.resultTotalDropFtTarget.textContent = `${totalDropFt} ft`
    this.resultMeetsMinimumTarget.textContent = meetsMinimum ? "Yes" : "No"
    this.resultMeetsMinimumTarget.className = meetsMinimum
      ? "text-xl font-bold text-green-600 dark:text-green-400"
      : "text-xl font-bold text-red-600 dark:text-red-400"
    this.resultMinSlopeTarget.textContent = `${pipeSpec.slopePct}% (${pipeSpec.slopeInPerFt}"/ft)`
    this.resultVelocityTarget.textContent = `${velocity} ft/s`
  }

  clearResults() {
    this.resultSlopePctTarget.textContent = "0%"
    this.resultSlopeInPerFtTarget.textContent = "0\"/ft"
    this.resultTotalDropInTarget.textContent = "0\""
    this.resultTotalDropFtTarget.textContent = "0 ft"
    this.resultMeetsMinimumTarget.textContent = "--"
    this.resultMeetsMinimumTarget.className = "text-xl font-bold text-gray-400"
    this.resultMinSlopeTarget.textContent = "--"
    this.resultVelocityTarget.textContent = "0 ft/s"
  }

  copy() {
    const slope = this.resultSlopePctTarget.textContent
    const dropIn = this.resultTotalDropInTarget.textContent
    const dropFt = this.resultTotalDropFtTarget.textContent
    const velocity = this.resultVelocityTarget.textContent
    const text = `Drainage Slope Estimate:\nSlope: ${slope}\nTotal Drop: ${dropIn} (${dropFt})\nFlow Velocity: ${velocity}`
    navigator.clipboard.writeText(text)
  }
}
