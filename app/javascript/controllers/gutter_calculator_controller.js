import { Controller } from "@hotwired/stimulus"
import { FT_TO_M } from "utils/units"

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
                    "unitSystem", "eave1Label", "eave2Label", "eave3Label", "eave4Label",
                    "downspoutLengthLabel", "priceLabel",
                    "resultSizeLabel", "resultGutterFt", "resultDownspouts", "resultDownspoutFt", "resultTotal", "resultCost"]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el, factor) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * factor : n / factor).toFixed(2)
    }
    convert(this.eave1Target, FT_TO_M)
    convert(this.eave2Target, FT_TO_M)
    convert(this.eave3Target, FT_TO_M)
    convert(this.eave4Target, FT_TO_M)
    convert(this.downspoutLengthTarget, FT_TO_M)
    convert(this.priceTarget, 1 / FT_TO_M)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    const lenUnit = metric ? "m" : "ft"
    this.eave1LabelTarget.textContent = `Eave 1 (${lenUnit})`
    this.eave2LabelTarget.textContent = `Eave 2 (${lenUnit})`
    this.eave3LabelTarget.textContent = `Eave 3 (${lenUnit})`
    this.eave4LabelTarget.textContent = `Eave 4 (${lenUnit})`
    this.downspoutLengthLabelTarget.textContent = metric ? "Downspout length (m each)" : "Downspout length (ft each)"
    this.priceLabelTarget.textContent = metric ? "Price / linear m ($, optional)" : "Price / linear ft ($, optional)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const eaves = [this.eave1Target, this.eave2Target, this.eave3Target, this.eave4Target]
      .map(t => parseFloat(t.value))
      .filter(n => Number.isFinite(n) && n > 0)
    const size = this.sizeTarget.value
    const downspoutLenInput = parseFloat(this.downspoutLengthTarget.value)
    const price = parseFloat(this.priceTarget.value)

    if (eaves.length === 0 || !SPACING[size] || !Number.isFinite(downspoutLenInput) || downspoutLenInput <= 0) {
      this.clear()
      return
    }

    // Imperial math internally (ft).
    const eavesFt = metric ? eaves.map(e => e / FT_TO_M) : eaves
    const downspoutLen = metric ? downspoutLenInput / FT_TO_M : downspoutLenInput

    const spacing = SPACING[size]
    const totalFt = eavesFt.reduce((a, b) => a + b, 0)
    const downspouts = eavesFt.reduce((acc, len) => acc + Math.max(Math.ceil(len / spacing), 1), 0)
    const downspoutFt = downspouts * downspoutLen
    const total = totalFt + downspoutFt

    this.resultSizeLabelTarget.textContent = LABELS[size]
    if (metric) {
      const totalM = totalFt * FT_TO_M
      const downspoutM = downspoutFt * FT_TO_M
      const totalCombinedM = total * FT_TO_M
      this.resultGutterFtTarget.textContent = `${totalM.toFixed(2)} m`
      this.resultDownspoutsTarget.textContent = `${downspouts}`
      this.resultDownspoutFtTarget.textContent = `${downspoutM.toFixed(2)} m`
      this.resultTotalTarget.textContent = `${totalCombinedM.toFixed(2)} m`
      if (Number.isFinite(price) && price > 0) {
        this.resultCostTarget.textContent = `$${(totalCombinedM * price).toFixed(2)}`
      } else {
        this.resultCostTarget.textContent = "—"
      }
    } else {
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
