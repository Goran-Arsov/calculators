import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input",
    "resultBase64", "resultUrlEncoded", "resultHtmlEntities",
    "resultBase64Error", "resultUrlError", "resultHtmlError"
  ]

  encode() {
    const text = this.inputTarget.value
    if (!text) {
      this.clearResults()
      return
    }

    try {
      this.resultBase64Target.value = btoa(unescape(encodeURIComponent(text)))
      this.hideError("resultBase64Error")
    } catch (e) {
      this.resultBase64Target.value = ""
      this.showError("resultBase64Error", "Encoding error: " + e.message)
    }

    this.resultUrlEncodedTarget.value = encodeURIComponent(text)
    this.hideError("resultUrlError")

    this.resultHtmlEntitiesTarget.value = text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;")
    this.hideError("resultHtmlError")
  }

  decode() {
    const text = this.inputTarget.value
    if (!text) {
      this.clearResults()
      return
    }

    try {
      this.resultBase64Target.value = decodeURIComponent(escape(atob(text)))
      this.hideError("resultBase64Error")
    } catch (e) {
      this.resultBase64Target.value = ""
      this.showError("resultBase64Error", "Invalid Base64 input")
    }

    try {
      this.resultUrlEncodedTarget.value = decodeURIComponent(text)
      this.hideError("resultUrlError")
    } catch (e) {
      this.resultUrlEncodedTarget.value = ""
      this.showError("resultUrlError", "Invalid URL-encoded input")
    }

    const textarea = document.createElement("textarea")
    textarea.innerHTML = text
    this.resultHtmlEntitiesTarget.value = textarea.value
    this.hideError("resultHtmlError")
  }

  showError(targetName, message) {
    if (this[`has${targetName.charAt(0).toUpperCase() + targetName.slice(1)}Target`]) {
      this[`${targetName}Target`].textContent = message
      this[`${targetName}Target`].classList.remove("hidden")
    }
  }

  hideError(targetName) {
    if (this[`has${targetName.charAt(0).toUpperCase() + targetName.slice(1)}Target`]) {
      this[`${targetName}Target`].textContent = ""
      this[`${targetName}Target`].classList.add("hidden")
    }
  }

  clearResults() {
    this.resultBase64Target.value = ""
    this.resultUrlEncodedTarget.value = ""
    this.resultHtmlEntitiesTarget.value = ""
    this.hideError("resultBase64Error")
    this.hideError("resultUrlError")
    this.hideError("resultHtmlError")
  }

  copyBase64() {
    navigator.clipboard.writeText(this.resultBase64Target.value)
  }

  copyUrl() {
    navigator.clipboard.writeText(this.resultUrlEncodedTarget.value)
  }

  copyHtml() {
    navigator.clipboard.writeText(this.resultHtmlEntitiesTarget.value)
  }
}
