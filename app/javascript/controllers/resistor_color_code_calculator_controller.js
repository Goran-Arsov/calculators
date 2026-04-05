import { Controller } from "@hotwired/stimulus"

const COLOR_VALUES = {
  black: 0, brown: 1, red: 2, orange: 3, yellow: 4,
  green: 5, blue: 6, violet: 7, gray: 8, white: 9
}

const MULTIPLIER_VALUES = {
  black: 1, brown: 10, red: 100, orange: 1e3, yellow: 1e4,
  green: 1e5, blue: 1e6, violet: 1e7, gray: 1e8, white: 1e9,
  gold: 0.1, silver: 0.01
}

const TOLERANCE_VALUES = {
  brown: 1, red: 2, green: 0.5, blue: 0.25, violet: 0.1,
  gray: 0.05, gold: 5, silver: 10, none: 20
}

export default class extends Controller {
  static targets = [
    "bands", "band1", "band2", "band3", "multiplier", "tolerance",
    "band3Group",
    "resultResistance", "resultTolerance", "resultRange", "resultBands",
    "resultsContainer"
  ]

  connect() {
    this.toggleBand3()
  }

  toggleBand3() {
    const bands = parseInt(this.bandsTarget.value)
    if (bands === 5) {
      this.band3GroupTarget.classList.remove("hidden")
    } else {
      this.band3GroupTarget.classList.add("hidden")
    }
    this.calculate()
  }

  calculate() {
    const bands = parseInt(this.bandsTarget.value)
    const b1 = this.band1Target.value
    const b2 = this.band2Target.value
    const mult = this.multiplierTarget.value
    const tol = this.toleranceTarget.value

    if (!b1 || !b2 || !mult || !tol) {
      this.clearResults()
      return
    }

    let digitValue
    if (bands === 5) {
      const b3 = this.band3Target.value
      if (!b3) { this.clearResults(); return }
      digitValue = COLOR_VALUES[b1] * 100 + COLOR_VALUES[b2] * 10 + COLOR_VALUES[b3]
    } else {
      digitValue = COLOR_VALUES[b1] * 10 + COLOR_VALUES[b2]
    }

    const resistance = digitValue * MULTIPLIER_VALUES[mult]
    const tolerance = TOLERANCE_VALUES[tol]
    const minR = resistance * (1 - tolerance / 100)
    const maxR = resistance * (1 + tolerance / 100)

    this.resultsContainerTarget.classList.remove("hidden")
    this.resultResistanceTarget.textContent = this.formatResistance(resistance)
    this.resultToleranceTarget.textContent = "\u00B1" + tolerance + "%"
    this.resultRangeTarget.textContent = this.formatResistance(minR) + " \u2013 " + this.formatResistance(maxR)
    this.resultBandsTarget.textContent = bands + "-band"
  }

  clearResults() {
    this.resultsContainerTarget.classList.add("hidden")
    this.resultResistanceTarget.textContent = "\u2014"
    this.resultToleranceTarget.textContent = "\u2014"
    this.resultRangeTarget.textContent = "\u2014"
    this.resultBandsTarget.textContent = "\u2014"
  }

  formatResistance(value) {
    if (value >= 1e9) return (value / 1e9).toFixed(2) + " G\u2126"
    if (value >= 1e6) return (value / 1e6).toFixed(2) + " M\u2126"
    if (value >= 1e3) return (value / 1e3).toFixed(2) + " k\u2126"
    if (value >= 1) return value.toFixed(2) + " \u2126"
    return (value * 1000).toFixed(2) + " m\u2126"
  }

  copy() {
    const text = "Resistance: " + this.resultResistanceTarget.textContent +
      " " + this.resultToleranceTarget.textContent +
      " (Range: " + this.resultRangeTarget.textContent + ")"
    navigator.clipboard.writeText(text)
  }
}
