import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "inputText", "password", "mode",
    "resultText", "resultStatus",
    "resultsContainer"
  ]

  async calculate() {
    const inputText = this.inputTextTarget.value
    const password = this.passwordTarget.value
    const mode = this.modeTarget.value

    if (!inputText || !password) {
      this.clearResults()
      return
    }

    try {
      if (mode === "encrypt") {
        const result = await this.encrypt(inputText, password)
        this.showResult(result, true, "encrypt")
      } else {
        const result = await this.decrypt(inputText, password)
        this.showResult(result, true, "decrypt")
      }
    } catch (e) {
      this.showResult(e.message || "Operation failed", false, mode)
    }
  }

  async encrypt(plaintext, password) {
    const salt = crypto.getRandomValues(new Uint8Array(16))
    const key = await this.deriveKey(password, salt)
    const iv = crypto.getRandomValues(new Uint8Array(12))
    const encoder = new TextEncoder()
    const data = encoder.encode(plaintext)

    const encrypted = await crypto.subtle.encrypt(
      { name: "AES-GCM", iv: iv, tagLength: 128 },
      key,
      data
    )

    // AES-GCM appends the tag to the ciphertext in Web Crypto
    const encryptedArray = new Uint8Array(encrypted)
    // Last 16 bytes are the auth tag
    const ciphertext = encryptedArray.slice(0, encryptedArray.length - 16)
    const tag = encryptedArray.slice(encryptedArray.length - 16)

    const combined = [
      this.arrayToBase64(salt),
      this.arrayToBase64(iv),
      this.arrayToBase64(ciphertext),
      this.arrayToBase64(tag)
    ].join(":")

    return btoa(combined)
  }

  async decrypt(encryptedB64, password) {
    let combined
    try {
      combined = atob(encryptedB64)
    } catch (e) {
      throw new Error("Invalid Base64 input")
    }

    const parts = combined.split(":")
    if (parts.length !== 4) {
      throw new Error("Invalid encrypted format: expected 4 parts")
    }

    const salt = this.base64ToArray(parts[0])
    const iv = this.base64ToArray(parts[1])
    const ciphertext = this.base64ToArray(parts[2])
    const tag = this.base64ToArray(parts[3])

    const key = await this.deriveKey(password, salt)

    // Web Crypto expects ciphertext + tag concatenated
    const combined_ct = new Uint8Array(ciphertext.length + tag.length)
    combined_ct.set(ciphertext)
    combined_ct.set(tag, ciphertext.length)

    try {
      const decrypted = await crypto.subtle.decrypt(
        { name: "AES-GCM", iv: iv, tagLength: 128 },
        key,
        combined_ct
      )

      const decoder = new TextDecoder()
      return decoder.decode(decrypted)
    } catch (e) {
      throw new Error("Decryption failed: wrong password or corrupted data")
    }
  }

  async deriveKey(password, salt) {
    const encoder = new TextEncoder()
    const passwordKey = await crypto.subtle.importKey(
      "raw",
      encoder.encode(password),
      "PBKDF2",
      false,
      ["deriveKey"]
    )

    return crypto.subtle.deriveKey(
      {
        name: "PBKDF2",
        salt: salt,
        iterations: 100000,
        hash: "SHA-256"
      },
      passwordKey,
      { name: "AES-GCM", length: 256 },
      false,
      ["encrypt", "decrypt"]
    )
  }

  arrayToBase64(array) {
    let binary = ""
    array.forEach(b => { binary += String.fromCharCode(b) })
    return btoa(binary)
  }

  base64ToArray(base64) {
    const binary = atob(base64)
    const array = new Uint8Array(binary.length)
    for (let i = 0; i < binary.length; i++) {
      array[i] = binary.charCodeAt(i)
    }
    return array
  }

  showResult(text, success, mode) {
    this.resultsContainerTarget.classList.remove("hidden")
    this.resultTextTarget.value = text
    if (success) {
      const label = mode === "encrypt" ? "Encrypted successfully" : "Decrypted successfully"
      this.resultStatusTarget.textContent = label
      this.resultStatusTarget.classList.remove("text-red-500", "dark:text-red-400")
      this.resultStatusTarget.classList.add("text-green-600", "dark:text-green-400")
    } else {
      this.resultStatusTarget.textContent = text
      this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400")
      this.resultStatusTarget.classList.add("text-red-500", "dark:text-red-400")
      this.resultTextTarget.value = ""
    }
  }

  clearResults() {
    this.resultsContainerTarget.classList.add("hidden")
    this.resultTextTarget.value = ""
    this.resultStatusTarget.textContent = "\u2014"
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
  }

  copy() {
    const text = this.resultTextTarget.value
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
