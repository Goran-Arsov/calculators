import { Controller } from "@hotwired/stimulus"
import { CUFT_TO_CUM } from "utils/units"

const CFM_TO_M3H = 1.69901

export default class extends Controller {
  static targets = [
    "mode", "cfm", "volume", "targetAch",
    "unitSystem", "cfmLabel", "volumeLabel",
    "cfmGroup", "volumeGroup", "achGroup",
    "resultAch", "resultCfm", "resultVolume"
  ]

  connect() {
    this.updateMode()
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const cfm = parseFloat(this.cfmTarget.value)
    if (Number.isFinite(cfm)) this.cfmTarget.value = (toMetric ? cfm * CFM_TO_M3H : cfm / CFM_TO_M3H).toFixed(1)
    const vol = parseFloat(this.volumeTarget.value)
    if (Number.isFinite(vol)) this.volumeTarget.value = (toMetric ? vol * CUFT_TO_CUM : vol / CUFT_TO_CUM).toFixed(1)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.cfmLabelTarget.textContent = metric ? "Airflow (m³/h)" : "Airflow (CFM)"
    this.volumeLabelTarget.textContent = metric ? "Room volume (m³)" : "Room volume (cu ft)"
  }

  updateMode() {
    const mode = this.modeTarget.value
    this.cfmGroupTarget.classList.toggle("hidden", mode === "find_cfm")
    this.volumeGroupTarget.classList.toggle("hidden", mode === "find_volume")
    this.achGroupTarget.classList.toggle("hidden", mode === "find_ach")
    this.calculate()
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const mode = this.modeTarget.value
    const cfmInput = parseFloat(this.cfmTarget.value) || 0
    const volInput = parseFloat(this.volumeTarget.value) || 0
    const targetAch = parseFloat(this.targetAchTarget.value) || 0

    const cfmImp = metric ? cfmInput / CFM_TO_M3H : cfmInput
    const volImp = metric ? volInput / CUFT_TO_CUM : volInput

    this.clear()

    if (mode === "find_ach") {
      if (cfmImp <= 0 || volImp <= 0) return
      const ach = cfmImp * 60 / volImp
      this.resultAchTarget.textContent = `${ach.toFixed(2)} ACH`
    } else if (mode === "find_cfm") {
      if (targetAch <= 0 || volImp <= 0) return
      const cfm = targetAch * volImp / 60
      const m3h = cfm * CFM_TO_M3H
      this.resultCfmTarget.textContent = metric
        ? `${m3h.toFixed(0)} m³/h (${cfm.toFixed(0)} CFM)`
        : `${cfm.toFixed(0)} CFM (${m3h.toFixed(0)} m³/h)`
    } else if (mode === "find_volume") {
      if (cfmImp <= 0 || targetAch <= 0) return
      const volCuft = cfmImp * 60 / targetAch
      const volM3 = volCuft * CUFT_TO_CUM
      this.resultVolumeTarget.textContent = metric
        ? `${volM3.toFixed(1)} m³ (${volCuft.toFixed(0)} cu ft)`
        : `${volCuft.toFixed(0)} cu ft (${volM3.toFixed(1)} m³)`
    }
  }

  clear() {
    ["Ach","Cfm","Volume"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Air change rate:",
      `ACH: ${this.resultAchTarget.textContent}`,
      `CFM: ${this.resultCfmTarget.textContent}`,
      `Volume: ${this.resultVolumeTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
