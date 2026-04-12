import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["length", "width", "height", "tankShape", "fishCount", "avgFishInches",
                     "volumeGallons", "volumeLiters", "maxFishInches", "stockingPercentage",
                     "stockingLevel", "filterGph", "heaterWatts"]

  static GALLONS_PER_CUBIC_INCH = 0.004329
  static LITERS_PER_GALLON = 3.78541
  static FILTER_TURNOVER = 4
  static HEATER_WATTS_PER_GALLON = 5

  calculate() {
    const length = parseFloat(this.lengthTarget.value) || 0
    const width = parseFloat(this.widthTarget.value) || 0
    const height = parseFloat(this.heightTarget.value) || 0
    const shape = this.tankShapeTarget.value
    const fishCount = parseInt(this.fishCountTarget.value) || 0
    const avgFishInches = parseFloat(this.avgFishInchesTarget.value) || 2

    if (length <= 0 || width <= 0 || height <= 0) {
      this.clearResults()
      return
    }

    let cubicInches
    switch (shape) {
      case "bow_front":
        cubicInches = length * width * height * 1.1
        break
      case "cylinder":
        cubicInches = Math.PI * Math.pow(length / 2, 2) * height
        break
      case "hexagonal":
        const side = length / 2
        cubicInches = (3 * Math.sqrt(3) / 2) * Math.pow(side, 2) * height
        break
      default:
        cubicInches = length * width * height
    }

    const effectiveCubicInches = cubicInches * 0.9
    const volumeGallons = effectiveCubicInches * this.constructor.GALLONS_PER_CUBIC_INCH
    const volumeLiters = volumeGallons * this.constructor.LITERS_PER_GALLON
    const maxFishInches = Math.floor(volumeGallons)
    const currentFishInches = fishCount * avgFishInches
    const stockingPct = volumeGallons > 0 ? (currentFishInches / volumeGallons) * 100 : 0
    const filterGph = Math.ceil(volumeGallons * this.constructor.FILTER_TURNOVER)
    const heaterWatts = Math.ceil(volumeGallons * this.constructor.HEATER_WATTS_PER_GALLON)

    this.volumeGallonsTarget.textContent = `${volumeGallons.toFixed(1)} gal`
    this.volumeLitersTarget.textContent = `${volumeLiters.toFixed(1)} L`
    this.maxFishInchesTarget.textContent = `${maxFishInches} inches`
    this.stockingPercentageTarget.textContent = `${stockingPct.toFixed(1)}%`
    this.stockingLevelTarget.textContent = this.getStockingLevel(stockingPct)
    this.filterGphTarget.textContent = `${filterGph} GPH`
    this.heaterWattsTarget.textContent = `${heaterWatts} watts`
  }

  getStockingLevel(pct) {
    if (pct < 50) return "Under-stocked"
    if (pct < 75) return "Lightly stocked"
    if (pct < 100) return "Well stocked"
    if (pct < 125) return "Fully stocked"
    return "Over-stocked"
  }

  clearResults() {
    this.volumeGallonsTarget.textContent = "\u2014"
    this.volumeLitersTarget.textContent = "\u2014"
    this.maxFishInchesTarget.textContent = "\u2014"
    this.stockingPercentageTarget.textContent = "\u2014"
    this.stockingLevelTarget.textContent = "\u2014"
    this.filterGphTarget.textContent = "\u2014"
    this.heaterWattsTarget.textContent = "\u2014"
  }

  copy() {
    const text = [
      `Volume: ${this.volumeGallonsTarget.textContent} (${this.volumeLitersTarget.textContent})`,
      `Max Fish (inches): ${this.maxFishInchesTarget.textContent}`,
      `Stocking: ${this.stockingPercentageTarget.textContent} - ${this.stockingLevelTarget.textContent}`,
      `Filter Needed: ${this.filterGphTarget.textContent}`,
      `Heater Needed: ${this.heaterWattsTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
