import { Controller } from "@hotwired/stimulus"
import { SQFT_TO_SQM, FT_TO_M } from "utils/units"

const SQ_IN_PER_SQFT = 144
const SQ_CM_PER_SQ_IN = 6.4516
const SQ_CM_PER_SQM = 10000

export default class extends Controller {
  static targets = ["area", "method", "soffitNfa", "ridgeNfa",
                    "unitSystem", "areaLabel", "soffitNfaLabel", "ridgeNfaLabel",
                    "nfaSqinHeading", "ridgeHeading",
                    "resultMethod", "resultNfaSqft", "resultNfaSqin",
                    "resultIntake", "resultExhaust", "resultSoffit", "resultRidge"]

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
    convert(this.areaTarget, SQFT_TO_SQM)
    convert(this.soffitNfaTarget, SQ_CM_PER_SQ_IN)
    convert(this.ridgeNfaTarget, SQ_CM_PER_SQ_IN)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.areaLabelTarget.textContent = metric ? "Attic floor area (m²)" : "Attic floor area (sq ft)"
    this.soffitNfaLabelTarget.textContent = metric ? "NFA per soffit vent (cm²)" : "NFA per soffit vent (sq in)"
    this.ridgeNfaLabelTarget.textContent = metric ? "NFA per ridge vent meter (cm²)" : "NFA per ridge vent foot (sq in)"
    this.nfaSqinHeadingTarget.textContent = metric ? "Total NFA (cm²)" : "Total NFA (sq in)"
    this.ridgeHeadingTarget.textContent = metric ? "Ridge vent" : "Ridge vent"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const area = parseFloat(this.areaTarget.value)
    const method = this.methodTarget.value
    const soffitNfa = parseFloat(this.soffitNfaTarget.value)
    const ridgeNfa = parseFloat(this.ridgeNfaTarget.value)

    if (!Number.isFinite(area) || area <= 0 ||
        !["balanced_1_300", "unbalanced_1_150"].includes(method) ||
        !Number.isFinite(soffitNfa) || soffitNfa < 0 ||
        !Number.isFinite(ridgeNfa) || ridgeNfa < 0) {
      this.clear()
      return
    }

    // Math is in imperial internally; convert metric inputs to imperial before computing.
    const areaSqft = metric ? area / SQFT_TO_SQM : area
    const soffitNfaSqin = metric ? soffitNfa / SQ_CM_PER_SQ_IN : soffitNfa
    // In metric mode ridgeNfa is cm² per meter; convert to sq in per foot.
    const ridgeNfaSqinPerFt = metric ? (ridgeNfa / SQ_CM_PER_SQ_IN) * FT_TO_M : ridgeNfa

    const ratio = method === "balanced_1_300" ? 1 / 300 : 1 / 150
    const nfaSqft = areaSqft * ratio
    const nfaSqin = nfaSqft * SQ_IN_PER_SQFT
    const intake = nfaSqin / 2
    const exhaust = nfaSqin / 2
    const soffitPieces = soffitNfaSqin > 0 ? Math.ceil(intake / soffitNfaSqin) : 0
    const ridgeFeet = ridgeNfaSqinPerFt > 0 ? Math.ceil(exhaust / ridgeNfaSqinPerFt) : 0

    this.resultMethodTarget.textContent = method === "balanced_1_300" ? "1:300 (balanced)" : "1:150"
    if (metric) {
      const nfaSqm = nfaSqft * SQFT_TO_SQM
      const nfaSqcm = nfaSqm * SQ_CM_PER_SQM
      const intakeSqcm = intake * SQ_CM_PER_SQ_IN
      const exhaustSqcm = exhaust * SQ_CM_PER_SQ_IN
      const ridgeMeters = ridgeFeet * FT_TO_M
      this.resultNfaSqftTarget.textContent = `${nfaSqm.toFixed(3)} m²`
      this.resultNfaSqinTarget.textContent = `${nfaSqcm.toFixed(1)} cm²`
      this.resultIntakeTarget.textContent = `${intakeSqcm.toFixed(1)} cm²`
      this.resultExhaustTarget.textContent = `${exhaustSqcm.toFixed(1)} cm²`
      this.resultSoffitTarget.textContent = `${soffitPieces}`
      this.resultRidgeTarget.textContent = `${ridgeMeters.toFixed(2)} m`
    } else {
      this.resultNfaSqftTarget.textContent = `${nfaSqft.toFixed(3)} sq ft`
      this.resultNfaSqinTarget.textContent = `${nfaSqin.toFixed(1)} sq in`
      this.resultIntakeTarget.textContent = `${intake.toFixed(1)} sq in`
      this.resultExhaustTarget.textContent = `${exhaust.toFixed(1)} sq in`
      this.resultSoffitTarget.textContent = `${soffitPieces}`
      this.resultRidgeTarget.textContent = `${ridgeFeet} ft`
    }
  }

  clear() {
    ["resultMethod", "resultNfaSqft", "resultNfaSqin", "resultIntake", "resultExhaust", "resultSoffit", "resultRidge"].forEach(t => {
      this[`${t}Target`].textContent = "—"
    })
  }

  copy() {
    const text = `Attic ventilation:\nMethod: ${this.resultMethodTarget.textContent}\nTotal NFA: ${this.resultNfaSqinTarget.textContent}\nIntake: ${this.resultIntakeTarget.textContent}\nExhaust: ${this.resultExhaustTarget.textContent}\nSoffit vents: ${this.resultSoffitTarget.textContent}\nRidge vent: ${this.resultRidgeTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
