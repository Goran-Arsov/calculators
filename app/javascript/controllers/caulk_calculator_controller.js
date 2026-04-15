import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM } from "utils/units"

const TUBE_FL_OZ = { "10.1": 10.1, "20": 20, "28": 28 }
const CUIN_PER_FL_OZ = 1.80469

export default class extends Controller {
  static targets = [
    "length", "width", "depth", "tube", "waste",
    "unitSystem", "lengthLabel", "widthLabel", "depthLabel",
    "resultJoint", "resultTubeVolume", "resultLinearPerTube", "resultTubes"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const len = parseFloat(this.lengthTarget.value)
    if (Number.isFinite(len)) this.lengthTarget.value = (toMetric ? len * FT_TO_M : len / FT_TO_M).toFixed(2)
    const w = parseFloat(this.widthTarget.value)
    if (Number.isFinite(w)) this.widthTarget.value = (toMetric ? w * IN_TO_CM * 10 : w / (IN_TO_CM * 10)).toFixed(2) // in ↔ mm
    const d = parseFloat(this.depthTarget.value)
    if (Number.isFinite(d)) this.depthTarget.value = (toMetric ? d * IN_TO_CM * 10 : d / (IN_TO_CM * 10)).toFixed(2)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Total joint length (m)" : "Total joint length (ft)"
    this.widthLabelTarget.textContent = metric ? "Joint width (mm)" : "Joint width (inches)"
    this.depthLabelTarget.textContent = metric ? "Joint depth (mm)" : "Joint depth (inches)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const lenInput = parseFloat(this.lengthTarget.value) || 0
    const wInput = parseFloat(this.widthTarget.value) || 0
    const dInput = parseFloat(this.depthTarget.value) || 0
    const tubeSize = this.tubeTarget.value
    const waste = parseFloat(this.wasteTarget.value) || 0

    if (lenInput <= 0 || wInput <= 0 || dInput <= 0 || !TUBE_FL_OZ[tubeSize] || waste < 0) {
      this.clear()
      return
    }

    // Convert to imperial internally.
    const lengthFt = metric ? lenInput / FT_TO_M : lenInput
    const widthIn = metric ? wInput / (IN_TO_CM * 10) : wInput
    const depthIn = metric ? dInput / (IN_TO_CM * 10) : dInput

    const lengthIn = lengthFt * 12
    const jointVolumeCuin = lengthIn * widthIn * depthIn
    const tubeVolumeCuin = TUBE_FL_OZ[tubeSize] * CUIN_PER_FL_OZ
    const tubesExact = jointVolumeCuin / tubeVolumeCuin
    const tubesWithWaste = Math.ceil(Math.round(tubesExact * (1 + waste / 100) * 1e6) / 1e6)
    const linearFtPerTube = (tubeVolumeCuin / (widthIn * depthIn)) / 12

    const jointVolumeMl = jointVolumeCuin * 16.3871
    const tubeVolumeMl = tubeVolumeCuin * 16.3871
    const linearMPerTube = linearFtPerTube * FT_TO_M

    if (metric) {
      this.resultJointTarget.textContent = `${jointVolumeMl.toFixed(0)} mL (${jointVolumeCuin.toFixed(2)} cu in)`
      this.resultTubeVolumeTarget.textContent = `${tubeVolumeMl.toFixed(0)} mL (${TUBE_FL_OZ[tubeSize]} fl oz)`
      this.resultLinearPerTubeTarget.textContent = `${linearMPerTube.toFixed(1)} m / tube (${linearFtPerTube.toFixed(1)} ft / tube)`
    } else {
      this.resultJointTarget.textContent = `${jointVolumeCuin.toFixed(2)} cu in (${jointVolumeMl.toFixed(0)} mL)`
      this.resultTubeVolumeTarget.textContent = `${TUBE_FL_OZ[tubeSize]} fl oz (${tubeVolumeMl.toFixed(0)} mL)`
      this.resultLinearPerTubeTarget.textContent = `${linearFtPerTube.toFixed(1)} ft / tube (${linearMPerTube.toFixed(1)} m / tube)`
    }
    this.resultTubesTarget.textContent = tubesWithWaste
  }

  clear() {
    ["Joint","TubeVolume","LinearPerTube","Tubes"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Caulk estimate:",
      `Joint volume: ${this.resultJointTarget.textContent}`,
      `Tube volume: ${this.resultTubeVolumeTarget.textContent}`,
      `Yield: ${this.resultLinearPerTubeTarget.textContent}`,
      `Tubes needed: ${this.resultTubesTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
