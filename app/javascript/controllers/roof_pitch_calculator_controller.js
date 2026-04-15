import { Controller } from "@hotwired/stimulus"
import { IN_TO_CM } from "utils/units"

export default class extends Controller {
  static targets = [
    "mode", "rise", "run", "angle", "grade",
    "unitSystem", "riseLabel", "runLabel",
    "riseRunGroup", "angleGroup", "gradeGroup",
    "resultPitch", "resultAngle", "resultGrade", "resultCategory"
  ]

  connect() {
    this.updateMode()
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * IN_TO_CM : n / IN_TO_CM).toFixed(2)
    }
    convert(this.riseTarget)
    convert(this.runTarget)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.riseLabelTarget.textContent = metric ? "Rise (cm)" : "Rise (inches)"
    this.runLabelTarget.textContent = metric ? "Run (cm)" : "Run (inches)"
  }

  updateMode() {
    const mode = this.modeTarget.value
    this.riseRunGroupTarget.classList.toggle("hidden", mode !== "rise_run")
    this.angleGroupTarget.classList.toggle("hidden", mode !== "angle")
    this.gradeGroupTarget.classList.toggle("hidden", mode !== "grade")
    this.calculate()
  }

  calculate() {
    const mode = this.modeTarget.value
    let ratio

    if (mode === "rise_run") {
      const rise = parseFloat(this.riseTarget.value) || 0
      const run = parseFloat(this.runTarget.value) || 0
      if (rise <= 0 || run <= 0) { this.clear(); return }
      // Ratio is dimensionless, so unit system doesn't matter here.
      ratio = rise / run
    } else if (mode === "angle") {
      const angle = parseFloat(this.angleTarget.value) || 0
      if (angle <= 0 || angle >= 90) { this.clear(); return }
      ratio = Math.tan(angle * Math.PI / 180)
    } else if (mode === "grade") {
      const grade = parseFloat(this.gradeTarget.value) || 0
      if (grade <= 0) { this.clear(); return }
      ratio = grade / 100
    } else {
      this.clear(); return
    }

    const pitch = ratio * 12
    const angleDeg = Math.atan(ratio) * 180 / Math.PI
    const gradePct = ratio * 100

    this.resultPitchTarget.textContent = `${pitch.toFixed(2)}/12`
    this.resultAngleTarget.textContent = `${angleDeg.toFixed(2)}°`
    this.resultGradeTarget.textContent = `${gradePct.toFixed(2)}%`
    this.resultCategoryTarget.textContent = this.categoryFor(pitch)
  }

  categoryFor(pitch) {
    if (pitch < 2) return "Flat (membrane required)"
    if (pitch < 4) return "Low slope"
    if (pitch < 9) return "Conventional slope"
    if (pitch < 12) return "Steep slope"
    return "Very steep slope"
  }

  clear() {
    this.resultPitchTarget.textContent = "—"
    this.resultAngleTarget.textContent = "—"
    this.resultGradeTarget.textContent = "—"
    this.resultCategoryTarget.textContent = "—"
  }

  copy() {
    const text = [
      "Roof Pitch:",
      `Pitch: ${this.resultPitchTarget.textContent}`,
      `Angle: ${this.resultAngleTarget.textContent}`,
      `Grade: ${this.resultGradeTarget.textContent}`,
      `Category: ${this.resultCategoryTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
