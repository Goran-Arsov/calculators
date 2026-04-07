import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "fileInput", "originalPreview", "originalInfo",
    "widthInput", "heightInput", "aspectRatioCheckbox", "qualitySlider", "qualityValue", "formatSelect",
    "resizedPreview", "resizedInfo", "downloadBtn"
  ]

  connect() {
    this.originalImage = null
    this.resizedBlob = null
  }

  loadImage(event) {
    const file = event.target.files[0]
    if (!file || !file.type.startsWith("image/")) return

    const reader = new FileReader()
    reader.onload = (e) => {
      const img = new Image()
      img.onload = () => {
        this.originalImage = img
        this.originalPreviewTarget.innerHTML = `<img src="${e.target.result}" class="max-w-full max-h-64 rounded-lg mx-auto" alt="Original">`
        this.originalInfoTarget.innerHTML = `
          <div class="grid grid-cols-3 gap-3 text-center">
            <div><span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase mb-1">Width</span><span class="text-sm font-bold text-gray-900 dark:text-white">${img.naturalWidth}px</span></div>
            <div><span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase mb-1">Height</span><span class="text-sm font-bold text-gray-900 dark:text-white">${img.naturalHeight}px</span></div>
            <div><span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase mb-1">Size</span><span class="text-sm font-bold text-gray-900 dark:text-white">${this._formatBytes(file.size)}</span></div>
          </div>`

        this.widthInputTarget.value = img.naturalWidth
        this.heightInputTarget.value = img.naturalHeight
      }
      img.src = e.target.result
    }
    reader.readAsDataURL(file)
  }

  updateWidth() {
    if (!this.aspectRatioCheckboxTarget.checked || !this.originalImage) return
    const ratio = this.originalImage.naturalHeight / this.originalImage.naturalWidth
    const w = parseInt(this.widthInputTarget.value) || 0
    this.heightInputTarget.value = Math.round(w * ratio)
  }

  updateHeight() {
    if (!this.aspectRatioCheckboxTarget.checked || !this.originalImage) return
    const ratio = this.originalImage.naturalWidth / this.originalImage.naturalHeight
    const h = parseInt(this.heightInputTarget.value) || 0
    this.widthInputTarget.value = Math.round(h * ratio)
  }

  updateQualityDisplay() {
    this.qualityValueTarget.textContent = this.qualitySliderTarget.value
  }

  resize() {
    if (!this.originalImage) {
      this.resizedInfoTarget.innerHTML = '<p class="text-red-500 text-sm">Please upload an image first.</p>'
      return
    }

    const newWidth = parseInt(this.widthInputTarget.value) || 1
    const newHeight = parseInt(this.heightInputTarget.value) || 1
    const quality = parseInt(this.qualitySliderTarget.value) / 100
    const format = this.formatSelectTarget.value

    const canvas = document.createElement("canvas")
    canvas.width = newWidth
    canvas.height = newHeight
    const ctx = canvas.getContext("2d")

    // Use high-quality resampling
    ctx.imageSmoothingEnabled = true
    ctx.imageSmoothingQuality = "high"
    ctx.drawImage(this.originalImage, 0, 0, newWidth, newHeight)

    let mimeType = "image/png"
    let ext = "png"
    if (format === "jpeg") { mimeType = "image/jpeg"; ext = "jpg" }
    if (format === "webp") { mimeType = "image/webp"; ext = "webp" }

    canvas.toBlob((blob) => {
      if (!blob) {
        this.resizedInfoTarget.innerHTML = '<p class="text-red-500 text-sm">Failed to resize. Try a different format.</p>'
        return
      }

      this.resizedBlob = blob
      this._currentExt = ext

      const url = URL.createObjectURL(blob)
      this.resizedPreviewTarget.innerHTML = `<img src="${url}" class="max-w-full max-h-64 rounded-lg mx-auto" alt="Resized">`
      this.resizedInfoTarget.innerHTML = `
        <div class="grid grid-cols-3 gap-3 text-center">
          <div><span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase mb-1">Width</span><span class="text-sm font-bold text-gray-900 dark:text-white">${newWidth}px</span></div>
          <div><span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase mb-1">Height</span><span class="text-sm font-bold text-gray-900 dark:text-white">${newHeight}px</span></div>
          <div><span class="block text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase mb-1">Size</span><span class="text-sm font-bold text-green-600 dark:text-green-400">${this._formatBytes(blob.size)}</span></div>
        </div>`

      this.downloadBtnTarget.classList.remove("hidden")
    }, mimeType, quality)
  }

  download() {
    if (!this.resizedBlob) return
    const url = URL.createObjectURL(this.resizedBlob)
    const a = document.createElement("a")
    a.href = url
    a.download = `resized-image.${this._currentExt || "png"}`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  }

  _formatBytes(bytes) {
    if (bytes === 0) return "0 B"
    const k = 1024
    const sizes = ["B", "KB", "MB", "GB"]
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + " " + sizes[i]
  }
}
