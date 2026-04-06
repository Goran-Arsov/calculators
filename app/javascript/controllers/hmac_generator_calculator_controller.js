import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "message", "secretKey", "algorithm",
    "resultHmac", "resultAlgorithm", "resultMessageLength", "resultKeyLength", "resultHmacLength"
  ]

  async calculate() {
    const message = this.messageTarget.value
    const secretKey = this.secretKeyTarget.value
    const algorithm = this.algorithmTarget.value

    if (!message || !message.trim() || !secretKey || !secretKey.trim()) {
      this.clearResults()
      return
    }

    const hmac = await this.computeHmac(message, secretKey, algorithm)

    this.resultHmacTarget.value = hmac
    this.resultAlgorithmTarget.textContent = "HMAC-" + algorithm.toUpperCase()
    this.resultMessageLengthTarget.textContent = message.length.toLocaleString()
    this.resultKeyLengthTarget.textContent = secretKey.length.toLocaleString()
    this.resultHmacLengthTarget.textContent = hmac.length + " chars"
  }

  async computeHmac(message, key, algorithm) {
    const algoMap = {
      "sha256": "SHA-256",
      "sha384": "SHA-384",
      "sha512": "SHA-512"
    }

    const encoder = new TextEncoder()
    const keyData = encoder.encode(key)
    const msgData = encoder.encode(message)

    const cryptoKey = await crypto.subtle.importKey(
      "raw",
      keyData,
      { name: "HMAC", hash: { name: algoMap[algorithm] } },
      false,
      ["sign"]
    )

    const signature = await crypto.subtle.sign("HMAC", cryptoKey, msgData)
    const hashArray = Array.from(new Uint8Array(signature))
    return hashArray.map(b => b.toString(16).padStart(2, "0")).join("")
  }

  clearResults() {
    this.resultHmacTarget.value = ""
    this.resultAlgorithmTarget.textContent = "\u2014"
    this.resultMessageLengthTarget.textContent = "\u2014"
    this.resultKeyLengthTarget.textContent = "\u2014"
    this.resultHmacLengthTarget.textContent = "\u2014"
  }

  copy() {
    const text = this.resultHmacTarget.value
    if (!text) return

    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copy']")
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
  }
}
