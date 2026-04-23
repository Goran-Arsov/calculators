import { Controller } from "@hotwired/stimulus"

const INCHES_TO_CM = 2.54

export default class extends Controller {
  static targets = [
    "unitSystem", "quiltWidth", "quiltLength", "stripWidth", "fabricWidth", "overage",
    "widthLabel", "lengthLabel", "fabricLabel", "overageLabel",
    "resultPerimeter", "resultTotalLength", "resultStripsNeeded",
    "resultFabricUsed", "resultYards", "resultMeters"
  ]

  connect() {
    this.calculate()
  }

  unitChanged() {
    const metric = this.isMetric()
    const pairs = [
      [this.quiltWidthTarget, 60, 150],
      [this.quiltLengthTarget, 80, 200],
      [this.fabricWidthTarget, 42, 110],
      [this.overageTarget, 10, 25]
    ]

    for (const [el, impDefault, metricDefault] of pairs) {
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
      this.fabricLabelTarget.textContent = `Fabric Usable Width (${unit})`
      this.overageLabelTarget.textContent = `Overage for Corners & Joining (${unit})`
    }

    this.calculate()
  }

  calculate() {
    const metric = this.isMetric()
    const toIn = (v) => (metric ? v / INCHES_TO_CM : v)

    const quiltWidth = toIn(parseFloat(this.quiltWidthTarget.value) || 0)
    const quiltLength = toIn(parseFloat(this.quiltLengthTarget.value) || 0)
    // Strip width values in the select are stored in inches — no conversion
    const stripWidth = parseFloat(this.stripWidthTarget.value) || 0
    const fabricWidth = toIn(parseFloat(this.fabricWidthTarget.value) || 0)
    const overage = toIn(parseFloat(this.overageTarget.value) || 0)

    if (quiltWidth <= 0 || quiltLength <= 0 || stripWidth <= 0 || fabricWidth <= 0 || overage < 0) {
      this.clearResults()
      return
    }

    const perimeter = 2 * (quiltWidth + quiltLength)
    const totalLengthNeeded = perimeter + overage
    const stripsNeeded = Math.ceil(totalLengthNeeded / fabricWidth)
    const fabricUsedIn = stripsNeeded * stripWidth
    const fabricYards = fabricUsedIn / 36
    const fabricMeters = fabricUsedIn * INCHES_TO_CM / 100

    this.resultPerimeterTarget.textContent =
      `${perimeter.toFixed(2)} in (${(perimeter * INCHES_TO_CM).toFixed(1)} cm)`
    this.resultTotalLengthTarget.textContent =
      `${totalLengthNeeded.toFixed(2)} in (${(totalLengthNeeded * INCHES_TO_CM).toFixed(1)} cm)`
    this.resultStripsNeededTarget.textContent = stripsNeeded
    this.resultFabricUsedTarget.textContent =
      `${fabricUsedIn.toFixed(2)} in (${(fabricUsedIn * INCHES_TO_CM).toFixed(1)} cm)`
    this.resultYardsTarget.textContent = fabricYards.toFixed(3)
    this.resultMetersTarget.textContent = fabricMeters.toFixed(3)
  }

  isMetric() {
    return this.hasUnitSystemTarget && this.unitSystemTarget.value === "metric"
  }

  clearResults() {
    this.resultPerimeterTarget.textContent = "0 in (0 cm)"
    this.resultTotalLengthTarget.textContent = "0 in (0 cm)"
    this.resultStripsNeededTarget.textContent = "0"
    this.resultFabricUsedTarget.textContent = "0 in (0 cm)"
    this.resultYardsTarget.textContent = "0"
    this.resultMetersTarget.textContent = "0"
  }

  copy() {
    const text = `Quilt Binding Strips Estimate:\nPerimeter: ${this.resultPerimeterTarget.textContent}\nTotal Length Needed: ${this.resultTotalLengthTarget.textContent}\nStrips Needed: ${this.resultStripsNeededTarget.textContent}\nFabric Used: ${this.resultFabricUsedTarget.textContent}\nTotal Yards: ${this.resultYardsTarget.textContent}\nTotal Meters: ${this.resultMetersTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
