import { Controller } from "@hotwired/stimulus"

const NAISMITH_KM_PER_HOUR = 5.0
const NAISMITH_ASCENT_M_PER_HOUR = 600.0
const LANGMUIR_DESCENT_HOURS_PER_300M = 10.0 / 60.0

const FITNESS_MULTIPLIERS = {
  fast: 0.80,
  normal: 1.00,
  moderate: 1.25,
  slow: 1.50
}

export default class extends Controller {
  static targets = ["distance", "ascent", "descent", "fitness", "resultFormatted", "resultBase", "resultAscent", "resultDescent"]

  connect() {
    this.calculate()
  }

  calculate() {
    const distance = parseFloat(this.distanceTarget.value)
    const ascent = parseFloat(this.ascentTarget.value)
    const descent = parseFloat(this.descentTarget.value)
    const fitness = this.fitnessTarget.value

    if (!Number.isFinite(distance) || distance <= 0 ||
        ascent < 0 || descent < 0 || !FITNESS_MULTIPLIERS[fitness]) {
      this.clear()
      return
    }

    const baseHours = distance / NAISMITH_KM_PER_HOUR
    const ascentHours = (Number.isFinite(ascent) ? ascent : 0) / NAISMITH_ASCENT_M_PER_HOUR
    const descentHours = (Number.isFinite(descent) ? descent : 0) / 300 * LANGMUIR_DESCENT_HOURS_PER_300M

    const subtotal = baseHours + ascentHours + descentHours
    const total = subtotal * FITNESS_MULTIPLIERS[fitness]

    this.resultFormattedTarget.textContent = this.formatHm(total)
    this.resultBaseTarget.textContent = `${baseHours.toFixed(2)}h`
    this.resultAscentTarget.textContent = `${ascentHours.toFixed(2)}h`
    this.resultDescentTarget.textContent = `${descentHours.toFixed(2)}h`
  }

  formatHm(hours) {
    let h = Math.floor(hours)
    let m = Math.round((hours - h) * 60)
    if (m === 60) { h += 1; m = 0 }
    return `${h}h ${m}m`
  }

  clear() {
    this.resultFormattedTarget.textContent = "0h 0m"
    this.resultBaseTarget.textContent = "0h"
    this.resultAscentTarget.textContent = "0h"
    this.resultDescentTarget.textContent = "0h"
  }

  copy() {
    const text = `Hiking Time Estimate:\nTotal: ${this.resultFormattedTarget.textContent}\nBase walking: ${this.resultBaseTarget.textContent}\nAscent: ${this.resultAscentTarget.textContent}\nDescent: ${this.resultDescentTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
