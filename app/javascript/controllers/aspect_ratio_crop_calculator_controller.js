import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "originalWidth", "originalHeight", "ratioW", "ratioH", "ratioPreset",
    "resultCropWidth", "resultCropHeight", "resultOffsetX", "resultOffsetY",
    "resultPercentKept", "resultMegapixels", "resultOriginalRatio"
  ]

  presetChanged() {
    const preset = this.ratioPresetTarget.value
    if (!preset) return
    const [w, h] = preset.split(":").map(Number)
    this.ratioWTarget.value = w
    this.ratioHTarget.value = h
    this.calculate()
  }

  calculate() {
    const ow = parseFloat(this.originalWidthTarget.value) || 0
    const oh = parseFloat(this.originalHeightTarget.value) || 0
    const rw = parseFloat(this.ratioWTarget.value) || 0
    const rh = parseFloat(this.ratioHTarget.value) || 0

    if (ow <= 0 || oh <= 0 || rw <= 0 || rh <= 0) {
      this.clearResults()
      return
    }

    const targetRatio = rw / rh
    const originalRatio = ow / oh
    let cropW, cropH

    if (targetRatio > originalRatio) {
      cropW = ow
      cropH = Math.round(ow / targetRatio)
    } else {
      cropH = oh
      cropW = Math.round(oh * targetRatio)
    }

    const offsetX = Math.round((ow - cropW) / 2)
    const offsetY = Math.round((oh - cropH) / 2)
    const percentKept = ((cropW * cropH) / (ow * oh) * 100)
    const megapixels = (cropW * cropH) / 1000000

    this.resultCropWidthTarget.textContent = `${cropW} px`
    this.resultCropHeightTarget.textContent = `${cropH} px`
    this.resultOffsetXTarget.textContent = `${offsetX} px`
    this.resultOffsetYTarget.textContent = `${offsetY} px`
    this.resultPercentKeptTarget.textContent = `${percentKept.toFixed(1)}%`
    this.resultMegapixelsTarget.textContent = `${megapixels.toFixed(1)} MP`

    // Simplify original ratio
    const gcd = this.gcd(ow, oh)
    this.resultOriginalRatioTarget.textContent = `${ow / gcd}:${oh / gcd}`
  }

  gcd(a, b) {
    a = Math.abs(Math.round(a))
    b = Math.abs(Math.round(b))
    while (b) { [a, b] = [b, a % b] }
    return a
  }

  clearResults() {
    this.resultCropWidthTarget.textContent = "—"
    this.resultCropHeightTarget.textContent = "—"
    this.resultOffsetXTarget.textContent = "—"
    this.resultOffsetYTarget.textContent = "—"
    this.resultPercentKeptTarget.textContent = "—"
    this.resultMegapixelsTarget.textContent = "—"
    this.resultOriginalRatioTarget.textContent = "—"
  }

  copy() {
    const text = `Aspect Ratio Crop Results:\nCrop: ${this.resultCropWidthTarget.textContent} x ${this.resultCropHeightTarget.textContent}\nOffset: ${this.resultOffsetXTarget.textContent}, ${this.resultOffsetYTarget.textContent}\nKept: ${this.resultPercentKeptTarget.textContent}\nMegapixels: ${this.resultMegapixelsTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
