import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, IN_TO_CM, BTU_TO_W } from "utils/units"

const BTU_PER_SQIN = { wood: 30000, gas: 75000, oil: 40000, pellet: 50000 }
const MIN_HEIGHT_FT = { wood: 15, gas: 5, oil: 10, pellet: 10 }
const COMMERCIAL_SIZES_IN = [6, 7, 8, 10, 12, 14, 16, 18, 20, 24]
const SQIN_TO_SQCM = 6.4516

export default class extends Controller {
  static targets = [
    "btu", "appliance",
    "unitSystem", "btuLabel",
    "resultArea", "resultRound", "resultSquare", "resultCommercial", "resultHeight"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const btu = parseFloat(this.btuTarget.value)
    if (Number.isFinite(btu)) this.btuTarget.value = (toMetric ? btu * BTU_TO_W : btu / BTU_TO_W).toFixed(0)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.btuLabelTarget.textContent = metric ? "Appliance heat output (W)" : "Appliance heat output (BTU/hr)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const input = parseFloat(this.btuTarget.value) || 0
    const appliance = this.applianceTarget.value

    if (input <= 0 || !BTU_PER_SQIN[appliance]) {
      this.clear()
      return
    }

    // Convert to imperial internally.
    const btuHr = metric ? input / BTU_TO_W : input

    const areaSqin = btuHr / BTU_PER_SQIN[appliance]
    const diameterIn = 2 * Math.sqrt(areaSqin / Math.PI)
    const sideIn = Math.sqrt(areaSqin)
    const commercial = COMMERCIAL_SIZES_IN.find(d => d >= diameterIn) || 24
    const minHeightFt = MIN_HEIGHT_FT[appliance]

    const areaSqcm = areaSqin * SQIN_TO_SQCM
    const diameterCm = diameterIn * IN_TO_CM
    const sideCm = sideIn * IN_TO_CM
    const commercialCm = commercial * IN_TO_CM
    const minHeightM = minHeightFt * FT_TO_M

    if (metric) {
      this.resultAreaTarget.textContent = `${areaSqcm.toFixed(1)} cm² (${areaSqin.toFixed(2)} sq in)`
      this.resultRoundTarget.textContent = `${diameterCm.toFixed(1)} cm (${diameterIn.toFixed(2)} in)`
      this.resultSquareTarget.textContent = `${sideCm.toFixed(1)} cm × ${sideCm.toFixed(1)} cm (${sideIn.toFixed(2)}" × ${sideIn.toFixed(2)}")`
      this.resultCommercialTarget.textContent = `${commercialCm.toFixed(0)} cm (${commercial}" round)`
      this.resultHeightTarget.textContent = `${minHeightM.toFixed(1)} m (${minHeightFt} ft)`
    } else {
      this.resultAreaTarget.textContent = `${areaSqin.toFixed(2)} sq in (${areaSqcm.toFixed(1)} cm²)`
      this.resultRoundTarget.textContent = `${diameterIn.toFixed(2)}" (${diameterCm.toFixed(1)} cm)`
      this.resultSquareTarget.textContent = `${sideIn.toFixed(2)}" × ${sideIn.toFixed(2)}" (${sideCm.toFixed(1)} × ${sideCm.toFixed(1)} cm)`
      this.resultCommercialTarget.textContent = `${commercial}" round (${commercialCm.toFixed(0)} cm)`
      this.resultHeightTarget.textContent = `${minHeightFt} ft (${minHeightM.toFixed(1)} m)`
    }
  }

  clear() {
    ["Area","Round","Square","Commercial","Height"].forEach(k => {
      this[`result${k}Target`].textContent = "—"
    })
  }

  copy() {
    const text = [
      "Chimney flue size:",
      `Required area: ${this.resultAreaTarget.textContent}`,
      `Round diameter: ${this.resultRoundTarget.textContent}`,
      `Square liner: ${this.resultSquareTarget.textContent}`,
      `Commercial size: ${this.resultCommercialTarget.textContent}`,
      `Min height above roof: ${this.resultHeightTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
