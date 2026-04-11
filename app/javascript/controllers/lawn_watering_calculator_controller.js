import { Controller } from "@hotwired/stimulus"

const GALLONS_PER_SQFT_INCH = 0.6234
const LITERS_PER_GALLON = 3.78541

export default class extends Controller {
  static targets = ["area", "inches", "gpm", "resultGallons", "resultLiters", "resultDaily", "resultMinutes"]

  connect() { this.calculate() }

  calculate() {
    const area = parseFloat(this.areaTarget.value)
    const inches = parseFloat(this.inchesTarget.value)
    const gpm = parseFloat(this.gpmTarget.value)

    if (!Number.isFinite(area) || area <= 0 ||
        !Number.isFinite(inches) || inches <= 0) {
      this.clear()
      return
    }

    const gallons = area * inches * GALLONS_PER_SQFT_INCH
    const liters = gallons * LITERS_PER_GALLON
    const daily = gallons / 7

    this.resultGallonsTarget.textContent = `${gallons.toFixed(0)} gal`
    this.resultLitersTarget.textContent = `${liters.toFixed(0)} L`
    this.resultDailyTarget.textContent = `${daily.toFixed(0)} gal`
    if (Number.isFinite(gpm) && gpm > 0) {
      this.resultMinutesTarget.textContent = `${Math.round(gallons / gpm)} min`
    } else {
      this.resultMinutesTarget.textContent = "—"
    }
  }

  clear() {
    this.resultGallonsTarget.textContent = "—"
    this.resultLitersTarget.textContent = "—"
    this.resultDailyTarget.textContent = "—"
    this.resultMinutesTarget.textContent = "—"
  }

  copy() {
    const text = `Lawn watering:\nWeekly: ${this.resultGallonsTarget.textContent} (${this.resultLitersTarget.textContent})\nDaily: ${this.resultDailyTarget.textContent}\nSprinkler run time / week: ${this.resultMinutesTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
