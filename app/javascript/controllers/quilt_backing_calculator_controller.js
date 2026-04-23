import { Controller } from "@hotwired/stimulus"

const INCHES_TO_CM = 2.54
// Sensible metric defaults that match the fabric-width select options.
const METRIC_DEFAULTS = { quiltWidth: 150, quiltLength: 200, overage: 10 }
const IMPERIAL_DEFAULTS = { quiltWidth: 60, quiltLength: 80, overage: 4 }

export default class extends Controller {
  static targets = [
    "unitSystem", "quiltWidth", "quiltLength", "overage", "fabricWidth",
    "widthLabel", "lengthLabel", "overageLabel", "overageHint", "fabricWidthLabel",
    "resultBackingW", "resultBackingL", "resultNeedsSeam",
    "resultNumPanels", "resultSeamOrientation",
    "resultYards", "resultMeters"
  ]

  connect() {
    this.calculate()
  }

  unitChanged() {
    const metric = this.isMetric()
    const inputs = [
      [this.quiltWidthTarget, IMPERIAL_DEFAULTS.quiltWidth, METRIC_DEFAULTS.quiltWidth],
      [this.quiltLengthTarget, IMPERIAL_DEFAULTS.quiltLength, METRIC_DEFAULTS.quiltLength],
      [this.overageTarget, IMPERIAL_DEFAULTS.overage, METRIC_DEFAULTS.overage]
    ]

    for (const [el, impDefault, metricDefault] of inputs) {
      const current = parseFloat(el.value) || 0
      if (current > 0) {
        el.value = metric
          ? (current * INCHES_TO_CM).toFixed(1)
          : (current / INCHES_TO_CM).toFixed(2)
      } else {
        el.value = metric ? metricDefault : impDefault
      }
    }

    if (this.hasWidthLabelTarget) {
      const unit = metric ? "cm" : "inches"
      this.widthLabelTarget.textContent = `Quilt Width (${unit})`
      this.lengthLabelTarget.textContent = `Quilt Length (${unit})`
      this.overageLabelTarget.textContent = `Overage per Side (${unit})`
      this.fabricWidthLabelTarget.textContent = `Fabric Width (${unit})`
      this.overageHintTarget.textContent = metric
        ? "10 cm per side is standard for longarm quilting."
        : `4" per side is standard for longarm quilting.`
    }

    this.calculate()
  }

  calculate() {
    const metric = this.isMetric()
    const toIn = (v) => (metric ? v / INCHES_TO_CM : v)

    const quiltWidth = toIn(parseFloat(this.quiltWidthTarget.value) || 0)
    const quiltLength = toIn(parseFloat(this.quiltLengthTarget.value) || 0)
    const overage = toIn(parseFloat(this.overageTarget.value) || 0)
    // Fabric-width select values are stored in inches; they don't need conversion.
    const fabricWidth = parseFloat(this.fabricWidthTarget.value) || 0

    if (quiltWidth <= 0 || quiltLength <= 0 || overage < 0 || fabricWidth <= 0) {
      this.clearResults()
      return
    }

    const backingWidth = quiltWidth + (2 * overage)
    const backingLength = quiltLength + (2 * overage)

    let needsSeam, numPanels, seamOrientation, fabricLength

    if (backingWidth <= fabricWidth) {
      needsSeam = false
      numPanels = 1
      seamOrientation = "none"
      fabricLength = backingLength
    } else {
      const numPanelsA = Math.ceil(backingWidth / fabricWidth)
      const fabricLengthA = numPanelsA * backingLength
      const numPanelsB = Math.ceil(backingLength / fabricWidth)
      const fabricLengthB = numPanelsB * backingWidth

      needsSeam = true
      if (fabricLengthA <= fabricLengthB) {
        numPanels = numPanelsA
        seamOrientation = "vertical"
        fabricLength = fabricLengthA
      } else {
        numPanels = numPanelsB
        seamOrientation = "horizontal"
        fabricLength = fabricLengthB
      }
    }

    const totalYards = fabricLength / 36
    const totalMeters = fabricLength * INCHES_TO_CM / 100

    this.resultBackingWTarget.textContent =
      `${backingWidth.toFixed(1)} in (${(backingWidth * INCHES_TO_CM).toFixed(1)} cm)`
    this.resultBackingLTarget.textContent =
      `${backingLength.toFixed(1)} in (${(backingLength * INCHES_TO_CM).toFixed(1)} cm)`
    this.resultNeedsSeamTarget.textContent = needsSeam ? "Yes" : "No"
    this.resultNumPanelsTarget.textContent = numPanels
    this.resultSeamOrientationTarget.textContent = this.capitalize(seamOrientation)
    this.resultYardsTarget.textContent = totalYards.toFixed(3)
    this.resultMetersTarget.textContent = totalMeters.toFixed(3)
  }

  isMetric() {
    return this.hasUnitSystemTarget && this.unitSystemTarget.value === "metric"
  }

  capitalize(str) {
    if (!str) return ""
    return str.charAt(0).toUpperCase() + str.slice(1)
  }

  clearResults() {
    this.resultBackingWTarget.textContent = "0 in (0 cm)"
    this.resultBackingLTarget.textContent = "0 in (0 cm)"
    this.resultNeedsSeamTarget.textContent = "—"
    this.resultNumPanelsTarget.textContent = "0"
    this.resultSeamOrientationTarget.textContent = "—"
    this.resultYardsTarget.textContent = "0"
    this.resultMetersTarget.textContent = "0"
  }

  copy() {
    const text = `Quilt Backing Estimate:\nBacking Width: ${this.resultBackingWTarget.textContent}\nBacking Length: ${this.resultBackingLTarget.textContent}\nNeeds Seam: ${this.resultNeedsSeamTarget.textContent}\nPanels: ${this.resultNumPanelsTarget.textContent}\nSeam Orientation: ${this.resultSeamOrientationTarget.textContent}\nTotal Yards: ${this.resultYardsTarget.textContent}\nTotal Meters: ${this.resultMetersTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
