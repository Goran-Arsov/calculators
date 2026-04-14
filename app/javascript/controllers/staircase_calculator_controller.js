import { Controller } from "@hotwired/stimulus"
import { IN_TO_CM } from "utils/units"

const IDEAL_RISER = 7.0
const MAX_RISER = 7.75
const MIN_TREAD = 10.0

export default class extends Controller {
  static targets = [
    "floorHeight", "runPreference",
    "unitSystem", "floorHeightLabel", "runPrefLabel",
    "resultRisers", "resultTreads", "resultRise", "resultRun",
    "resultTotalRun", "resultStringer", "resultAngle"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * IN_TO_CM : n / IN_TO_CM).toFixed(2)
    }
    convert(this.floorHeightTarget)
    convert(this.runPreferenceTarget)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.floorHeightLabelTarget.textContent = metric ? "Floor-to-Floor Height (cm)" : "Floor-to-Floor Height (inches)"
    this.runPrefLabelTarget.textContent = metric ? "Preferred Run per Step (cm, optional)" : "Preferred Run per Step (inches, optional)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const rawFloor = parseFloat(this.floorHeightTarget.value) || 0
    const rawRunPref = parseFloat(this.runPreferenceTarget.value) || 0

    if (rawFloor <= 0) {
      this.clearResults()
      return
    }

    // Canonical math in inches
    const floorHeight = metric ? rawFloor / IN_TO_CM : rawFloor
    const runPref = metric ? rawRunPref / IN_TO_CM : rawRunPref

    let numRisers = Math.round(floorHeight / IDEAL_RISER)
    numRisers = Math.max(numRisers, 1)
    let risePerStep = floorHeight / numRisers

    if (risePerStep > MAX_RISER) {
      numRisers += 1
      risePerStep = floorHeight / numRisers
    }

    const numTreads = numRisers - 1
    const runPerStep = runPref >= MIN_TREAD ? runPref : Math.max(17.5 - risePerStep, MIN_TREAD)
    const totalRun = numTreads * runPerStep
    const stringerLength = Math.sqrt(Math.pow(floorHeight, 2) + Math.pow(totalRun, 2))
    const angle = Math.atan2(floorHeight, totalRun) * (180 / Math.PI)

    this.resultRisersTarget.textContent = numRisers
    this.resultTreadsTarget.textContent = numTreads

    if (metric) {
      this.resultRiseTarget.textContent = `${(risePerStep * IN_TO_CM).toFixed(2)} cm`
      this.resultRunTarget.textContent = `${(runPerStep * IN_TO_CM).toFixed(2)} cm`
      this.resultTotalRunTarget.textContent = `${(totalRun * IN_TO_CM).toFixed(2)} cm`
      this.resultStringerTarget.textContent = `${(stringerLength * IN_TO_CM).toFixed(2)} cm`
    } else {
      this.resultRiseTarget.textContent = `${risePerStep.toFixed(3)}"`
      this.resultRunTarget.textContent = `${runPerStep.toFixed(3)}"`
      this.resultTotalRunTarget.textContent = `${totalRun.toFixed(2)}"`
      this.resultStringerTarget.textContent = `${stringerLength.toFixed(2)}"`
    }
    this.resultAngleTarget.textContent = `${angle.toFixed(2)}°`
  }

  clearResults() {
    const metric = this.unitSystemTarget.value === "metric"
    const unit = metric ? " cm" : "\""
    this.resultRisersTarget.textContent = "0"
    this.resultTreadsTarget.textContent = "0"
    this.resultRiseTarget.textContent = `0${unit}`
    this.resultRunTarget.textContent = `0${unit}`
    this.resultTotalRunTarget.textContent = `0${unit}`
    this.resultStringerTarget.textContent = `0${unit}`
    this.resultAngleTarget.textContent = "0°"
  }

  copy() {
    const text = `Staircase Estimate:\nRisers: ${this.resultRisersTarget.textContent}\nTreads: ${this.resultTreadsTarget.textContent}\nRise per Step: ${this.resultRiseTarget.textContent}\nRun per Step: ${this.resultRunTarget.textContent}\nTotal Run: ${this.resultTotalRunTarget.textContent}\nStringer Length: ${this.resultStringerTarget.textContent}\nAngle: ${this.resultAngleTarget.textContent}`
    navigator.clipboard.writeText(text)
  }

  fmt(n) {
    return Number(n).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }
}
