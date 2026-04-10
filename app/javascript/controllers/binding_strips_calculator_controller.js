import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "quiltWidth", "quiltLength", "stripWidth", "fabricWidth", "overage",
    "resultPerimeter", "resultTotalLength", "resultStripsNeeded",
    "resultFabricUsed", "resultYards", "resultMeters"
  ]

  connect() {
    this.calculate()
  }

  calculate() {
    const quiltWidth = parseFloat(this.quiltWidthTarget.value) || 0
    const quiltLength = parseFloat(this.quiltLengthTarget.value) || 0
    const stripWidth = parseFloat(this.stripWidthTarget.value) || 0
    const fabricWidth = parseFloat(this.fabricWidthTarget.value) || 0
    const overage = parseFloat(this.overageTarget.value) || 0

    if (quiltWidth <= 0 || quiltLength <= 0 || stripWidth <= 0 || fabricWidth <= 0 || overage < 0) {
      this.clearResults()
      return
    }

    const perimeter = 2 * (quiltWidth + quiltLength)
    const totalLengthNeeded = perimeter + overage
    const stripsNeeded = Math.ceil(totalLengthNeeded / fabricWidth)
    const fabricUsedIn = stripsNeeded * stripWidth
    const fabricYards = fabricUsedIn / 36
    const fabricMeters = fabricUsedIn * 0.0254

    this.resultPerimeterTarget.textContent = `${perimeter.toFixed(2)} in`
    this.resultTotalLengthTarget.textContent = `${totalLengthNeeded.toFixed(2)} in`
    this.resultStripsNeededTarget.textContent = stripsNeeded
    this.resultFabricUsedTarget.textContent = `${fabricUsedIn.toFixed(2)} in`
    this.resultYardsTarget.textContent = fabricYards.toFixed(3)
    this.resultMetersTarget.textContent = fabricMeters.toFixed(3)
  }

  clearResults() {
    this.resultPerimeterTarget.textContent = "0 in"
    this.resultTotalLengthTarget.textContent = "0 in"
    this.resultStripsNeededTarget.textContent = "0"
    this.resultFabricUsedTarget.textContent = "0 in"
    this.resultYardsTarget.textContent = "0"
    this.resultMetersTarget.textContent = "0"
  }

  copy() {
    const text = `Quilt Binding Strips Estimate:\nPerimeter: ${this.resultPerimeterTarget.textContent}\nTotal Length Needed: ${this.resultTotalLengthTarget.textContent}\nStrips Needed: ${this.resultStripsNeededTarget.textContent}\nFabric Used: ${this.resultFabricUsedTarget.textContent}\nTotal Yards: ${this.resultYardsTarget.textContent}\nTotal Meters: ${this.resultMetersTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
