import { Controller } from "@hotwired/stimulus"

const SQ_IN_PER_SQFT = 144

export default class extends Controller {
  static targets = ["area", "method", "soffitNfa", "ridgeNfa",
                    "resultMethod", "resultNfaSqft", "resultNfaSqin",
                    "resultIntake", "resultExhaust", "resultSoffit", "resultRidge"]

  connect() { this.calculate() }

  calculate() {
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

    const ratio = method === "balanced_1_300" ? 1 / 300 : 1 / 150
    const nfaSqft = area * ratio
    const nfaSqin = nfaSqft * SQ_IN_PER_SQFT
    const intake = nfaSqin / 2
    const exhaust = nfaSqin / 2
    const soffitPieces = soffitNfa > 0 ? Math.ceil(intake / soffitNfa) : 0
    const ridgeFeet = ridgeNfa > 0 ? Math.ceil(exhaust / ridgeNfa) : 0

    this.resultMethodTarget.textContent = method === "balanced_1_300" ? "1:300 (balanced)" : "1:150"
    this.resultNfaSqftTarget.textContent = `${nfaSqft.toFixed(3)} sq ft`
    this.resultNfaSqinTarget.textContent = `${nfaSqin.toFixed(1)} sq in`
    this.resultIntakeTarget.textContent = `${intake.toFixed(1)} sq in`
    this.resultExhaustTarget.textContent = `${exhaust.toFixed(1)} sq in`
    this.resultSoffitTarget.textContent = `${soffitPieces}`
    this.resultRidgeTarget.textContent = `${ridgeFeet} ft`
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
