import { Controller } from "@hotwired/stimulus"
import qrcode from "qrcode-generator"

export default class extends Controller {
  static targets = [
    "textInput", "qrOutput", "downloadArea",
    "resultStatus", "resultCharCount", "resultType"
  ]

  generate() {
    var text = this.textInputTarget.value
    if (!text || !text.trim()) {
      this.clearResults()
      return
    }

    if (text.length > 500) {
      this.showError("Text exceeds maximum length of 500 characters")
      return
    }

    var charCount = text.length
    var type = this.detectType(text.trim())

    try {
      var qr = qrcode(0, "L")
      qr.addData(text)
      qr.make()

      var moduleCount = qr.getModuleCount()
      var scale = 8
      var border = 4
      var canvasSize = (moduleCount + border * 2) * scale

      var canvas = document.createElement("canvas")
      canvas.width = canvasSize
      canvas.height = canvasSize
      canvas.className = "mx-auto rounded-lg"
      canvas.style.imageRendering = "pixelated"
      canvas.style.maxWidth = "300px"
      canvas.style.width = "100%"

      var ctx = canvas.getContext("2d")
      ctx.fillStyle = "#ffffff"
      ctx.fillRect(0, 0, canvasSize, canvasSize)
      ctx.fillStyle = "#000000"

      for (var y = 0; y < moduleCount; y++) {
        for (var x = 0; x < moduleCount; x++) {
          if (qr.isDark(y, x)) {
            ctx.fillRect((x + border) * scale, (y + border) * scale, scale, scale)
          }
        }
      }

      this.qrOutputTarget.innerHTML = ""
      this.qrOutputTarget.appendChild(canvas)
      this.canvas = canvas
      this.qr = qr
      this.moduleCount = moduleCount

      this.downloadAreaTarget.innerHTML =
        '<div class="flex flex-wrap gap-2 justify-center">' +
          '<button data-action="click->qr-code-generator-calculator#downloadPng" class="px-4 py-2 bg-green-600 text-white text-sm font-semibold rounded-xl hover:bg-green-700 transition-colors shadow-sm cursor-pointer">Download PNG</button>' +
          '<button data-action="click->qr-code-generator-calculator#downloadSvg" class="px-4 py-2 bg-blue-600 text-white text-sm font-semibold rounded-xl hover:bg-blue-700 transition-colors shadow-sm cursor-pointer">Download SVG</button>' +
        '</div>'

      this.resultStatusTarget.textContent = "Generated"
      this.resultStatusTarget.classList.remove("text-red-500", "dark:text-red-400")
      this.resultStatusTarget.classList.add("text-green-600", "dark:text-green-400")
      this.resultCharCountTarget.textContent = charCount.toLocaleString()
      this.resultTypeTarget.textContent = type.charAt(0).toUpperCase() + type.slice(1)
    } catch (e) {
      this.showError("Failed to generate QR code: " + e.message)
    }
  }

  downloadPng() {
    if (!this.canvas) return
    this.canvas.toBlob(function(blob) {
      var url = URL.createObjectURL(blob)
      var a = document.createElement("a")
      a.href = url
      a.download = "qr-code.png"
      a.click()
      URL.revokeObjectURL(url)
    }, "image/png")
  }

  downloadSvg() {
    if (!this.qr) return
    var size = this.moduleCount
    var border = 4
    var totalSize = size + border * 2

    var rects = ""
    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        if (this.qr.isDark(y, x)) {
          rects += '<rect x="' + (x + border) + '" y="' + (y + border) + '" width="1" height="1"/>'
        }
      }
    }

    var svg = '<?xml version="1.0" encoding="UTF-8"?>\n' +
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ' + totalSize + ' ' + totalSize + '" width="300" height="300">' +
      '<rect width="100%" height="100%" fill="#fff"/>' +
      '<g fill="#000">' + rects + '</g></svg>'

    var blob = new Blob([svg], { type: "image/svg+xml" })
    var url = URL.createObjectURL(blob)
    var a = document.createElement("a")
    a.href = url
    a.download = "qr-code.svg"
    a.click()
    URL.revokeObjectURL(url)
  }

  detectType(text) {
    if (/^https?:\/\//i.test(text)) return "url"
    if (/^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/.test(text)) return "email"
    if (/^\+?[\d\s\-().]{7,}$/.test(text)) return "phone"
    return "text"
  }

  showError(message) {
    this.qrOutputTarget.innerHTML = ""
    this.downloadAreaTarget.innerHTML = ""
    this.resultStatusTarget.textContent = message
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400")
    this.resultStatusTarget.classList.add("text-red-500", "dark:text-red-400")
    this.resultCharCountTarget.textContent = "\u2014"
    this.resultTypeTarget.textContent = "\u2014"
  }

  clearResults() {
    this.qrOutputTarget.innerHTML = '<p class="text-gray-400 text-center py-8">Enter text or URL and click Generate</p>'
    this.downloadAreaTarget.innerHTML = ""
    this.resultStatusTarget.textContent = "\u2014"
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
    this.resultCharCountTarget.textContent = "\u2014"
    this.resultTypeTarget.textContent = "\u2014"
  }
}
