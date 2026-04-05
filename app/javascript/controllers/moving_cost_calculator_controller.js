import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "distance", "homeSize",
    "packing", "piano", "storage", "insurance", "stairs",
    "resultLow", "resultHigh", "resultBaseLow", "resultBaseHigh",
    "resultExtrasLow", "resultExtrasHigh", "resultMoveType"
  ]

  static homeSizes = {
    "studio": { baseLow: 400,  baseHigh: 800,  weight: 2000 },
    "1bed":   { baseLow: 500,  baseHigh: 1000, weight: 3500 },
    "2bed":   { baseLow: 800,  baseHigh: 1500, weight: 5000 },
    "3bed":   { baseLow: 1200, baseHigh: 2200, weight: 7500 },
    "4bed":   { baseLow: 1500, baseHigh: 3000, weight: 10000 },
    "5bed":   { baseLow: 2000, baseHigh: 4000, weight: 12000 }
  }

  static extras = {
    "packing":   { low: 200,  high: 600 },
    "piano":     { low: 200,  high: 500 },
    "storage":   { low: 100,  high: 300 },
    "insurance": { low: 50,   high: 200 },
    "stairs":    { low: 75,   high: 250 }
  }

  calculate() {
    const distance = parseFloat(this.distanceTarget.value) || 0
    const sizeKey = this.homeSizeTarget.value
    const sizeData = this.constructor.homeSizes[sizeKey]
    if (!sizeData || distance <= 0) return

    let baseLow, baseHigh
    if (distance <= 100) {
      baseLow = sizeData.baseLow
      baseHigh = sizeData.baseHigh
    } else {
      const distFactor = distance * 0.50 * (sizeData.weight / 5000)
      baseLow = sizeData.baseLow + distFactor * 0.8
      baseHigh = sizeData.baseHigh + distFactor * 1.2
    }

    let extrasLow = 0
    let extrasHigh = 0
    const allExtras = this.constructor.extras

    for (const key of Object.keys(allExtras)) {
      if (this[`has${this.capitalize(key)}Target`] && this[`${key}Target`].checked) {
        extrasLow += allExtras[key].low
        extrasHigh += allExtras[key].high
      }
    }

    const totalLow = Math.round(baseLow + extrasLow)
    const totalHigh = Math.round(baseHigh + extrasHigh)

    this.resultLowTarget.textContent = "$" + totalLow.toLocaleString()
    this.resultHighTarget.textContent = "$" + totalHigh.toLocaleString()
    this.resultBaseLowTarget.textContent = "$" + Math.round(baseLow).toLocaleString()
    this.resultBaseHighTarget.textContent = "$" + Math.round(baseHigh).toLocaleString()
    this.resultExtrasLowTarget.textContent = "$" + extrasLow.toLocaleString()
    this.resultExtrasHighTarget.textContent = "$" + extrasHigh.toLocaleString()
    this.resultMoveTypeTarget.textContent = distance > 100 ? "Long Distance" : "Local"
  }

  capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1)
  }

  copy() {
    const low = this.resultLowTarget.textContent
    const high = this.resultHighTarget.textContent
    const type = this.resultMoveTypeTarget.textContent
    const text = `Estimated Cost: ${low} - ${high}\nMove Type: ${type}`
    navigator.clipboard.writeText(text)
  }
}
