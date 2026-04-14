import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM, IN_TO_CM, LB_TO_KG } from "utils/units"

const DENSITY_FACTOR = 45.0

export default class extends Controller {
  static targets = ["area", "tileLength", "tileWidth", "joint", "thickness", "waste",
                    "unitSystem", "areaLabel", "tileLengthLabel", "tileWidthLabel", "jointLabel", "thicknessLabel",
                    "perAreaHeading", "totalHeading", "bags25Heading", "bags10Heading", "coverageHeading",
                    "resultLbsPerSqft", "resultPounds", "resultBags25", "resultBags10", "resultCoverage"]

  connect() {
    this.updateLabels()
    this.calculate()
  }

  switchUnits() {
    const toMetric = this.unitSystemTarget.value === "metric"
    const convert = (el, factor, digits = 2) => {
      const n = parseFloat(el.value)
      if (Number.isFinite(n)) el.value = (toMetric ? n * factor : n / factor).toFixed(digits)
    }
    convert(this.areaTarget, SQFT_TO_SQM)
    convert(this.tileLengthTarget, IN_TO_CM)
    convert(this.tileWidthTarget, IN_TO_CM)
    convert(this.jointTarget, IN_TO_CM, 3)
    convert(this.thicknessTarget, IN_TO_CM, 2)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.areaLabelTarget.textContent = metric ? "Area (m²)" : "Area (sq ft)"
    this.tileLengthLabelTarget.textContent = metric ? "Tile L (cm)" : "Tile L (in)"
    this.tileWidthLabelTarget.textContent = metric ? "Tile W (cm)" : "Tile W (in)"
    this.jointLabelTarget.textContent = metric ? "Joint width (cm)" : "Joint width (in)"
    this.thicknessLabelTarget.textContent = metric ? "Depth (cm)" : "Depth (in)"
    this.perAreaHeadingTarget.textContent = metric ? "kg per m²" : "Lb per sq ft"
    this.totalHeadingTarget.textContent = metric ? "Total kilograms" : "Total pounds"
    this.bags25HeadingTarget.textContent = metric ? "11.3 kg bags" : "25 lb bags"
    this.bags10HeadingTarget.textContent = metric ? "4.5 kg bags" : "10 lb bags"
    this.coverageHeadingTarget.textContent = metric ? "Coverage / 11.3 kg" : "Coverage / 25 lb"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const areaInput = parseFloat(this.areaTarget.value)
    const lInput = parseFloat(this.tileLengthTarget.value)
    const wInput = parseFloat(this.tileWidthTarget.value)
    const jInput = parseFloat(this.jointTarget.value)
    const tInput = parseFloat(this.thicknessTarget.value)
    const waste = parseFloat(this.wasteTarget.value)

    if (![areaInput, lInput, wInput, jInput, tInput].every(n => Number.isFinite(n) && n > 0) ||
        !Number.isFinite(waste) || waste < 0) {
      this.clear()
      return
    }

    // Imperial math internally.
    const area = metric ? areaInput / SQFT_TO_SQM : areaInput
    const l = metric ? lInput / IN_TO_CM : lInput
    const w = metric ? wInput / IN_TO_CM : wInput
    const j = metric ? jInput / IN_TO_CM : jInput
    const t = metric ? tInput / IN_TO_CM : tInput

    const lbsPerSqft = ((l + w) / (l * w)) * j * t * DENSITY_FACTOR
    const pounds = lbsPerSqft * area * (1 + waste / 100)
    const bags25 = Math.ceil(pounds / 25)
    const bags10 = Math.ceil(pounds / 10)
    const coverage = 25 / lbsPerSqft

    if (metric) {
      const kgPerM2 = lbsPerSqft * LB_TO_KG / SQFT_TO_SQM
      const kgTotal = pounds * LB_TO_KG
      const coverageM2 = coverage * SQFT_TO_SQM
      this.resultLbsPerSqftTarget.textContent = `${kgPerM2.toFixed(3)} kg`
      this.resultPoundsTarget.textContent = `${kgTotal.toFixed(1)} kg`
      this.resultBags25Target.textContent = `${bags25}`
      this.resultBags10Target.textContent = `${bags10}`
      this.resultCoverageTarget.textContent = `${coverageM2.toFixed(1)} m²`
    } else {
      this.resultLbsPerSqftTarget.textContent = `${lbsPerSqft.toFixed(3)} lb`
      this.resultPoundsTarget.textContent = `${pounds.toFixed(1)} lb`
      this.resultBags25Target.textContent = `${bags25}`
      this.resultBags10Target.textContent = `${bags10}`
      this.resultCoverageTarget.textContent = `${coverage.toFixed(0)} sq ft`
    }
  }

  clear() {
    ["resultLbsPerSqft", "resultPounds", "resultBags25", "resultBags10", "resultCoverage"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
  }

  copy() {
    const text = `Grout needed:\nTotal: ${this.resultPoundsTarget.textContent}\n${this.bags25HeadingTarget.textContent}: ${this.resultBags25Target.textContent}\n${this.bags10HeadingTarget.textContent}: ${this.resultBags10Target.textContent}\n${this.coverageHeadingTarget.textContent}: ${this.resultCoverageTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
