import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "scale", "preview", "downloadLink",
    "resultWidth", "resultHeight", "resultElements", "resultSvgSize"
  ]

  convert() {
    const svg = this.inputTarget.value
    if (!svg || !svg.trim()) {
      this.clearResults()
      return
    }

    if (!svg.includes("<svg")) {
      this.previewTarget.innerHTML = '<p class="text-red-500 text-sm">Input does not appear to be valid SVG.</p>'
      this.clearStats()
      return
    }

    const scale = parseFloat(this.scaleTarget.value) || 1

    try {
      const blob = new Blob([svg], { type: "image/svg+xml;charset=utf-8" })
      const url = URL.createObjectURL(blob)
      const img = new Image()

      img.onload = () => {
        const width = Math.round(img.width * scale)
        const height = Math.round(img.height * scale)

        const canvas = document.createElement("canvas")
        canvas.width = width
        canvas.height = height
        const ctx = canvas.getContext("2d")
        ctx.drawImage(img, 0, 0, width, height)

        canvas.toBlob((pngBlob) => {
          const pngUrl = URL.createObjectURL(pngBlob)
          this.previewTarget.innerHTML = `<img src="${pngUrl}" class="max-w-full border border-gray-200 dark:border-gray-700 rounded-lg" alt="PNG Preview" />`
          this.downloadLinkTarget.href = pngUrl
          this.downloadLinkTarget.download = "converted.png"
          this.downloadLinkTarget.classList.remove("hidden")

          this.resultWidthTarget.textContent = `${width}px`
          this.resultHeightTarget.textContent = `${height}px`
          this.resultElementsTarget.textContent = (svg.match(/<[a-zA-Z]/g) || []).length
          this.resultSvgSizeTarget.textContent = this.formatBytes(new Blob([svg]).size)

          URL.revokeObjectURL(url)
        }, "image/png")
      }

      img.onerror = () => {
        this.previewTarget.innerHTML = '<p class="text-red-500 text-sm">Failed to render SVG. Check that your SVG is valid.</p>'
        this.clearStats()
        URL.revokeObjectURL(url)
      }

      img.src = url
    } catch (e) {
      this.previewTarget.innerHTML = `<p class="text-red-500 text-sm">Error: ${e.message}</p>`
      this.clearStats()
    }
  }

  formatBytes(bytes) {
    if (bytes === 0) return "0 B"
    if (bytes < 1024) return bytes + " B"
    return (bytes / 1024).toFixed(2) + " KB"
  }

  clearStats() {
    this.resultWidthTarget.textContent = "\u2014"
    this.resultHeightTarget.textContent = "\u2014"
    this.resultElementsTarget.textContent = "\u2014"
    this.resultSvgSizeTarget.textContent = "\u2014"
  }

  clearResults() {
    this.previewTarget.innerHTML = ""
    this.downloadLinkTarget.classList.add("hidden")
    this.clearStats()
  }
}
