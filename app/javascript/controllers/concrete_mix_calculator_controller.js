import { Controller } from "@hotwired/stimulus"

const MIX_RATIOS = {
  2500: { cement: 1.0, sand: 2.5, gravel: 3.5, wcr: 0.65, label: "General purpose" },
  3000: { cement: 1.0, sand: 2.0, gravel: 3.0, wcr: 0.55, label: "Standard residential" },
  3500: { cement: 1.0, sand: 1.75, gravel: 2.75, wcr: 0.50, label: "Driveways & sidewalks" },
  4000: { cement: 1.0, sand: 1.5, gravel: 2.5, wcr: 0.45, label: "Structural / commercial" },
  4500: { cement: 1.0, sand: 1.25, gravel: 2.25, wcr: 0.40, label: "Heavy-duty structural" },
  5000: { cement: 1.0, sand: 1.0, gravel: 2.0, wcr: 0.35, label: "High-strength" }
}

const CEMENT_WT = 94.0
const SAND_WT = 100.0
const GRAVEL_WT = 105.0
const CUFT_PER_YARD = 27.0

export default class extends Controller {
  static targets = ["targetPsi", "volume",
    "resultLabel", "resultRatio", "resultCementLbs", "resultSandLbs",
    "resultGravelLbs", "resultWaterGal", "resultCementBags", "resultWcr"]

  calculate() {
    const psi = parseInt(this.targetPsiTarget.value) || 0
    const volume = parseFloat(this.volumeTarget.value) || 0

    if (volume <= 0 || !MIX_RATIOS[psi]) {
      this.clearResults()
      return
    }

    const mix = MIX_RATIOS[psi]
    const totalParts = mix.cement + mix.sand + mix.gravel
    const volumeCuft = volume * CUFT_PER_YARD

    const cementCuft = (mix.cement / totalParts) * volumeCuft
    const sandCuft = (mix.sand / totalParts) * volumeCuft
    const gravelCuft = (mix.gravel / totalParts) * volumeCuft
    const waterCuft = cementCuft * mix.wcr

    const cementLbs = Math.round(cementCuft * CEMENT_WT)
    const sandLbs = Math.round(sandCuft * SAND_WT)
    const gravelLbs = Math.round(gravelCuft * GRAVEL_WT)
    const waterGal = (waterCuft * 7.48).toFixed(1)
    const cementBags = Math.ceil(cementLbs / 94)

    this.resultLabelTarget.textContent = mix.label
    this.resultRatioTarget.textContent = `${mix.cement} : ${mix.sand} : ${mix.gravel}`
    this.resultCementLbsTarget.textContent = `${cementLbs.toLocaleString()} lbs`
    this.resultSandLbsTarget.textContent = `${sandLbs.toLocaleString()} lbs`
    this.resultGravelLbsTarget.textContent = `${gravelLbs.toLocaleString()} lbs`
    this.resultWaterGalTarget.textContent = `${waterGal} gal`
    this.resultCementBagsTarget.textContent = cementBags
    this.resultWcrTarget.textContent = mix.wcr.toFixed(2)
  }

  clearResults() {
    this.resultLabelTarget.textContent = "--"
    this.resultRatioTarget.textContent = "--"
    this.resultCementLbsTarget.textContent = "0 lbs"
    this.resultSandLbsTarget.textContent = "0 lbs"
    this.resultGravelLbsTarget.textContent = "0 lbs"
    this.resultWaterGalTarget.textContent = "0 gal"
    this.resultCementBagsTarget.textContent = "0"
    this.resultWcrTarget.textContent = "--"
  }

  copy() {
    const ratio = this.resultRatioTarget.textContent
    const cement = this.resultCementLbsTarget.textContent
    const sand = this.resultSandLbsTarget.textContent
    const gravel = this.resultGravelLbsTarget.textContent
    const water = this.resultWaterGalTarget.textContent
    const bags = this.resultCementBagsTarget.textContent
    const text = `Concrete Mix Estimate:\nRatio (C:S:G): ${ratio}\nCement: ${cement}\nSand: ${sand}\nGravel: ${gravel}\nWater: ${water}\nCement Bags (94 lb): ${bags}`
    navigator.clipboard.writeText(text)
  }
}
