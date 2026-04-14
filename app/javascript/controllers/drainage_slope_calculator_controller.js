import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM } from "utils/units"

const MINIMUM_SLOPES = {
  2: { slopeInPerFt: 0.25, slopePct: 2.08 },
  3: { slopeInPerFt: 0.25, slopePct: 2.08 },
  4: { slopeInPerFt: 0.125, slopePct: 1.04 },
  6: { slopeInPerFt: 0.125, slopePct: 1.04 },
  8: { slopeInPerFt: 0.0625, slopePct: 0.52 }
}

const CM_PER_M = 100

export default class extends Controller {
  static targets = ["runLength", "pipeDiameter", "slopePct",
    "unitSystem", "runLengthLabel",
    "dropPerFtHeading", "totalDropSmallHeading", "totalDropLargeHeading", "velocityHeading",
    "resultSlopePct", "resultSlopeInPerFt", "resultTotalDropIn",
    "resultTotalDropFt", "resultMeetsMinimum", "resultMinSlope",
    "resultVelocity"]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el, factor) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * factor : n / factor).toFixed(2)
    }
    convert(this.runLengthTarget, FT_TO_M)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.runLengthLabelTarget.textContent = metric ? "Pipe Run Length (m)" : "Pipe Run Length (ft)"
    this.dropPerFtHeadingTarget.textContent = metric ? "Drop Per Meter" : "Drop Per Foot"
    this.totalDropSmallHeadingTarget.textContent = metric ? "Total Drop (cm)" : "Total Drop (inches)"
    this.totalDropLargeHeadingTarget.textContent = metric ? "Total Drop (m)" : "Total Drop (feet)"
    this.velocityHeadingTarget.textContent = metric ? "Flow Velocity (m/s)" : "Flow Velocity"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const runInput = parseFloat(this.runLengthTarget.value) || 0
    const runLengthFt = metric ? runInput / FT_TO_M : runInput
    const pipeDiameter = parseInt(this.pipeDiameterTarget.value) || 4
    const customSlopePct = this.slopePctTarget.value.trim() !== "" ? parseFloat(this.slopePctTarget.value) : null

    if (runLengthFt <= 0 || !MINIMUM_SLOPES[pipeDiameter]) {
      this.clearResults()
      return
    }

    const pipeSpec = MINIMUM_SLOPES[pipeDiameter]
    const slopePct = customSlopePct !== null && customSlopePct > 0 ? customSlopePct : pipeSpec.slopePct
    const slopeInPerFt = (slopePct / 100) * 12
    const totalDropIn = slopeInPerFt * runLengthFt
    const totalDropFt = totalDropIn / 12
    const meetsMinimum = slopePct >= pipeSpec.slopePct

    // Manning's equation simplified for velocity
    const n = 0.013
    const radiusFt = (pipeDiameter / 2) / 12
    const hydraulicRadius = radiusFt / 2
    const slopeDecimal = slopePct / 100
    const velocity = (1.486 / n) * Math.pow(hydraulicRadius, 2/3) * Math.pow(slopeDecimal, 0.5)

    this.resultSlopePctTarget.textContent = `${slopePct.toFixed(2)}%`
    if (metric) {
      // Drop per meter: slopePct/100 * 100 cm = slopePct cm/m
      const dropPerMCm = slopePct
      const totalDropCm = totalDropIn * IN_TO_CM
      const totalDropM = totalDropFt * FT_TO_M
      const velocityMs = velocity * FT_TO_M
      this.resultSlopeInPerFtTarget.textContent = `${dropPerMCm.toFixed(2)} cm/m`
      this.resultTotalDropInTarget.textContent = `${totalDropCm.toFixed(1)} cm`
      this.resultTotalDropFtTarget.textContent = `${totalDropM.toFixed(3)} m`
      this.resultVelocityTarget.textContent = `${velocityMs.toFixed(2)} m/s`
    } else {
      this.resultSlopeInPerFtTarget.textContent = `${slopeInPerFt.toFixed(3)}"/ft`
      this.resultTotalDropInTarget.textContent = `${totalDropIn.toFixed(2)}"`
      this.resultTotalDropFtTarget.textContent = `${totalDropFt.toFixed(3)} ft`
      this.resultVelocityTarget.textContent = `${velocity.toFixed(2)} ft/s`
    }

    this.resultMeetsMinimumTarget.textContent = meetsMinimum ? "Yes" : "No"
    this.resultMeetsMinimumTarget.className = meetsMinimum
      ? "text-xl font-bold text-green-600 dark:text-green-400"
      : "text-xl font-bold text-red-600 dark:text-red-400"
    this.resultMinSlopeTarget.textContent = `${pipeSpec.slopePct}% (${pipeSpec.slopeInPerFt}"/ft)`
  }

  clearResults() {
    const metric = this.unitSystemTarget.value === "metric"
    this.resultSlopePctTarget.textContent = "0%"
    this.resultSlopeInPerFtTarget.textContent = metric ? "0 cm/m" : "0\"/ft"
    this.resultTotalDropInTarget.textContent = metric ? "0 cm" : "0\""
    this.resultTotalDropFtTarget.textContent = metric ? "0 m" : "0 ft"
    this.resultMeetsMinimumTarget.textContent = "--"
    this.resultMeetsMinimumTarget.className = "text-xl font-bold text-gray-400"
    this.resultMinSlopeTarget.textContent = "--"
    this.resultVelocityTarget.textContent = metric ? "0 m/s" : "0 ft/s"
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
