import { Controller } from "@hotwired/stimulus"
import { GAL_TO_L } from "utils/units"

export default class extends Controller {
  static targets = [
    "volume", "og", "beerType", "yeastType", "age",
    "resultCells", "resultPlato", "resultPitchRate",
    "resultDryGroup", "resultLiquidGroup",
    "resultDryPacks", "resultDryGrams", "resultViability",
    "resultLiquidPacks", "resultStarter",
    "unitSystem", "volumeLabel"
  ]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const n = parseFloat(this.volumeTarget.value)
    if (Number.isFinite(n)) {
      this.volumeTarget.value = (toMetric ? n * GAL_TO_L : n / GAL_TO_L).toFixed(2)
    }
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.volumeLabelTarget.textContent = metric ? "Batch Volume (L)" : "Batch Volume (gal)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const volumeInput = parseFloat(this.volumeTarget.value) || 0
    const og = parseFloat(this.ogTarget.value) || 0
    const beerType = this.beerTypeTarget.value
    const yeastType = this.yeastTypeTarget.value
    const age = parseInt(this.ageTarget.value) || 0

    if (volumeInput <= 0 || og <= 1.0 || og > 1.15) {
      this.clearResults()
      return
    }

    const volumeL = metric ? volumeInput : volumeInput * GAL_TO_L
    const volumeMl = volumeL * 1000.0
    const plato = (og - 1.0) * 1000.0 / 4.0
    const lager = beerType.includes("lager")
    const highGrav = og >= 1.06
    let pitchRate = 0.75
    if (lager && highGrav) pitchRate = 2.0
    else if (lager) pitchRate = 1.5
    else if (highGrav) pitchRate = 1.0

    const cellsNeeded = (pitchRate * volumeMl * plato) / 1000.0
    const viability = Math.max(yeastType === "dry" ? 1.0 - 0.007 * age : Math.max(1.0 - 0.007 * age, 0.0), yeastType === "dry" ? 0.5 : 0.0)

    this.resultPlatoTarget.textContent = plato.toFixed(2) + " °P"
    this.resultPitchRateTarget.textContent = pitchRate.toFixed(2) + " M/mL/°P"
    this.resultCellsTarget.textContent = cellsNeeded.toFixed(0) + " B"
    this.resultViabilityTarget.textContent = (viability * 100).toFixed(0) + "%"

    if (yeastType === "dry") {
      this.resultDryGroupTarget.classList.remove("hidden")
      this.resultLiquidGroupTarget.classList.add("hidden")
      const viableCellsPer11g = 20.0 * 11 * viability
      const packs = Math.ceil(cellsNeeded / viableCellsPer11g)
      this.resultDryPacksTarget.textContent = packs
      this.resultDryGramsTarget.textContent = (packs * 11).toFixed(0) + " g"
    } else {
      this.resultLiquidGroupTarget.classList.remove("hidden")
      this.resultDryGroupTarget.classList.add("hidden")
      const cellsPerPack = 100.0 * viability
      const packsNoStarter = Math.ceil(cellsNeeded / cellsPerPack)
      let starter = cellsNeeded / (cellsPerPack * 2.0)
      if (starter < 0.5 && cellsNeeded > cellsPerPack) starter = 0.5
      this.resultLiquidPacksTarget.textContent = packsNoStarter
      this.resultStarterTarget.textContent = starter.toFixed(2) + " L"
    }
  }

  clearResults() {
    this.resultPlatoTarget.textContent = "—"
    this.resultPitchRateTarget.textContent = "—"
    this.resultCellsTarget.textContent = "—"
    this.resultViabilityTarget.textContent = "—"
    if (this.hasResultDryPacksTarget) this.resultDryPacksTarget.textContent = "—"
    if (this.hasResultDryGramsTarget) this.resultDryGramsTarget.textContent = "—"
    if (this.hasResultLiquidPacksTarget) this.resultLiquidPacksTarget.textContent = "—"
    if (this.hasResultStarterTarget) this.resultStarterTarget.textContent = "—"
  }

  copy() {
    const lines = [
      "Yeast Pitch Rate:",
      `Plato: ${this.resultPlatoTarget.textContent}`,
      `Cells Needed: ${this.resultCellsTarget.textContent}`,
      `Viability: ${this.resultViabilityTarget.textContent}`
    ]
    if (this.yeastTypeTarget.value === "dry") {
      lines.push(`Dry Packs (11g): ${this.resultDryPacksTarget.textContent}`)
      lines.push(`Total Dry Yeast: ${this.resultDryGramsTarget.textContent}`)
    } else {
      lines.push(`Liquid Packs (no starter): ${this.resultLiquidPacksTarget.textContent}`)
      lines.push(`Starter (1 pack): ${this.resultStarterTarget.textContent}`)
    }
    navigator.clipboard.writeText(lines.join("\n"))
  }
}
