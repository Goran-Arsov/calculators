import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mode",
    "focalLength", "objectDistance", "imageDistance",
    "focalLengthGroup", "objectDistanceGroup", "imageDistanceGroup",
    "results",
    "resultFocal", "resultObject", "resultImage",
    "resultMagnification", "resultImageType", "resultOrientation",
    "resultSize", "resultLensType"
  ]

  connect() {
    this.updateFields()
  }

  updateFields() {
    const mode = this.modeTarget.value
    this.focalLengthGroupTarget.classList.toggle("hidden", mode === "find_focal")
    this.objectDistanceGroupTarget.classList.toggle("hidden", mode === "find_object")
    this.imageDistanceGroupTarget.classList.toggle("hidden", mode === "find_image")
    this.resultsTarget.classList.add("hidden")
  }

  calculate() {
    const mode = this.modeTarget.value
    let f, dObj, dImg

    if (mode === "find_image") {
      f = parseFloat(this.focalLengthTarget.value)
      dObj = parseFloat(this.objectDistanceTarget.value)
      if (isNaN(f) || f === 0 || isNaN(dObj) || dObj === 0) { this.resultsTarget.classList.add("hidden"); return }
      const invDi = (1/f) - (1/dObj)
      if (invDi === 0) { this.resultsTarget.classList.add("hidden"); return }
      dImg = 1 / invDi
    } else if (mode === "find_focal") {
      dObj = parseFloat(this.objectDistanceTarget.value)
      dImg = parseFloat(this.imageDistanceTarget.value)
      if (isNaN(dObj) || dObj === 0 || isNaN(dImg) || dImg === 0) { this.resultsTarget.classList.add("hidden"); return }
      const invF = (1/dObj) + (1/dImg)
      if (invF === 0) { this.resultsTarget.classList.add("hidden"); return }
      f = 1 / invF
    } else if (mode === "find_object") {
      f = parseFloat(this.focalLengthTarget.value)
      dImg = parseFloat(this.imageDistanceTarget.value)
      if (isNaN(f) || f === 0 || isNaN(dImg) || dImg === 0) { this.resultsTarget.classList.add("hidden"); return }
      const invDo = (1/f) - (1/dImg)
      if (invDo === 0) { this.resultsTarget.classList.add("hidden"); return }
      dObj = 1 / invDo
    }

    const mag = -dImg / dObj
    const absMag = Math.abs(mag)

    this.resultsTarget.classList.remove("hidden")
    this.resultFocalTarget.textContent = this.fmt(f) + " cm"
    this.resultObjectTarget.textContent = this.fmt(dObj) + " cm"
    this.resultImageTarget.textContent = this.fmt(dImg) + " cm"
    this.resultMagnificationTarget.textContent = this.fmt(mag) + "x"
    this.resultImageTypeTarget.textContent = dImg > 0 ? "Real" : "Virtual"
    this.resultOrientationTarget.textContent = mag > 0 ? "Upright" : "Inverted"
    this.resultSizeTarget.textContent = absMag > 1.001 ? "Enlarged" : absMag < 0.999 ? "Reduced" : "Same size"
    this.resultLensTypeTarget.textContent = f > 0 ? "Converging (convex)" : "Diverging (concave)"
  }

  fmt(n) {
    const abs = Math.abs(n)
    if (abs >= 1e6) return n.toExponential(4)
    if (abs >= 1000) return n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    return n.toFixed(4).replace(/\.?0+$/, "")
  }

  copy() {
    const results = this.resultsTarget.querySelectorAll("[data-result]")
    const lines = Array.from(results).map(el => el.textContent)
    navigator.clipboard.writeText("Lens Optics: " + lines.join(" | "))
  }
}
