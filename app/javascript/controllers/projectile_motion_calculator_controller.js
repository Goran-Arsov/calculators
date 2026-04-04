import { Controller } from "@hotwired/stimulus"

const G = 9.80665

export default class extends Controller {
  static targets = ["velocity", "angle", "height",
                     "resultRange", "resultMaxHeight", "resultFlightTime",
                     "resultTimeToPeak", "resultHorizontalV", "resultVerticalV"]

  calculate() {
    const v = parseFloat(this.velocityTarget.value)
    const deg = parseFloat(this.angleTarget.value)
    const h = parseFloat(this.heightTarget.value) || 0

    if (v <= 0 || deg <= 0 || deg >= 90 || h < 0) {
      this.clearResults()
      return
    }

    const rad = deg * Math.PI / 180
    const vx = v * Math.cos(rad)
    const vy = v * Math.sin(rad)

    const tPeak = vy / G
    const maxH = h + (vy * vy) / (2 * G)
    const disc = vy * vy + 2 * G * h
    const totalT = (vy + Math.sqrt(disc)) / G
    const range = vx * totalT

    this.resultRangeTarget.textContent = this.fmt(range)
    this.resultMaxHeightTarget.textContent = this.fmt(maxH)
    this.resultFlightTimeTarget.textContent = this.fmt(totalT)
    this.resultTimeToPeakTarget.textContent = this.fmt(tPeak)
    this.resultHorizontalVTarget.textContent = this.fmt(vx)
    this.resultVerticalVTarget.textContent = this.fmt(vy)
  }

  clearResults() {
    this.resultRangeTarget.textContent = "—"
    this.resultMaxHeightTarget.textContent = "—"
    this.resultFlightTimeTarget.textContent = "—"
    this.resultTimeToPeakTarget.textContent = "—"
    this.resultHorizontalVTarget.textContent = "—"
    this.resultVerticalVTarget.textContent = "—"
  }

  fmt(n) { return n.toFixed(4).replace(/\.?0+$/, "") }

  copy() {
    const text = `Range: ${this.resultRangeTarget.textContent} m\nMax Height: ${this.resultMaxHeightTarget.textContent} m\nFlight Time: ${this.resultFlightTimeTarget.textContent} s`
    navigator.clipboard.writeText(text)
  }
}
