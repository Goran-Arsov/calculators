import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM } from "utils/units"

export default class extends Controller {
  static targets = [
    "run", "pitch", "overhang",
    "unitSystem", "runLabel", "overhangLabel",
    "riseHeading", "rafterHeading", "totalHeading",
    "resultPitch", "resultRise", "resultRafter", "resultTotal", "resultAngle", "resultGrade"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const run = parseFloat(this.runTarget.value)
    if (Number.isFinite(run)) this.runTarget.value = (toMetric ? run * FT_TO_M : run / FT_TO_M).toFixed(2)
    const overhang = parseFloat(this.overhangTarget.value)
    if (Number.isFinite(overhang)) this.overhangTarget.value = (toMetric ? overhang * IN_TO_CM : overhang / IN_TO_CM).toFixed(1)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.runLabelTarget.textContent = metric ? "Run (m)" : "Run (ft, half of building width)"
    this.overhangLabelTarget.textContent = metric ? "Overhang (cm)" : "Overhang (inches)"
    this.riseHeadingTarget.textContent = metric ? "Rise (m)" : "Rise (ft)"
    this.rafterHeadingTarget.textContent = metric ? "Rafter length (m)" : "Rafter length (ft)"
    this.totalHeadingTarget.textContent = metric ? "Total with overhang (m)" : "Total with overhang (ft)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const runInput = parseFloat(this.runTarget.value) || 0
    const pitch = parseFloat(this.pitchTarget.value) || 0
    const overhangInput = parseFloat(this.overhangTarget.value) || 0

    if (runInput <= 0 || pitch <= 0 || overhangInput < 0) {
      this.clear()
      return
    }

    // Work in imperial internally.
    const runFt = metric ? runInput / FT_TO_M : runInput
    const overhangIn = metric ? overhangInput / IN_TO_CM : overhangInput

    const riseFt = runFt * (pitch / 12)
    const rafterFt = Math.sqrt(runFt * runFt + riseFt * riseFt)
    const overhangFt = overhangIn / 12
    const totalFt = rafterFt + overhangFt
    const angleDeg = Math.atan(pitch / 12) * 180 / Math.PI
    const gradePct = (pitch / 12) * 100

    if (metric) {
      this.resultRiseTarget.textContent = `${(riseFt * FT_TO_M).toFixed(2)} m (${riseFt.toFixed(2)} ft)`
      this.resultRafterTarget.textContent = `${(rafterFt * FT_TO_M).toFixed(2)} m (${rafterFt.toFixed(2)} ft)`
      this.resultTotalTarget.textContent = `${(totalFt * FT_TO_M).toFixed(2)} m (${totalFt.toFixed(2)} ft)`
    } else {
      this.resultRiseTarget.textContent = `${riseFt.toFixed(2)} ft (${(riseFt * FT_TO_M).toFixed(2)} m)`
      this.resultRafterTarget.textContent = `${rafterFt.toFixed(2)} ft (${(rafterFt * FT_TO_M).toFixed(2)} m)`
      this.resultTotalTarget.textContent = `${totalFt.toFixed(2)} ft (${(totalFt * FT_TO_M).toFixed(2)} m)`
    }
    this.resultPitchTarget.textContent = `${Math.round(pitch)}/12`
    this.resultAngleTarget.textContent = `${angleDeg.toFixed(2)}°`
    this.resultGradeTarget.textContent = `${gradePct.toFixed(1)}%`
  }

  clear() {
    this.resultPitchTarget.textContent = "—"
    this.resultRiseTarget.textContent = "—"
    this.resultRafterTarget.textContent = "—"
    this.resultTotalTarget.textContent = "—"
    this.resultAngleTarget.textContent = "—"
    this.resultGradeTarget.textContent = "—"
  }

  copy() {
    const text = [
      "Rafter Length Estimate:",
      `Pitch: ${this.resultPitchTarget.textContent}`,
      `${this.riseHeadingTarget.textContent}: ${this.resultRiseTarget.textContent}`,
      `${this.rafterHeadingTarget.textContent}: ${this.resultRafterTarget.textContent}`,
      `${this.totalHeadingTarget.textContent}: ${this.resultTotalTarget.textContent}`,
      `Angle: ${this.resultAngleTarget.textContent}`,
      `Grade: ${this.resultGradeTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
