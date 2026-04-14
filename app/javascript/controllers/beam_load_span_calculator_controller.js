import { Controller } from "@hotwired/stimulus"
import { FT_TO_M, LB_TO_KG, PSI_TO_KPA } from "utils/units"

const MATERIALS = {
  southern_pine: { fb: 1500, label: "Southern Pine (No. 2)" },
  douglas_fir: { fb: 1350, label: "Douglas Fir-Larch (No. 2)" },
  spruce: { fb: 1150, label: "Spruce-Pine-Fir (No. 2)" },
  lvl: { fb: 2600, label: "LVL (Laminated Veneer Lumber)" },
  steel_a36: { fb: 21600, label: "Steel A36" }
}

const LUMBER_SECTIONS = [
  { size: "2x6", s: 7.56 },
  { size: "2x8", s: 13.14 },
  { size: "2x10", s: 21.39 },
  { size: "2x12", s: 31.64 },
  { size: "4x6", s: 17.65 },
  { size: "4x8", s: 30.66 },
  { size: "4x10", s: 49.91 },
  { size: "4x12", s: 73.83 },
  { size: "6x6", s: 27.73 },
  { size: "6x8", s: 51.56 },
  { size: "6x10", s: 82.73 },
  { size: "6x12", s: 121.23 }
]

const IN3_TO_CM3 = 16.387064
// Force conversion: 1 lb-force ≈ 0.45359237 kgf (as weight/mass equivalent).
const PLF_TO_KGF_PER_M = LB_TO_KG / FT_TO_M // ≈ 1.4882
// ft-lbs to N·m (kgf·m approximation)
const LB_FT_TO_KGF_M = LB_TO_KG * FT_TO_M * (1 / FT_TO_M) // = LB_TO_KG; use kgf·m
const FTLBS_TO_NM = 1.3558179

export default class extends Controller {
  static targets = ["span", "load", "material",
    "unitSystem", "spanLabel", "loadLabel",
    "resultMoment", "resultSectionModulus", "resultRecommended",
    "resultMaterialLabel", "resultAllowableStress"]

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
    convert(this.spanTarget, FT_TO_M)
    convert(this.loadTarget, PLF_TO_KGF_PER_M)
    this.updateLabels()
    this.calculate()
  }

  updateLabels() {
    const metric = this.unitSystemTarget.value === "metric"
    this.spanLabelTarget.textContent = metric ? "Beam Span (m)" : "Beam Span (ft)"
    this.loadLabelTarget.textContent = metric ? "Load (kg per linear meter)" : "Load (lbs per linear foot)"
  }

  calculate() {
    const metric = this.unitSystemTarget.value === "metric"
    const spanInput = parseFloat(this.spanTarget.value) || 0
    const loadInput = parseFloat(this.loadTarget.value) || 0
    const materialKey = this.materialTarget.value || "douglas_fir"

    if (spanInput <= 0 || loadInput <= 0 || !MATERIALS[materialKey]) {
      this.clearResults()
      return
    }

    // Math is in imperial internally.
    const spanFt = metric ? spanInput / FT_TO_M : spanInput
    const loadPlf = metric ? loadInput / PLF_TO_KGF_PER_M : loadInput

    const mat = MATERIALS[materialKey]
    const fb = mat.fb
    const spanIn = spanFt * 12

    const wPerIn = loadPlf / 12
    const maxMomentLbIn = (wPerIn * spanIn * spanIn) / 8
    const requiredS = maxMomentLbIn / fb
    const maxMomentFtLbs = Math.round(maxMomentLbIn / 12)

    let recommended = "Exceeds standard sizes"
    for (const section of LUMBER_SECTIONS) {
      if (section.s >= requiredS) {
        recommended = metric
          ? `${section.size} (S = ${(section.s * IN3_TO_CM3).toFixed(1)} cm\u00B3)`
          : `${section.size} (S = ${section.s} in\u00B3)`
        break
      }
    }

    this.resultMaterialLabelTarget.textContent = mat.label
    if (metric) {
      const momentNm = maxMomentFtLbs * FTLBS_TO_NM
      const reqSCm3 = requiredS * IN3_TO_CM3
      const fbKpa = fb * PSI_TO_KPA
      this.resultMomentTarget.textContent = `${Math.round(momentNm).toLocaleString()} N·m`
      this.resultSectionModulusTarget.textContent = `${reqSCm3.toFixed(2)} cm\u00B3`
      this.resultAllowableStressTarget.textContent = `${Math.round(fbKpa).toLocaleString()} kPa`
    } else {
      this.resultMomentTarget.textContent = `${maxMomentFtLbs.toLocaleString()} ft-lbs`
      this.resultSectionModulusTarget.textContent = `${requiredS.toFixed(2)} in\u00B3`
      this.resultAllowableStressTarget.textContent = `${fb.toLocaleString()} PSI`
    }
    this.resultRecommendedTarget.textContent = recommended
  }

  clearResults() {
    const metric = this.unitSystemTarget.value === "metric"
    this.resultMomentTarget.textContent = metric ? "0 N·m" : "0 ft-lbs"
    this.resultSectionModulusTarget.textContent = metric ? "0 cm\u00B3" : "0 in\u00B3"
    this.resultRecommendedTarget.textContent = "--"
    this.resultMaterialLabelTarget.textContent = "--"
    this.resultAllowableStressTarget.textContent = metric ? "0 kPa" : "0 PSI"
  }

  copy() {
    const moment = this.resultMomentTarget.textContent
    const smod = this.resultSectionModulusTarget.textContent
    const rec = this.resultRecommendedTarget.textContent
    const mat = this.resultMaterialLabelTarget.textContent
    const text = `Beam Load Span Estimate:\nMaterial: ${mat}\nMax Moment: ${moment}\nRequired Section Modulus: ${smod}\nRecommended Size: ${rec}`
    navigator.clipboard.writeText(text)
  }
}
