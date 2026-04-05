import { Controller } from "@hotwired/stimulus"

const IDEAL_RISER = 7.0
const MAX_RISER = 7.75
const MIN_TREAD = 10.0

export default class extends Controller {
  static targets = [
    "floorHeight", "runPreference",
    "resultRisers", "resultTreads", "resultRise", "resultRun",
    "resultTotalRun", "resultStringer", "resultAngle"
  ]

  calculate() {
    const floorHeight = parseFloat(this.floorHeightTarget.value) || 0
    const runPref = parseFloat(this.runPreferenceTarget.value) || 0

    if (floorHeight <= 0) {
      this.clearResults()
      return
    }

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
    this.resultRiseTarget.textContent = `${risePerStep.toFixed(3)}"`
    this.resultRunTarget.textContent = `${runPerStep.toFixed(3)}"`
    this.resultTotalRunTarget.textContent = `${totalRun.toFixed(2)}"`
    this.resultStringerTarget.textContent = `${stringerLength.toFixed(2)}"`
    this.resultAngleTarget.textContent = `${angle.toFixed(2)}°`
  }

  clearResults() {
    this.resultRisersTarget.textContent = "0"
    this.resultTreadsTarget.textContent = "0"
    this.resultRiseTarget.textContent = `0"`
    this.resultRunTarget.textContent = `0"`
    this.resultTotalRunTarget.textContent = `0"`
    this.resultStringerTarget.textContent = `0"`
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
