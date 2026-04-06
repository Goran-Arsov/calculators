import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "textInput", "qrOutput", "downloadArea",
    "resultStatus", "resultCharCount", "resultType"
  ]

  generate() {
    const text = this.textInputTarget.value
    if (!text || !text.trim()) {
      this.clearResults()
      return
    }

    if (text.length > 2048) {
      this.showError("Text exceeds maximum length of 2048 characters")
      return
    }

    const charCount = text.length
    const type = this.detectType(text.trim())

    // Generate QR code using Google Charts API
    const encoded = encodeURIComponent(text)
    const qrUrl = `https://chart.googleapis.com/chart?cht=qr&chs=300x300&chl=${encoded}&choe=UTF-8`

    this.qrOutputTarget.innerHTML = `<img src="${qrUrl}" alt="QR Code for: ${this.escapeHtml(text.substring(0, 50))}" class="mx-auto rounded-lg" width="300" height="300">`

    this.downloadAreaTarget.innerHTML = `
      <div class="flex flex-wrap gap-2 justify-center">
        <a href="${qrUrl}" download="qr-code.png" class="px-4 py-2 bg-green-600 text-white text-sm font-semibold rounded-xl hover:bg-green-700 transition-colors shadow-sm">Download PNG</a>
        <button data-action="click->qr-code-generator-calculator#copyUrl" class="px-4 py-2 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 text-sm font-semibold rounded-xl hover:bg-blue-200 dark:hover:bg-blue-900/50 transition-colors">Copy QR URL</button>
      </div>
    `

    this.resultStatusTarget.textContent = "Generated"
    this.resultStatusTarget.classList.remove("text-red-500", "dark:text-red-400")
    this.resultStatusTarget.classList.add("text-green-600", "dark:text-green-400")
    this.resultCharCountTarget.textContent = charCount.toLocaleString()
    this.resultTypeTarget.textContent = type.charAt(0).toUpperCase() + type.slice(1)
  }

  detectType(text) {
    if (/^https?:\/\//i.test(text)) return "url"
    if (/^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/.test(text)) return "email"
    if (/^\+?[\d\s\-().]{7,}$/.test(text)) return "phone"
    return "text"
  }

  copyUrl() {
    const text = this.textInputTarget.value
    if (!text) return
    const encoded = encodeURIComponent(text)
    const qrUrl = `https://chart.googleapis.com/chart?cht=qr&chs=300x300&chl=${encoded}&choe=UTF-8`

    navigator.clipboard.writeText(qrUrl).then(() => {
      const btn = this.downloadAreaTarget.querySelector("[data-action*='copyUrl']")
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
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

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
