import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "quiltWidth", "quiltLength", "overage", "fabricWidth",
    "resultBackingW", "resultBackingL", "resultNeedsSeam",
    "resultNumPanels", "resultSeamOrientation",
    "resultYards", "resultMeters"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const quiltWidth = parseFloat(this.quiltWidthTarget.value) || 0
    const quiltLength = parseFloat(this.quiltLengthTarget.value) || 0
    const overage = parseFloat(this.overageTarget.value) || 0
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
    const totalMeters = fabricLength * 0.0254

    this.resultBackingWTarget.textContent = `${backingWidth.toFixed(1)} in`
    this.resultBackingLTarget.textContent = `${backingLength.toFixed(1)} in`
    this.resultNeedsSeamTarget.textContent = needsSeam ? "Yes" : "No"
    this.resultNumPanelsTarget.textContent = numPanels
    this.resultSeamOrientationTarget.textContent = this.capitalize(seamOrientation)
    this.resultYardsTarget.textContent = totalYards.toFixed(3)
    this.resultMetersTarget.textContent = totalMeters.toFixed(3)
  }

  capitalize(str) {
    if (!str) return ""
    return str.charAt(0).toUpperCase() + str.slice(1)
  }

  clearResults() {
    this.resultBackingWTarget.textContent = "0 in"
    this.resultBackingLTarget.textContent = "0 in"
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
