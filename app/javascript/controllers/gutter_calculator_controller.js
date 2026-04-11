import { Controller } from "@hotwired/stimulus"

const SPACING = {
  "5_inch": 35,
  "6_inch": 50,
  "7_inch": 60
}

const LABELS = {
  "5_inch": "5-inch K-style",
  "6_inch": "6-inch K-style",
  "7_inch": "7-inch K-style"
}

export default class extends Controller {
  static targets = ["eave1", "eave2", "eave3", "eave4", "size", "downspoutLength", "price",
                    "resultSizeLabel", "resultGutterFt", "resultDownspouts", "resultDownspoutFt", "resultTotal", "resultCost"]

  connect() { this.calculate() }

  calculate() {
    const eaves = [this.eave1Target, this.eave2Target, this.eave3Target, this.eave4Target]
      .map(t => parseFloat(t.value))
      .filter(n => Number.isFinite(n) && n > 0)
    const size = this.sizeTarget.value
    const downspoutLen = parseFloat(this.downspoutLengthTarget.value)
    const price = parseFloat(this.priceTarget.value)

    if (eaves.length === 0 || !SPACING[size] || !Number.isFinite(downspoutLen) || downspoutLen <= 0) {
      this.clear()
      return
    }

    const spacing = SPACING[size]
    const totalFt = eaves.reduce((a, b) => a + b, 0)
    const downspouts = eaves.reduce((acc, len) => acc + Math.max(Math.ceil(len / spacing), 1), 0)
    const downspoutFt = downspouts * downspoutLen
    const total = totalFt + downspoutFt

    this.resultSizeLabelTarget.textContent = LABELS[size]
    this.resultGutterFtTarget.textContent = `${totalFt.toFixed(1)} ft`
    this.resultDownspoutsTarget.textContent = `${downspouts}`
    this.resultDownspoutFtTarget.textContent = `${downspoutFt.toFixed(1)} ft`
    this.resultTotalTarget.textContent = `${total.toFixed(1)} ft`
    if (Number.isFinite(price) && price > 0) {
      this.resultCostTarget.textContent = `$${(total * price).toFixed(2)}`
    } else {
      this.resultCostTarget.textContent = "—"
    }
  }

  clear() {
    ["resultSizeLabel", "resultGutterFt", "resultDownspouts", "resultDownspoutFt", "resultTotal", "resultCost"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
  }

  copy() {
    const text = `Gutters:\nSize: ${this.resultSizeLabelTarget.textContent}\nGutter: ${this.resultGutterFtTarget.textContent}\nDownspouts: ${this.resultDownspoutsTarget.textContent}\nDownspout feet: ${this.resultDownspoutFtTarget.textContent}\nTotal: ${this.resultTotalTarget.textContent}\nCost: ${this.resultCostTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
