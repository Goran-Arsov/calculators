import { Controller } from "@hotwired/stimulus"

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

export default class extends Controller {
  static targets = ["span", "load", "material",
    "resultMoment", "resultSectionModulus", "resultRecommended",
    "resultMaterialLabel", "resultAllowableStress"]

  calculate() {
    const spanFt = parseFloat(this.spanTarget.value) || 0
    const loadPlf = parseFloat(this.loadTarget.value) || 0
    const materialKey = this.materialTarget.value || "douglas_fir"

    if (spanFt <= 0 || loadPlf <= 0 || !MATERIALS[materialKey]) {
      this.clearResults()
      return
    }

    const mat = MATERIALS[materialKey]
    const fb = mat.fb
    const spanIn = spanFt * 12

    const wPerIn = loadPlf / 12
    const maxMomentLbIn = (wPerIn * spanIn * spanIn) / 8
    const requiredS = (maxMomentLbIn / fb).toFixed(2)
    const maxMomentFtLbs = Math.round(maxMomentLbIn / 12)

    let recommended = "Exceeds standard sizes"
    for (const section of LUMBER_SECTIONS) {
      if (section.s >= requiredS) {
        recommended = `${section.size} (S = ${section.s} in\u00B3)`
        break
      }
    }

    this.resultMomentTarget.textContent = `${maxMomentFtLbs.toLocaleString()} ft-lbs`
    this.resultSectionModulusTarget.textContent = `${requiredS} in\u00B3`
    this.resultRecommendedTarget.textContent = recommended
    this.resultMaterialLabelTarget.textContent = mat.label
    this.resultAllowableStressTarget.textContent = `${fb.toLocaleString()} PSI`
  }

  clearResults() {
    this.resultMomentTarget.textContent = "0 ft-lbs"
    this.resultSectionModulusTarget.textContent = "0 in\u00B3"
    this.resultRecommendedTarget.textContent = "--"
    this.resultMaterialLabelTarget.textContent = "--"
    this.resultAllowableStressTarget.textContent = "0 PSI"
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
