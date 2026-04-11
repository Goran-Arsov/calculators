import { Controller } from "@hotwired/stimulus"

const DENSITY_FACTOR = 45.0

export default class extends Controller {
  static targets = ["area", "tileLength", "tileWidth", "joint", "thickness", "waste",
                    "resultLbsPerSqft", "resultPounds", "resultBags25", "resultBags10", "resultCoverage"]

  connect() { this.calculate() }

  calculate() {
    const area = parseFloat(this.areaTarget.value)
    const l = parseFloat(this.tileLengthTarget.value)
    const w = parseFloat(this.tileWidthTarget.value)
    const j = parseFloat(this.jointTarget.value)
    const t = parseFloat(this.thicknessTarget.value)
    const waste = parseFloat(this.wasteTarget.value)

    if (![area, l, w, j, t].every(n => Number.isFinite(n) && n > 0) ||
        !Number.isFinite(waste) || waste < 0) {
      this.clear()
      return
    }

    const lbsPerSqft = ((l + w) / (l * w)) * j * t * DENSITY_FACTOR
    const pounds = lbsPerSqft * area * (1 + waste / 100)
    const bags25 = Math.ceil(pounds / 25)
    const bags10 = Math.ceil(pounds / 10)
    const coverage = 25 / lbsPerSqft

    this.resultLbsPerSqftTarget.textContent = `${lbsPerSqft.toFixed(3)} lb`
    this.resultPoundsTarget.textContent = `${pounds.toFixed(1)} lb`
    this.resultBags25Target.textContent = `${bags25}`
    this.resultBags10Target.textContent = `${bags10}`
    this.resultCoverageTarget.textContent = `${coverage.toFixed(0)} sq ft`
  }

  clear() {
    ["resultLbsPerSqft", "resultPounds", "resultBags25", "resultBags10", "resultCoverage"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
  }

  copy() {
    const text = `Grout needed:\nPounds: ${this.resultPoundsTarget.textContent}\n25 lb bags: ${this.resultBags25Target.textContent}\n10 lb bags: ${this.resultBags10Target.textContent}\nCoverage / 25 lb bag: ${this.resultCoverageTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
