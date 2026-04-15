import { Controller } from "@hotwired/stimulus"
import { LB_TO_KG, IN_TO_CM, CUFT_TO_CUM, CUYD_TO_CUM, SQFT_TO_SQM } from "utils/units"

const PSF_TO_KPA = 0.04788 // lb/ft² → kPa

export default class extends Controller {
  static targets = [
    "load", "bearing", "safetyFactor", "depth",
    "unitSystem", "loadLabel", "bearingLabel", "depthLabel",
    "resultArea", "resultSquare", "resultRound", "resultDepth", "resultVolume", "resultActualBearing"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const load = parseFloat(this.loadTarget.value)
    if (Number.isFinite(load)) this.loadTarget.value = (toMetric ? load * LB_TO_KG : load / LB_TO_KG).toFixed(0)
    const b = parseFloat(this.bearingTarget.value)
    if (Number.isFinite(b)) this.bearingTarget.value = (toMetric ? b * PSF_TO_KPA : b / PSF_TO_KPA).toFixed(0)
    const d = parseFloat(this.depthTarget.value)
    if (Number.isFinite(d)) this.depthTarget.value = (toMetric ? d * IN_TO_CM : d / IN_TO_CM).toFixed(1)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.loadLabelTarget.textContent = metric ? "Column load (kg)" : "Column load (lb)"
    this.bearingLabelTarget.textContent = metric ? "Soil bearing (kPa)" : "Soil bearing (psf)"
    this.depthLabelTarget.textContent = metric ? "Footing depth (cm)" : "Footing depth (inches)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const loadInput = parseFloat(this.loadTarget.value) || 0
    const bearingInput = parseFloat(this.bearingTarget.value) || 0
    const sf = parseFloat(this.safetyFactorTarget.value) || 1.0
    const depthInput = parseFloat(this.depthTarget.value) || 0

    if (loadInput <= 0 || bearingInput <= 0 || sf < 1.0 || depthInput <= 0) {
      this.clear()
      return
    }

    // Convert to imperial internally.
    const loadLbs = metric ? loadInput / LB_TO_KG : loadInput
    const bearingPsf = metric ? bearingInput / PSF_TO_KPA : bearingInput
    const depthIn = metric ? depthInput / IN_TO_CM : depthInput

    const requiredAreaSqft = (loadLbs * sf) / bearingPsf
    const sideInRaw = Math.sqrt(requiredAreaSqft) * 12
    const sideIn = Math.max(Math.ceil(sideInRaw / 2) * 2, 8)
    const diameterIn = Math.max(2 * Math.sqrt(requiredAreaSqft * 144 / Math.PI), 8)

    const concreteCuft = Math.pow(sideIn / 12, 2) * (depthIn / 12)
    const concreteCuyd = concreteCuft / 27
    const actualBearingPsf = loadLbs / Math.pow(sideIn / 12, 2)

    const areaM2 = requiredAreaSqft * SQFT_TO_SQM
    const sideCm = sideIn * IN_TO_CM
    const diamCm = diameterIn * IN_TO_CM
    const depthCm = depthIn * IN_TO_CM
    const cum = concreteCuft * CUFT_TO_CUM
    const actualBearingKpa = actualBearingPsf * PSF_TO_KPA

    if (metric) {
      this.resultAreaTarget.textContent = `${areaM2.toFixed(3)} m² (${requiredAreaSqft.toFixed(2)} sq ft)`
      this.resultSquareTarget.textContent = `${sideCm.toFixed(0)} cm × ${sideCm.toFixed(0)} cm (${sideIn.toFixed(0)}" × ${sideIn.toFixed(0)}")`
      this.resultRoundTarget.textContent = `${diamCm.toFixed(0)} cm dia (${diameterIn.toFixed(1)}" dia)`
      this.resultDepthTarget.textContent = `${depthCm.toFixed(0)} cm (${depthIn.toFixed(1)}")`
      this.resultVolumeTarget.textContent = `${cum.toFixed(3)} m³ (${concreteCuft.toFixed(2)} cu ft)`
      this.resultActualBearingTarget.textContent = `${actualBearingKpa.toFixed(0)} kPa (${actualBearingPsf.toFixed(0)} psf)`
    } else {
      this.resultAreaTarget.textContent = `${requiredAreaSqft.toFixed(2)} sq ft (${areaM2.toFixed(3)} m²)`
      this.resultSquareTarget.textContent = `${sideIn.toFixed(0)}" × ${sideIn.toFixed(0)}" (${sideCm.toFixed(0)} × ${sideCm.toFixed(0)} cm)`
      this.resultRoundTarget.textContent = `${diameterIn.toFixed(1)}" dia (${diamCm.toFixed(0)} cm dia)`
      this.resultDepthTarget.textContent = `${depthIn.toFixed(1)}" (${depthCm.toFixed(0)} cm)`
      this.resultVolumeTarget.textContent = `${concreteCuft.toFixed(2)} cu ft (${cum.toFixed(3)} m³)`
      this.resultActualBearingTarget.textContent = `${actualBearingPsf.toFixed(0)} psf (${actualBearingKpa.toFixed(0)} kPa)`
    }
  }

  clear() {
    ["Area","Square","Round","Depth","Volume","ActualBearing"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Spread footing:",
      `Required area: ${this.resultAreaTarget.textContent}`,
      `Square footing: ${this.resultSquareTarget.textContent}`,
      `Round footing: ${this.resultRoundTarget.textContent}`,
      `Depth: ${this.resultDepthTarget.textContent}`,
      `Concrete: ${this.resultVolumeTarget.textContent}`,
      `Actual bearing: ${this.resultActualBearingTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
