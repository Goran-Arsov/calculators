import { Controller } from "@hotwired/stimulus"
import { IN_TO_CM } from "utils/units"

export default class extends Controller {
  static targets = ["length", "width", "height", "tankShape", "fishCount", "avgFishInches",
                     "volumeGallons", "volumeLiters", "maxFishInches", "stockingPercentage",
                     "stockingLevel", "filterGph", "heaterWatts",
                     "unitSystem", "lengthLabel", "widthLabel", "heightLabel",
                     "avgFishLabel", "maxFishLabel"]

  static GALLONS_PER_CUBIC_INCH = 0.004329
  static LITERS_PER_GALLON = 3.78541
  static FILTER_TURNOVER = 4
  static HEATER_WATTS_PER_GALLON = 5

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el, factor) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * factor : n / factor).toFixed(2)
    }
    convert(this.lengthTarget, IN_TO_CM)
    convert(this.widthTarget, IN_TO_CM)
    convert(this.heightTarget, IN_TO_CM)
    convert(this.avgFishInchesTarget, IN_TO_CM)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.lengthLabelTarget.textContent = metric ? "Length / Diameter (cm)" : "Length / Diameter (inches)"
    this.widthLabelTarget.textContent = metric ? "Width (cm)" : "Width (inches)"
    this.heightLabelTarget.textContent = metric ? "Height (cm)" : "Height (inches)"
    this.avgFishLabelTarget.textContent = metric ? "Average Fish Size (cm)" : "Average Fish Size (inches)"
    this.maxFishLabelTarget.textContent = metric ? "Max Fish (cm)" : "Max Fish (inches)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const lengthIn = this.toInches(parseFloat(this.lengthTarget.value) || 0, metric)
    const widthIn = this.toInches(parseFloat(this.widthTarget.value) || 0, metric)
    const heightIn = this.toInches(parseFloat(this.heightTarget.value) || 0, metric)
    const shape = this.tankShapeTarget.value
    const fishCount = parseInt(this.fishCountTarget.value) || 0
    const avgFishIn = this.toInches(parseFloat(this.avgFishInchesTarget.value) || 2, metric)

    if (lengthIn <= 0 || widthIn <= 0 || heightIn <= 0) {
      this.clearResults()
      return
    }

    let cubicInches
    switch (shape) {
      case "bow_front":
        cubicInches = lengthIn * widthIn * heightIn * 1.1
        break
      case "cylinder":
        cubicInches = Math.PI * Math.pow(lengthIn / 2, 2) * heightIn
        break
      case "hexagonal":
        const side = lengthIn / 2
        cubicInches = (3 * Math.sqrt(3) / 2) * Math.pow(side, 2) * heightIn
        break
      default:
        cubicInches = lengthIn * widthIn * heightIn
    }

    const effectiveCubicInches = cubicInches * 0.9
    const volumeGallons = effectiveCubicInches * this.constructor.GALLONS_PER_CUBIC_INCH
    const volumeLiters = volumeGallons * this.constructor.LITERS_PER_GALLON
    const maxFishInchesInt = Math.floor(volumeGallons)
    const currentFishInches = fishCount * avgFishIn
    const stockingPct = volumeGallons > 0 ? (currentFishInches / volumeGallons) * 100 : 0
    const filterGph = Math.ceil(volumeGallons * this.constructor.FILTER_TURNOVER)
    const heaterWatts = Math.ceil(volumeGallons * this.constructor.HEATER_WATTS_PER_GALLON)

    this.volumeGallonsTarget.textContent = `${volumeGallons.toFixed(1)} gal`
    this.volumeLitersTarget.textContent = `${volumeLiters.toFixed(1)} L`
    if (metric) {
      this.maxFishInchesTarget.textContent = `${(maxFishInchesInt * IN_TO_CM).toFixed(1)} cm`
    } else {
      this.maxFishInchesTarget.textContent = `${maxFishInchesInt} inches`
    }
    this.stockingPercentageTarget.textContent = `${stockingPct.toFixed(1)}%`
    this.stockingLevelTarget.textContent = this.getStockingLevel(stockingPct)
    this.filterGphTarget.textContent = `${filterGph} GPH`
    this.heaterWattsTarget.textContent = `${heaterWatts} watts`
  }

  toInches(value, metric) {
    return metric ? value / IN_TO_CM : value
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
      `${this.maxFishLabelTarget.textContent}: ${this.maxFishInchesTarget.textContent}`,
      `Stocking: ${this.stockingPercentageTarget.textContent} - ${this.stockingLevelTarget.textContent}`,
      `Filter Needed: ${this.filterGphTarget.textContent}`,
      `Heater Needed: ${this.heaterWattsTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
