import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "foreground", "background", "fgPreview", "bgPreview",
    "resultRatio", "resultAaNormal", "resultAaLarge",
    "resultAaaNormal", "resultAaaLarge", "preview", "error"
  ]

  calculate() {
    const fg = this.foregroundTarget.value.trim()
    const bg = this.backgroundTarget.value.trim()

    if (!fg || !bg) return

    const fgRgb = this.parseHex(fg)
    const bgRgb = this.parseHex(bg)

    if (!fgRgb || !bgRgb) {
      this.showError("Enter valid hex colors (e.g., #FF0000 or #F00).")
      return
    }
    this.hideError()

    const fgL = this.relativeLuminance(fgRgb)
    const bgL = this.relativeLuminance(bgRgb)
    const ratio = this.contrastRatio(fgL, bgL)

    this.resultRatioTarget.textContent = `${ratio.toFixed(2)}:1`

    this.setPassFail(this.resultAaNormalTarget, ratio >= 4.5)
    this.setPassFail(this.resultAaLargeTarget, ratio >= 3.0)
    this.setPassFail(this.resultAaaNormalTarget, ratio >= 7.0)
    this.setPassFail(this.resultAaaLargeTarget, ratio >= 4.5)

    // Update previews
    const fgHex = this.normalizeHex(fg)
    const bgHex = this.normalizeHex(bg)

    if (this.hasFgPreviewTarget) this.fgPreviewTarget.style.backgroundColor = fgHex
    if (this.hasBgPreviewTarget) this.bgPreviewTarget.style.backgroundColor = bgHex

    if (this.hasPreviewTarget) {
      this.previewTarget.style.color = fgHex
      this.previewTarget.style.backgroundColor = bgHex
    }
  }

  parseHex(color) {
    let clean = color.replace(/^#/, "")
    if (clean.length === 3) clean = clean.split("").map(c => c + c).join("")
    if (!/^[0-9A-Fa-f]{6}$/.test(clean)) return null
    return [parseInt(clean.substr(0, 2), 16), parseInt(clean.substr(2, 2), 16), parseInt(clean.substr(4, 2), 16)]
  }

  normalizeHex(color) {
    let clean = color.replace(/^#/, "")
    if (clean.length === 3) clean = clean.split("").map(c => c + c).join("")
    return `#${clean}`
  }

  relativeLuminance([r, g, b]) {
    const [rl, gl, bl] = [r, g, b].map(c => {
      const s = c / 255
      return s <= 0.04045 ? s / 12.92 : Math.pow((s + 0.055) / 1.055, 2.4)
    })
    return 0.2126 * rl + 0.7152 * gl + 0.0722 * bl
  }

  contrastRatio(l1, l2) {
    const lighter = Math.max(l1, l2)
    const darker = Math.min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)
  }

  setPassFail(target, passes) {
    target.textContent = passes ? "Pass" : "Fail"
    target.className = target.className.replace(/text-\w+-\d+/g, "")
    if (passes) {
      target.classList.add("text-green-600", "font-bold")
      target.classList.remove("text-red-600")
    } else {
      target.classList.add("text-red-600", "font-bold")
      target.classList.remove("text-green-600")
    }
  }

  showError(msg) { this.errorTarget.textContent = msg; this.errorTarget.classList.remove("hidden") }
  hideError() { this.errorTarget.classList.add("hidden") }

  swap() {
    const temp = this.foregroundTarget.value
    this.foregroundTarget.value = this.backgroundTarget.value
    this.backgroundTarget.value = temp
    this.calculate()
  }

  copy() {
    const ratio = this.resultRatioTarget.textContent
    const aa = this.resultAaNormalTarget.textContent
    const aaa = this.resultAaaNormalTarget.textContent
    const text = `Contrast Ratio: ${ratio}\nAA Normal: ${aa}\nAAA Normal: ${aaa}`
    navigator.clipboard.writeText(text)
  }
}
