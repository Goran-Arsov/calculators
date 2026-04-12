import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "numPhotos", "megapixels", "format",
    "resultPerPhoto", "resultTotalMb", "resultTotalGb", "resultTotalTb",
    "resultCards32", "resultCards64", "resultCards128", "resultFormat"
  ]

  static values = {
    mbPerMp: { type: Object, default: {
      jpeg: 0.3,
      raw: 1.2,
      tiff: 3.0,
      heif: 0.2,
      raw_jpeg: 1.5
    }}
  }

  calculate() {
    const numPhotos = parseInt(this.numPhotosTarget.value) || 0
    const megapixels = parseFloat(this.megapixelsTarget.value) || 0
    const format = this.formatTarget.value || "jpeg"

    if (numPhotos <= 0 || megapixels <= 0) {
      this.clearResults()
      return
    }

    let perPhotoMb
    if (format === "raw_jpeg") {
      perPhotoMb = megapixels * 1.2 + megapixels * 0.3
    } else {
      perPhotoMb = megapixels * (this.mbPerMpValue[format] || 0.3)
    }

    const totalMb = perPhotoMb * numPhotos
    const totalGb = totalMb / 1024
    const totalTb = totalGb / 1024

    const formatNames = { jpeg: "JPEG", raw: "RAW", tiff: "TIFF", heif: "HEIF/HEIC", raw_jpeg: "RAW + JPEG" }

    this.resultPerPhotoTarget.textContent = `${perPhotoMb.toFixed(1)} MB`
    this.resultTotalMbTarget.textContent = `${Math.round(totalMb).toLocaleString()} MB`
    this.resultTotalGbTarget.textContent = `${totalGb.toFixed(2)} GB`
    this.resultTotalTbTarget.textContent = `${totalTb.toFixed(3)} TB`
    this.resultCards32Target.textContent = Math.ceil(totalGb / 32)
    this.resultCards64Target.textContent = Math.ceil(totalGb / 64)
    this.resultCards128Target.textContent = Math.ceil(totalGb / 128)
    this.resultFormatTarget.textContent = formatNames[format] || format.toUpperCase()
  }

  clearResults() {
    this.resultPerPhotoTarget.textContent = "—"
    this.resultTotalMbTarget.textContent = "—"
    this.resultTotalGbTarget.textContent = "—"
    this.resultTotalTbTarget.textContent = "—"
    this.resultCards32Target.textContent = "—"
    this.resultCards64Target.textContent = "—"
    this.resultCards128Target.textContent = "—"
    this.resultFormatTarget.textContent = "—"
  }

  copy() {
    const text = `Photo Storage Estimate:\nPer Photo: ${this.resultPerPhotoTarget.textContent}\nTotal: ${this.resultTotalGbTarget.textContent}\nCards Needed (64GB): ${this.resultCards64Target.textContent}`
    navigator.clipboard.writeText(text)
  }
}
