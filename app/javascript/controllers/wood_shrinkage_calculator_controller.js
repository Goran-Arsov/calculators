import { Controller } from "@hotwired/stimulus"

const SPECIES = {
  red_oak:            { name: "Red Oak",            tangential: 8.6,  radial: 4.0 },
  white_oak:          { name: "White Oak",          tangential: 10.5, radial: 5.6 },
  hard_maple:         { name: "Hard Maple",         tangential: 9.9,  radial: 4.8 },
  soft_maple:         { name: "Soft Maple (Red)",   tangential: 8.2,  radial: 4.0 },
  black_walnut:       { name: "Black Walnut",       tangential: 7.8,  radial: 5.5 },
  cherry:             { name: "Black Cherry",       tangential: 7.1,  radial: 3.7 },
  white_ash:          { name: "White Ash",          tangential: 7.8,  radial: 4.9 },
  mahogany:           { name: "Mahogany (Genuine)", tangential: 4.1,  radial: 3.0 },
  poplar:             { name: "Yellow Poplar",      tangential: 8.2,  radial: 4.6 },
  eastern_white_pine: { name: "Eastern White Pine", tangential: 6.1,  radial: 2.1 },
  douglas_fir:        { name: "Douglas Fir",        tangential: 7.6,  radial: 4.8 },
  yellow_birch:       { name: "Yellow Birch",       tangential: 9.5,  radial: 7.3 },
  teak:               { name: "Teak",               tangential: 4.0,  radial: 2.5 },
  hickory:            { name: "Hickory",            tangential: 11.5, radial: 7.0 },
  beech:              { name: "American Beech",     tangential: 11.9, radial: 5.5 }
}

const FSP = 30.0

export default class extends Controller {
  static targets = [
    "species", "direction", "initialDimension", "initialMc", "finalMc",
    "resultShrinkagePct", "resultChange", "resultFinalDim"
  ]

  calculate() {
    const speciesKey = this.speciesTarget.value
    const speciesData = SPECIES[speciesKey]
    if (!speciesData) {
      this.clearResults()
      return
    }

    const direction = this.selectedDirection()
    if (direction !== "tangential" && direction !== "radial") {
      this.clearResults()
      return
    }

    const initialDimension = parseFloat(this.initialDimensionTarget.value) || 0
    const initialMc = parseFloat(this.initialMcTarget.value)
    const finalMc = parseFloat(this.finalMcTarget.value)

    if (initialDimension <= 0 || isNaN(initialMc) || isNaN(finalMc)) {
      this.clearResults()
      return
    }

    if (initialMc < 0 || initialMc > 100 || finalMc < 0 || finalMc > 100) {
      this.clearResults()
      return
    }

    if (finalMc > initialMc) {
      this.clearResults()
      return
    }

    const S = speciesData[direction]
    const effectiveInitial = Math.min(initialMc, FSP)
    const effectiveFinal = Math.min(finalMc, FSP)
    const mcChange = effectiveInitial - effectiveFinal

    const shrinkageFraction = (S / 100) * (mcChange / FSP)
    const dimensionChange = initialDimension * shrinkageFraction
    const finalDimension = initialDimension - dimensionChange

    this.resultShrinkagePctTarget.textContent = `${(shrinkageFraction * 100).toFixed(3)}%`
    this.resultChangeTarget.textContent = dimensionChange.toFixed(4)
    this.resultFinalDimTarget.textContent = finalDimension.toFixed(4)
  }

  selectedDirection() {
    if (!this.hasDirectionTarget) return "tangential"
    const checked = this.directionTargets.find((el) => el.checked)
    return checked ? checked.value : "tangential"
  }

  clearResults() {
    this.resultShrinkagePctTarget.textContent = "0.000%"
    this.resultChangeTarget.textContent = "0.0000"
    this.resultFinalDimTarget.textContent = "0.0000"
  }

  copy() {
    const text = `Wood Shrinkage Estimate:\nShrinkage: ${this.resultShrinkagePctTarget.textContent}\nDimension Change: ${this.resultChangeTarget.textContent}\nFinal Dimension: ${this.resultFinalDimTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
