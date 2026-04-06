import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "resultHeader", "resultPayload", "resultSignature",
    "resultAlgorithm", "resultType", "resultExpiry", "resultIssuedAt",
    "resultExpired", "resultIssuer", "resultSubject", "resultClaimCount",
    "resultsContainer"
  ]

  calculate() {
    const token = this.inputTarget.value.trim()
    if (!token) {
      this.clearResults()
      return
    }

    const parts = token.split(".")
    if (parts.length !== 3) {
      this.showError("Invalid JWT format: expected 3 parts separated by dots, got " + parts.length)
      return
    }

    let header, payload
    try {
      header = this.decodeSegment(parts[0])
    } catch (e) {
      this.showError("Invalid header: " + e.message)
      return
    }

    try {
      payload = this.decodeSegment(parts[1])
    } catch (e) {
      this.showError("Invalid payload: " + e.message)
      return
    }

    const signature = parts[2]
    const now = Math.floor(Date.now() / 1000)

    this.resultsContainerTarget.classList.remove("hidden")

    this.resultHeaderTarget.textContent = JSON.stringify(header, null, 2)
    this.resultPayloadTarget.textContent = JSON.stringify(payload, null, 2)
    this.resultSignatureTarget.textContent = signature

    this.resultAlgorithmTarget.textContent = header.alg || "\u2014"
    this.resultTypeTarget.textContent = header.typ || "\u2014"

    if (payload.exp) {
      const expDate = new Date(payload.exp * 1000)
      this.resultExpiryTarget.textContent = expDate.toUTCString()
      const isExpired = now > payload.exp
      this.resultExpiredTarget.textContent = isExpired ? "Yes (expired)" : "No (valid)"
      this.resultExpiredTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
      if (isExpired) {
        this.resultExpiredTarget.classList.add("text-red-500", "dark:text-red-400")
      } else {
        this.resultExpiredTarget.classList.add("text-green-600", "dark:text-green-400")
      }
    } else {
      this.resultExpiryTarget.textContent = "No expiration set"
      this.resultExpiredTarget.textContent = "N/A"
      this.resultExpiredTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
    }

    if (payload.iat) {
      const iatDate = new Date(payload.iat * 1000)
      this.resultIssuedAtTarget.textContent = iatDate.toUTCString()
    } else {
      this.resultIssuedAtTarget.textContent = "\u2014"
    }

    this.resultIssuerTarget.textContent = payload.iss || "\u2014"
    this.resultSubjectTarget.textContent = payload.sub || "\u2014"
    this.resultClaimCountTarget.textContent = Object.keys(payload).length
  }

  decodeSegment(segment) {
    // Add padding
    let padded = segment
    while (padded.length % 4 !== 0) {
      padded += "="
    }
    // URL-safe base64 to standard
    const base64 = padded.replace(/-/g, "+").replace(/_/g, "/")
    const decoded = atob(base64)
    return JSON.parse(decoded)
  }

  showError(message) {
    this.resultsContainerTarget.classList.remove("hidden")
    this.resultHeaderTarget.textContent = message
    this.resultPayloadTarget.textContent = ""
    this.resultSignatureTarget.textContent = ""
    this.resultAlgorithmTarget.textContent = "\u2014"
    this.resultTypeTarget.textContent = "\u2014"
    this.resultExpiryTarget.textContent = "\u2014"
    this.resultIssuedAtTarget.textContent = "\u2014"
    this.resultExpiredTarget.textContent = "\u2014"
    this.resultExpiredTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
    this.resultIssuerTarget.textContent = "\u2014"
    this.resultSubjectTarget.textContent = "\u2014"
    this.resultClaimCountTarget.textContent = "\u2014"
  }

  clearResults() {
    this.resultsContainerTarget.classList.add("hidden")
    this.resultHeaderTarget.textContent = ""
    this.resultPayloadTarget.textContent = ""
    this.resultSignatureTarget.textContent = ""
    this.resultAlgorithmTarget.textContent = "\u2014"
    this.resultTypeTarget.textContent = "\u2014"
    this.resultExpiryTarget.textContent = "\u2014"
    this.resultIssuedAtTarget.textContent = "\u2014"
    this.resultExpiredTarget.textContent = "\u2014"
    this.resultExpiredTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
    this.resultIssuerTarget.textContent = "\u2014"
    this.resultSubjectTarget.textContent = "\u2014"
    this.resultClaimCountTarget.textContent = "\u2014"
  }

  copyHeader() {
    navigator.clipboard.writeText(this.resultHeaderTarget.textContent)
  }

  copyPayload() {
    navigator.clipboard.writeText(this.resultPayloadTarget.textContent)
  }

  copySignature() {
    navigator.clipboard.writeText(this.resultSignatureTarget.textContent)
  }
}
