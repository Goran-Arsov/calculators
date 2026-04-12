import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "focalLength", "aperture", "distance", "sensorSize",
    "resultDof", "resultNear", "resultFar", "resultHyperfocal", "resultUnit"
  ]

  static values = {
    sensorCoc: { type: Object, default: {
      full_frame: 0.03,
      apsc_canon: 0.019,
      apsc_nikon: 0.02,
      micro_four_thirds: 0.015,
      medium_format: 0.043
    }}
  }

  calculate() {
    const focalLength = parseFloat(this.focalLengthTarget.value) || 0
    const aperture = parseFloat(this.apertureTarget.value) || 0
    const distance = parseFloat(this.distanceTarget.value) || 0
    const sensorSize = this.sensorSizeTarget.value || "full_frame"

    if (focalLength <= 0 || aperture <= 0 || distance <= 0) {
      this.clearResults()
      return
    }

    const coc = this.sensorCocValue[sensorSize] || 0.03
    const f = focalLength // mm
    const N = aperture
    const s = distance  // meters

    // Hyperfocal distance: H = f^2 / (N * c) + f (mm), convert to meters
    const H = ((f * f) / (N * coc) + f) / 1000.0

    // Near limit: Dn = (H * s) / (H + (s - f/1000))
    const fMeters = f / 1000.0
    const near = (H * s) / (H + (s - fMeters))

    // Far limit: Df = (H * s) / (H - (s - f/1000))
    const farDenom = H - (s - fMeters)
    const far = farDenom <= 0 ? Infinity : (H * s) / farDenom

    const dof = far === Infinity ? Infinity : far - near

    // Display in appropriate unit
    if (dof === Infinity) {
      this.resultDofTarget.textContent = "Infinite"
    } else if (dof >= 1) {
      this.resultDofTarget.textContent = `${dof.toFixed(2)} m`
    } else {
      this.resultDofTarget.textContent = `${(dof * 1000).toFixed(1)} mm`
    }

    this.resultNearTarget.textContent = near >= 1 ? `${near.toFixed(2)} m` : `${(near * 1000).toFixed(1)} mm`

    if (far === Infinity) {
      this.resultFarTarget.textContent = "Infinite"
    } else {
      this.resultFarTarget.textContent = far >= 1 ? `${far.toFixed(2)} m` : `${(far * 1000).toFixed(1)} mm`
    }

    this.resultHyperfocalTarget.textContent = H >= 1 ? `${H.toFixed(2)} m` : `${(H * 1000).toFixed(1)} mm`
  }

  clearResults() {
    this.resultDofTarget.textContent = "—"
    this.resultNearTarget.textContent = "—"
    this.resultFarTarget.textContent = "—"
    this.resultHyperfocalTarget.textContent = "—"
  }

  copy() {
    const text = `Depth of Field Results:\nDoF: ${this.resultDofTarget.textContent}\nNear Limit: ${this.resultNearTarget.textContent}\nFar Limit: ${this.resultFarTarget.textContent}\nHyperfocal: ${this.resultHyperfocalTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
