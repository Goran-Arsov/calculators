import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "headerJson", "payloadJson", "secretKey",
    "resultToken", "resultHeader", "resultPayload", "resultValid",
    "resultsContainer"
  ]

  async calculate() {
    const headerJson = this.headerJsonTarget.value.trim()
    const payloadJson = this.payloadJsonTarget.value.trim()
    const secretKey = this.secretKeyTarget.value

    if (!payloadJson || !secretKey) {
      this.clearResults()
      return
    }

    const headerStr = headerJson || '{"alg":"HS256","typ":"JWT"}'

    let header, payload
    try {
      header = JSON.parse(headerStr)
    } catch (e) {
      this.showError("Invalid header JSON: " + e.message)
      return
    }

    try {
      payload = JSON.parse(payloadJson)
    } catch (e) {
      this.showError("Invalid payload JSON: " + e.message)
      return
    }

    const headerB64 = this.base64urlEncode(headerStr)
    const payloadB64 = this.base64urlEncode(payloadJson)
    const signingInput = headerB64 + "." + payloadB64

    try {
      const signatureB64 = await this.hmacSign(signingInput, secretKey)
      const jwt = signingInput + "." + signatureB64

      this.resultsContainerTarget.classList.remove("hidden")
      this.resultTokenTarget.value = jwt
      this.resultHeaderTarget.textContent = JSON.stringify(header, null, 2)
      this.resultPayloadTarget.textContent = JSON.stringify(payload, null, 2)
      this.resultValidTarget.textContent = "Yes"
      this.resultValidTarget.classList.remove("text-red-500", "dark:text-red-400")
      this.resultValidTarget.classList.add("text-green-600", "dark:text-green-400")
    } catch (e) {
      this.showError("Signing error: " + e.message)
    }
  }

  async hmacSign(data, key) {
    const encoder = new TextEncoder()
    const keyData = encoder.encode(key)
    const msgData = encoder.encode(data)

    const cryptoKey = await crypto.subtle.importKey(
      "raw",
      keyData,
      { name: "HMAC", hash: { name: "SHA-256" } },
      false,
      ["sign"]
    )

    const signature = await crypto.subtle.sign("HMAC", cryptoKey, msgData)
    return this.arrayBufferToBase64url(signature)
  }

  base64urlEncode(str) {
    const encoded = btoa(unescape(encodeURIComponent(str)))
    return encoded.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "")
  }

  arrayBufferToBase64url(buffer) {
    const bytes = new Uint8Array(buffer)
    let binary = ""
    bytes.forEach(b => { binary += String.fromCharCode(b) })
    const base64 = btoa(binary)
    return base64.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "")
  }

  showError(message) {
    this.resultsContainerTarget.classList.remove("hidden")
    this.resultTokenTarget.value = ""
    this.resultHeaderTarget.textContent = message
    this.resultPayloadTarget.textContent = ""
    this.resultValidTarget.textContent = "No"
    this.resultValidTarget.classList.remove("text-green-600", "dark:text-green-400")
    this.resultValidTarget.classList.add("text-red-500", "dark:text-red-400")
  }

  clearResults() {
    this.resultsContainerTarget.classList.add("hidden")
    this.resultTokenTarget.value = ""
    this.resultHeaderTarget.textContent = ""
    this.resultPayloadTarget.textContent = ""
    this.resultValidTarget.textContent = "\u2014"
    this.resultValidTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
  }

  copyToken() {
    const text = this.resultTokenTarget.value
    if (!text) return

    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copyToken']")
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
  }

  copyHeader() {
    navigator.clipboard.writeText(this.resultHeaderTarget.textContent)
  }

  copyPayload() {
    navigator.clipboard.writeText(this.resultPayloadTarget.textContent)
  }
}
