import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mode", "pixelWidth", "pixelHeight", "dpi", "printWidth", "printHeight", "unit",
    "resultPrintWidth", "resultPrintHeight", "resultPixelWidth", "resultPixelHeight",
    "resultMegapixels", "resultQuality", "resultDpi",
    "pixelsToFields", "printToFields", "findDpiFields"
  ]

  connect() {
    this.updateMode()
  }

  updateMode() {
    const mode = this.modeTarget.value
    this.pixelsToFieldsTarget.classList.toggle("hidden", mode !== "pixels_to_print")
    this.printToFieldsTarget.classList.toggle("hidden", mode !== "print_to_pixels")
    this.findDpiFieldsTarget.classList.toggle("hidden", mode !== "find_dpi")
    this.calculate()
  }

  calculate() {
    const mode = this.modeTarget.value

    if (mode === "pixels_to_print") {
      this.calcPixelsToPrint()
    } else if (mode === "print_to_pixels") {
      this.calcPrintToPixels()
    } else if (mode === "find_dpi") {
      this.calcFindDpi()
    }
  }

  calcPixelsToPrint() {
    const pw = parseFloat(this.pixelWidthTarget.value) || 0
    const ph = parseFloat(this.pixelHeightTarget.value) || 0
    const dpi = parseFloat(this.dpiTarget.value) || 0

    if (pw <= 0 || ph <= 0 || dpi <= 0) { this.clearResults(); return }

    const widthIn = pw / dpi
    const heightIn = ph / dpi
    const mp = (pw * ph) / 1000000

    this.resultPrintWidthTarget.textContent = `${widthIn.toFixed(2)} in (${(widthIn * 2.54).toFixed(2)} cm)`
    this.resultPrintHeightTarget.textContent = `${heightIn.toFixed(2)} in (${(heightIn * 2.54).toFixed(2)} cm)`
    this.resultMegapixelsTarget.textContent = `${mp.toFixed(1)} MP`
    this.resultQualityTarget.textContent = this.qualityLabel(dpi)
  }

  calcPrintToPixels() {
    const pw = parseFloat(this.printWidthTarget.value) || 0
    const ph = parseFloat(this.printHeightTarget.value) || 0
    const dpi = parseFloat(this.dpiTarget.value) || 0
    const unit = this.unitTarget.value

    if (pw <= 0 || ph <= 0 || dpi <= 0) { this.clearResults(); return }

    const wIn = unit === "cm" ? pw / 2.54 : pw
    const hIn = unit === "cm" ? ph / 2.54 : ph

    const pixelsW = Math.ceil(wIn * dpi)
    const pixelsH = Math.ceil(hIn * dpi)
    const mp = (pixelsW * pixelsH) / 1000000

    this.resultPixelWidthTarget.textContent = pixelsW.toLocaleString() + " px"
    this.resultPixelHeightTarget.textContent = pixelsH.toLocaleString() + " px"
    this.resultMegapixelsTarget.textContent = `${mp.toFixed(1)} MP`
    this.resultQualityTarget.textContent = this.qualityLabel(dpi)
  }

  calcFindDpi() {
    const pw = parseFloat(this.pixelWidthTarget.value) || 0
    const ph = parseFloat(this.pixelHeightTarget.value) || 0
    const printW = parseFloat(this.printWidthTarget.value) || 0
    const printH = parseFloat(this.printHeightTarget.value) || 0
    const unit = this.unitTarget.value

    if (pw <= 0 || ph <= 0 || printW <= 0 || printH <= 0) { this.clearResults(); return }

    const wIn = unit === "cm" ? printW / 2.54 : printW
    const hIn = unit === "cm" ? printH / 2.54 : printH

    const dpiW = pw / wIn
    const dpiH = ph / hIn
    const effectiveDpi = Math.min(dpiW, dpiH)

    this.resultDpiTarget.textContent = `${Math.round(effectiveDpi)} DPI`
    this.resultQualityTarget.textContent = this.qualityLabel(effectiveDpi)
  }

  qualityLabel(dpi) {
    if (dpi >= 300) return "Excellent"
    if (dpi >= 200) return "Good"
    if (dpi >= 150) return "Acceptable"
    return "Low — may appear pixelated"
  }

  clearResults() {
    const targets = ["resultPrintWidth", "resultPrintHeight", "resultPixelWidth", "resultPixelHeight", "resultMegapixels", "resultQuality", "resultDpi"]
    targets.forEach(t => {
      if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) {
        this[`${t}Target`].textContent = "—"
      }
    })
  }

  copy() {
    const text = `Print Size/DPI Results:\nQuality: ${this.resultQualityTarget.textContent}\nMegapixels: ${this.resultMegapixelsTarget.textContent}`
    navigator.clipboard.writeText(text)
  }
}
