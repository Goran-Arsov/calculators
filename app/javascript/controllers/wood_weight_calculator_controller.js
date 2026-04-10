import { Controller } from "@hotwired/stimulus"

const SPECIES_DENSITY = {
  red_oak:            { name: "Red Oak",            density_lb_ft3: 44.0 },
  white_oak:          { name: "White Oak",          density_lb_ft3: 47.0 },
  hard_maple:         { name: "Hard Maple",         density_lb_ft3: 44.0 },
  soft_maple:         { name: "Soft Maple (Red)",   density_lb_ft3: 38.0 },
  black_walnut:       { name: "Black Walnut",       density_lb_ft3: 38.0 },
  cherry:             { name: "Black Cherry",       density_lb_ft3: 35.0 },
  white_ash:          { name: "White Ash",          density_lb_ft3: 41.0 },
  mahogany:           { name: "Mahogany (Genuine)", density_lb_ft3: 31.0 },
  poplar:             { name: "Yellow Poplar",      density_lb_ft3: 29.0 },
  eastern_white_pine: { name: "Eastern White Pine", density_lb_ft3: 25.0 },
  douglas_fir:        { name: "Douglas Fir",        density_lb_ft3: 32.0 },
  yellow_birch:       { name: "Yellow Birch",       density_lb_ft3: 43.0 },
  teak:               { name: "Teak",               density_lb_ft3: 41.0 },
  hickory:            { name: "Hickory",            density_lb_ft3: 51.0 },
  beech:              { name: "American Beech",     density_lb_ft3: 45.0 },
  red_cedar:          { name: "Western Red Cedar",  density_lb_ft3: 23.0 },
  spanish_cedar:      { name: "Spanish Cedar",      density_lb_ft3: 30.0 },
  sapele:             { name: "Sapele",             density_lb_ft3: 42.0 },
  ipe:                { name: "Ipe",                density_lb_ft3: 69.0 },
  purpleheart:        { name: "Purpleheart",        density_lb_ft3: 56.0 }
}

const LB_TO_KG = 0.453592
const FT3_TO_M3 = 0.0283168
const LB_FT3_TO_KG_M3 = 16.0185

export default class extends Controller {
  static targets = [
    "species", "thickness", "width", "length", "quantity",
    "resultDensity", "resultWeightEach",
    "resultTotalWeightLb", "resultTotalWeightKg",
    "resultVolumeFt3", "resultVolumeM3"
  ]

  calculate() {
    const speciesKey = this.speciesTarget.value
    const speciesData = SPECIES_DENSITY[speciesKey]
    if (!speciesData) {
      this.clearResults()
      return
    }

    const thickness = parseFloat(this.thicknessTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const length = parseFloat(this.lengthTarget.value) || 0
    const quantity = parseInt(this.quantityTarget.value) || 1

    if (thickness <= 0 || width <= 0 || length <= 0 || quantity < 1) {
      this.clearResults()
      return
    }

    const density = speciesData.density_lb_ft3
    const volumePer = (thickness * width * (length * 12)) / 1728
    const weightPer = volumePer * density

    const totalVolumeFt3 = volumePer * quantity
    const totalVolumeM3 = totalVolumeFt3 * FT3_TO_M3
    const totalWeightLb = weightPer * quantity
    const totalWeightKg = totalWeightLb * LB_TO_KG
    const densityKgM3 = density * LB_FT3_TO_KG_M3

    this.resultDensityTarget.textContent = `${density.toFixed(2)} lb/ft³ (${densityKgM3.toFixed(2)} kg/m³)`
    this.resultWeightEachTarget.textContent = `${weightPer.toFixed(2)} lb`
    this.resultTotalWeightLbTarget.textContent = `${totalWeightLb.toFixed(2)} lb`
    this.resultTotalWeightKgTarget.textContent = `${totalWeightKg.toFixed(2)} kg`
    this.resultVolumeFt3Target.textContent = `${totalVolumeFt3.toFixed(4)} ft³`
    this.resultVolumeM3Target.textContent = `${totalVolumeM3.toFixed(4)} m³`
  }

  clearResults() {
    this.resultDensityTarget.textContent = "0.00 lb/ft³"
    this.resultWeightEachTarget.textContent = "0.00 lb"
    this.resultTotalWeightLbTarget.textContent = "0.00 lb"
    this.resultTotalWeightKgTarget.textContent = "0.00 kg"
    this.resultVolumeFt3Target.textContent = "0.0000 ft³"
    this.resultVolumeM3Target.textContent = "0.0000 m³"
  }

  copy() {
    const text = `Wood Weight Estimate:\nDensity: ${this.resultDensityTarget.textContent}\nWeight per Piece: ${this.resultWeightEachTarget.textContent}\nTotal Weight: ${this.resultTotalWeightLbTarget.textContent} (${this.resultTotalWeightKgTarget.textContent})\nTotal Volume: ${this.resultVolumeFt3Target.textContent} (${this.resultVolumeM3Target.textContent})`
    navigator.clipboard.writeText(text)
  }
}
