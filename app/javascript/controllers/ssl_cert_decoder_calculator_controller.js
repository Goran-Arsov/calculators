import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input", "resultError", "resultsContainer",
    "subjectCN", "subjectOrg", "subjectFull",
    "issuerCN", "issuerOrg", "issuerFull",
    "serialNumber", "version",
    "notBefore", "notAfter", "expiryStatus", "daysUntilExpiry",
    "signatureAlgorithm", "publicKeyAlgorithm", "publicKeySize",
    "sansList",
    "selfSigned",
    "fingerprintSha1", "fingerprintSha256"
  ]

  async calculate() {
    const pem = this.inputTarget.value.trim()
    if (!pem) {
      this.clearResults()
      return
    }

    if (!pem.includes("-----BEGIN CERTIFICATE-----")) {
      this.showError("Text does not appear to be a PEM-encoded certificate. It should start with -----BEGIN CERTIFICATE-----")
      this.hideResults()
      return
    }

    try {
      const der = this.pemToDer(pem)
      const parsed = this.parseAsn1Certificate(der)
      const fingerprints = await this.computeFingerprints(der)

      this.hideError()
      this.showResults()
      this.renderResults(parsed, fingerprints)
    } catch (e) {
      this.showError("Failed to parse certificate: " + e.message)
      this.hideResults()
    }
  }

  pemToDer(pem) {
    const lines = pem.split("\n")
    const base64 = lines
      .filter(l => !l.startsWith("-----"))
      .join("")
    const binary = atob(base64)
    const bytes = new Uint8Array(binary.length)
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i)
    }
    return bytes
  }

  parseAsn1Certificate(der) {
    const reader = { data: der, pos: 0 }

    // Certificate is a SEQUENCE
    const cert = this.readTag(reader)
    const certReader = { data: cert.value, pos: 0 }

    // TBSCertificate is a SEQUENCE
    const tbs = this.readTag(certReader)
    const tbsReader = { data: tbs.value, pos: 0 }

    // Version [0] EXPLICIT (optional, default v1)
    let version = 1
    const firstTag = this.peekTag(tbsReader)
    if (firstTag === 0xA0) {
      const versionContainer = this.readTag(tbsReader)
      const vReader = { data: versionContainer.value, pos: 0 }
      const vTag = this.readTag(vReader)
      version = vTag.value[0] + 1
    }

    // Serial number
    const serialTag = this.readTag(tbsReader)
    const serialHex = Array.from(serialTag.value).map(b => b.toString(16).padStart(2, "0").toUpperCase()).join(":")

    // Signature algorithm
    const sigAlgSeq = this.readTag(tbsReader)
    const sigAlgReader = { data: sigAlgSeq.value, pos: 0 }
    const sigAlgOid = this.readTag(sigAlgReader)
    const signatureAlgorithm = this.oidToName(this.decodeOid(sigAlgOid.value))

    // Issuer
    const issuerSeq = this.readTag(tbsReader)
    const issuer = this.parseName(issuerSeq.value)

    // Validity
    const validitySeq = this.readTag(tbsReader)
    const validityReader = { data: validitySeq.value, pos: 0 }
    const notBeforeTag = this.readTag(validityReader)
    const notAfterTag = this.readTag(validityReader)
    const notBefore = this.parseTime(notBeforeTag)
    const notAfter = this.parseTime(notAfterTag)

    // Subject
    const subjectSeq = this.readTag(tbsReader)
    const subject = this.parseName(subjectSeq.value)

    // Subject Public Key Info
    const spkiSeq = this.readTag(tbsReader)
    const spkiReader = { data: spkiSeq.value, pos: 0 }
    const pkAlgSeq = this.readTag(spkiReader)
    const pkAlgReader = { data: pkAlgSeq.value, pos: 0 }
    const pkAlgOid = this.readTag(pkAlgReader)
    const publicKeyAlgorithm = this.oidToKeyAlgName(this.decodeOid(pkAlgOid.value))
    const pkBitString = this.readTag(spkiReader)
    const publicKeySize = this.estimateKeySize(publicKeyAlgorithm, pkBitString.value)

    // Extensions (optional) - look for SANs
    let sans = []
    while (tbsReader.pos < tbsReader.data.length) {
      const tag = this.peekTag(tbsReader)
      if (tag === 0xA3) {
        const extContainer = this.readTag(tbsReader)
        sans = this.extractSans(extContainer.value)
      } else {
        this.readTag(tbsReader)
      }
    }

    // Determine expiry
    const now = new Date()
    const isExpired = notAfter < now
    const daysUntilExpiry = Math.floor((notAfter - now) / 86400000)
    const isSelfSigned = subject.full === issuer.full

    let expiryStatus = "valid"
    if (isExpired) expiryStatus = "expired"
    else if (daysUntilExpiry <= 30) expiryStatus = "expiring_soon"

    return {
      version,
      serialNumber: serialHex,
      signatureAlgorithm,
      issuer,
      subject,
      notBefore,
      notAfter,
      isExpired,
      daysUntilExpiry,
      expiryStatus,
      publicKeyAlgorithm,
      publicKeySize,
      sans,
      isSelfSigned
    }
  }

  peekTag(reader) {
    return reader.data[reader.pos]
  }

  readTag(reader) {
    const tag = reader.data[reader.pos++]
    let length = reader.data[reader.pos++]

    if (length & 0x80) {
      const numBytes = length & 0x7F
      length = 0
      for (let i = 0; i < numBytes; i++) {
        length = (length << 8) | reader.data[reader.pos++]
      }
    }

    const value = reader.data.slice(reader.pos, reader.pos + length)
    reader.pos += length

    return { tag, length, value }
  }

  parseName(data) {
    const reader = { data, pos: 0 }
    const result = { cn: "", org: "", ou: "", country: "", state: "", locality: "", parts: [] }

    while (reader.pos < data.length) {
      const set = this.readTag(reader)
      const setReader = { data: set.value, pos: 0 }
      const seq = this.readTag(setReader)
      const seqReader = { data: seq.value, pos: 0 }
      const oidTag = this.readTag(seqReader)
      const oid = this.decodeOid(oidTag.value)
      const valueTag = this.readTag(seqReader)
      const value = new TextDecoder().decode(valueTag.value)

      result.parts.push({ oid, value })

      switch (oid) {
        case "2.5.4.3": result.cn = value; break
        case "2.5.4.10": result.org = value; break
        case "2.5.4.11": result.ou = value; break
        case "2.5.4.6": result.country = value; break
        case "2.5.4.8": result.state = value; break
        case "2.5.4.7": result.locality = value; break
      }
    }

    result.full = result.parts.map(p => `${this.oidToRdnName(p.oid)}=${p.value}`).join(", ")
    return result
  }

  parseTime(tag) {
    const str = new TextDecoder().decode(tag.value)
    let year, month, day, hour, minute, second

    if (tag.tag === 0x17) {
      // UTCTime: YYMMDDHHMMSSZ
      year = parseInt(str.substring(0, 2))
      year += year >= 50 ? 1900 : 2000
      month = parseInt(str.substring(2, 4)) - 1
      day = parseInt(str.substring(4, 6))
      hour = parseInt(str.substring(6, 8))
      minute = parseInt(str.substring(8, 10))
      second = parseInt(str.substring(10, 12))
    } else {
      // GeneralizedTime: YYYYMMDDHHMMSSZ
      year = parseInt(str.substring(0, 4))
      month = parseInt(str.substring(4, 6)) - 1
      day = parseInt(str.substring(6, 8))
      hour = parseInt(str.substring(8, 10))
      minute = parseInt(str.substring(10, 12))
      second = parseInt(str.substring(12, 14))
    }

    return new Date(Date.UTC(year, month, day, hour, minute, second))
  }

  decodeOid(bytes) {
    const components = []
    components.push(Math.floor(bytes[0] / 40))
    components.push(bytes[0] % 40)

    let value = 0
    for (let i = 1; i < bytes.length; i++) {
      value = (value << 7) | (bytes[i] & 0x7F)
      if (!(bytes[i] & 0x80)) {
        components.push(value)
        value = 0
      }
    }

    return components.join(".")
  }

  oidToName(oid) {
    const map = {
      "1.2.840.113549.1.1.5": "SHA-1 with RSA",
      "1.2.840.113549.1.1.11": "SHA-256 with RSA",
      "1.2.840.113549.1.1.12": "SHA-384 with RSA",
      "1.2.840.113549.1.1.13": "SHA-512 with RSA",
      "1.2.840.10045.4.3.2": "ECDSA with SHA-256",
      "1.2.840.10045.4.3.3": "ECDSA with SHA-384",
      "1.2.840.10045.4.3.4": "ECDSA with SHA-512",
      "1.2.840.113549.1.1.10": "RSASSA-PSS",
      "1.2.840.113549.1.1.4": "MD5 with RSA"
    }
    return map[oid] || oid
  }

  oidToKeyAlgName(oid) {
    const map = {
      "1.2.840.113549.1.1.1": "RSA",
      "1.2.840.10045.2.1": "EC",
      "1.2.840.10040.4.1": "DSA",
      "1.3.101.110": "X25519",
      "1.3.101.112": "Ed25519"
    }
    return map[oid] || oid
  }

  oidToRdnName(oid) {
    const map = {
      "2.5.4.3": "CN",
      "2.5.4.6": "C",
      "2.5.4.7": "L",
      "2.5.4.8": "ST",
      "2.5.4.10": "O",
      "2.5.4.11": "OU",
      "1.2.840.113549.1.9.1": "emailAddress"
    }
    return map[oid] || oid
  }

  estimateKeySize(algorithm, bitStringValue) {
    // Skip the first byte (number of unused bits in the bit string)
    const keyBytes = bitStringValue.length - 1
    if (algorithm === "RSA") {
      // RSA public key is a SEQUENCE containing modulus and exponent
      // Key size is roughly the modulus bit length
      const keyData = bitStringValue.slice(1)
      const keyReader = { data: keyData, pos: 0 }
      try {
        const seq = this.readTag(keyReader)
        const seqReader = { data: seq.value, pos: 0 }
        const modulus = this.readTag(seqReader)
        // Modulus length in bits (subtract leading zero byte if present)
        const modulusBytes = modulus.value[0] === 0 ? modulus.value.length - 1 : modulus.value.length
        return modulusBytes * 8
      } catch {
        return keyBytes * 8
      }
    } else if (algorithm === "EC") {
      // EC key size is roughly half the uncompressed point size minus 1
      if (keyBytes === 65) return 256 // P-256
      if (keyBytes === 97) return 384 // P-384
      if (keyBytes === 133) return 521 // P-521
      return keyBytes * 4
    }
    return keyBytes * 8
  }

  extractSans(extData) {
    const reader = { data: extData, pos: 0 }
    const sans = []

    try {
      // Extensions is a SEQUENCE of SEQUENCE
      const extsSeq = this.readTag(reader)
      const extsReader = { data: extsSeq.value, pos: 0 }

      while (extsReader.pos < extsSeq.value.length) {
        const extSeq = this.readTag(extsReader)
        const extReader = { data: extSeq.value, pos: 0 }
        const oidTag = this.readTag(extReader)
        const oid = this.decodeOid(oidTag.value)

        // SAN OID: 2.5.29.17
        if (oid === "2.5.29.17") {
          // Skip critical boolean if present
          let nextTag = this.peekTag(extReader)
          if (nextTag === 0x01) {
            this.readTag(extReader) // skip boolean
          }
          // OCTET STRING containing the SAN value
          const octetString = this.readTag(extReader)
          const sanReader = { data: octetString.value, pos: 0 }
          const sanSeq = this.readTag(sanReader)
          const sanSeqReader = { data: sanSeq.value, pos: 0 }

          while (sanSeqReader.pos < sanSeq.value.length) {
            const sanEntry = this.readTag(sanSeqReader)
            // Context tag [2] = dNSName, [7] = iPAddress
            if (sanEntry.tag === 0x82) {
              sans.push(new TextDecoder().decode(sanEntry.value))
            } else if (sanEntry.tag === 0x87) {
              // IP address
              if (sanEntry.value.length === 4) {
                sans.push(Array.from(sanEntry.value).join("."))
              } else {
                sans.push(Array.from(sanEntry.value).map(b => b.toString(16).padStart(2, "0")).join(":"))
              }
            }
          }
        }
      }
    } catch {
      // Extensions parsing is best-effort
    }

    return sans
  }

  async computeFingerprints(der) {
    const sha1 = await crypto.subtle.digest("SHA-1", der)
    const sha256 = await crypto.subtle.digest("SHA-256", der)

    return {
      sha1: Array.from(new Uint8Array(sha1)).map(b => b.toString(16).padStart(2, "0").toUpperCase()).join(":"),
      sha256: Array.from(new Uint8Array(sha256)).map(b => b.toString(16).padStart(2, "0").toUpperCase()).join(":")
    }
  }

  renderResults(parsed, fingerprints) {
    // Subject
    this.subjectCNTarget.textContent = parsed.subject.cn || "(not set)"
    this.subjectOrgTarget.textContent = parsed.subject.org || "(not set)"
    this.subjectFullTarget.textContent = parsed.subject.full || "(empty)"

    // Issuer
    this.issuerCNTarget.textContent = parsed.issuer.cn || "(not set)"
    this.issuerOrgTarget.textContent = parsed.issuer.org || "(not set)"
    this.issuerFullTarget.textContent = parsed.issuer.full || "(empty)"

    // Serial & version
    this.serialNumberTarget.textContent = parsed.serialNumber
    this.versionTarget.textContent = `v${parsed.version}`

    // Validity
    this.notBeforeTarget.textContent = parsed.notBefore.toUTCString()
    this.notAfterTarget.textContent = parsed.notAfter.toUTCString()
    this.daysUntilExpiryTarget.textContent = parsed.daysUntilExpiry

    // Expiry status
    if (parsed.expiryStatus === "expired") {
      this.expiryStatusTarget.textContent = "Expired"
      this.expiryStatusTarget.className = "px-3 py-1 rounded-full text-sm font-semibold bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400"
    } else if (parsed.expiryStatus === "expiring_soon") {
      this.expiryStatusTarget.textContent = "Expiring Soon"
      this.expiryStatusTarget.className = "px-3 py-1 rounded-full text-sm font-semibold bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400"
    } else {
      this.expiryStatusTarget.textContent = "Valid"
      this.expiryStatusTarget.className = "px-3 py-1 rounded-full text-sm font-semibold bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400"
    }

    // Key info
    this.signatureAlgorithmTarget.textContent = parsed.signatureAlgorithm
    this.publicKeyAlgorithmTarget.textContent = parsed.publicKeyAlgorithm
    this.publicKeySizeTarget.textContent = `${parsed.publicKeySize} bits`

    // SANs
    if (parsed.sans.length > 0) {
      let sansHtml = ""
      parsed.sans.forEach(san => {
        sansHtml += `<span class="inline-block bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 px-2 py-0.5 rounded text-xs font-mono mr-1 mb-1">${this.escapeHtml(san)}</span>`
      })
      this.sansListTarget.innerHTML = sansHtml
    } else {
      this.sansListTarget.innerHTML = '<span class="text-sm text-gray-400">None</span>'
    }

    // Self-signed
    this.selfSignedTarget.textContent = parsed.isSelfSigned ? "Yes" : "No"
    this.selfSignedTarget.className = parsed.isSelfSigned
      ? "text-sm font-semibold text-amber-600 dark:text-amber-400"
      : "text-sm font-semibold text-green-600 dark:text-green-400"

    // Fingerprints
    this.fingerprintSha1Target.textContent = fingerprints.sha1
    this.fingerprintSha256Target.textContent = fingerprints.sha256
  }

  showError(message) {
    this.resultErrorTarget.textContent = message
    this.resultErrorTarget.classList.remove("hidden")
  }

  hideError() {
    this.resultErrorTarget.textContent = ""
    this.resultErrorTarget.classList.add("hidden")
  }

  showResults() {
    this.resultsContainerTarget.classList.remove("hidden")
  }

  hideResults() {
    this.resultsContainerTarget.classList.add("hidden")
  }

  clearResults() {
    this.hideError()
    this.hideResults()
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }

  copyField(event) {
    const text = event.currentTarget.closest("[data-copy-value]")?.dataset.copyValue ||
                 event.currentTarget.parentElement.querySelector("[data-ssl-cert-decoder-calculator-target]")?.textContent
    if (text) {
      navigator.clipboard.writeText(text)
    }
  }
}
