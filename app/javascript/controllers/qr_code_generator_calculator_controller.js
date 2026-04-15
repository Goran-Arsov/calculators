import { Controller } from "@hotwired/stimulus"
import qrcode from "qrcode-generator"

// Emit UTF-8 bytes so non-Latin-1 input (Cyrillic, Greek, CJK, emoji) round-trips
// through scanners. The library's default truncates each char to one byte.
qrcode.stringToBytes = function(s) {
  return Array.from(new TextEncoder().encode(s))
}

const MAX_PAYLOAD_LENGTH = 2048
const LOGO_FRACTION = 0.22
const CONTRAST_WARNING_THRESHOLD = 3
const STORAGE_KEY = "qr-code-generator:options"

const ACTIVE_TAB_CLASSES = ["bg-blue-600", "text-white", "hover:bg-blue-700"]
const INACTIVE_TAB_CLASSES = ["text-gray-600", "dark:text-gray-400", "hover:bg-gray-100", "dark:hover:bg-gray-800"]

export default class extends Controller {
  static targets = [
    "tabButton",
    "textSection", "wifiSection", "vcardSection", "smsSection", "geoSection",
    "textInput",
    "wifiSsid", "wifiPassword", "wifiEncryption", "wifiHidden",
    "vcardFirstName", "vcardLastName", "vcardOrg", "vcardPhone", "vcardEmail", "vcardUrl",
    "smsNumber", "smsBody",
    "geoLat", "geoLng",
    "ecLevel", "sizeInput", "sizeValue", "fgColor", "bgColor", "marginInput", "marginValue", "logoInput",
    "contrastWarning",
    "qrOutput", "downloadArea",
    "resultStatus", "resultCharCount", "resultType"
  ]

  connect() {
    this.activeFormat = "text"
    this.logoImage = null
    this.logoDataUrl = null
    this.webShareSupported = this.detectWebShare()
    this.loadPreferences()
    this.updateTabStyles()
    this.updateContrastWarning()
    this.syncRangeLabels()
  }

  selectTab(event) {
    this.activeFormat = event.currentTarget.dataset.format
    this.updateTabStyles()
    this.savePreferences()
  }

  updateTabStyles() {
    for (const btn of this.tabButtonTargets) {
      const isActive = btn.dataset.format === this.activeFormat
      btn.setAttribute("aria-selected", isActive ? "true" : "false")
      ACTIVE_TAB_CLASSES.forEach(c => btn.classList.toggle(c, isActive))
      INACTIVE_TAB_CLASSES.forEach(c => btn.classList.toggle(c, !isActive))
    }
    const sections = {
      text: this.textSectionTarget,
      wifi: this.wifiSectionTarget,
      vcard: this.vcardSectionTarget,
      sms: this.smsSectionTarget,
      geo: this.geoSectionTarget
    }
    for (const [format, el] of Object.entries(sections)) {
      el.classList.toggle("hidden", format !== this.activeFormat)
    }
  }

  optionChanged() {
    this.syncRangeLabels()
    this.updateContrastWarning()
    this.savePreferences()
    if (this.canvas) this.generate()
  }

  syncRangeLabels() {
    if (this.hasSizeValueTarget) this.sizeValueTarget.textContent = this.sizeInputTarget.value
    if (this.hasMarginValueTarget) this.marginValueTarget.textContent = this.marginInputTarget.value
  }

  updateContrastWarning() {
    const ratio = this.contrastRatio(this.fgColorTarget.value, this.bgColorTarget.value)
    this.contrastWarningTarget.classList.toggle("hidden", ratio >= CONTRAST_WARNING_THRESHOLD)
  }

  contrastRatio(hex1, hex2) {
    const lum = hex => {
      const rgb = hex.slice(1).match(/.{2}/g).map(h => parseInt(h, 16) / 255)
      const lin = rgb.map(c => c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4))
      return 0.2126 * lin[0] + 0.7152 * lin[1] + 0.0722 * lin[2]
    }
    const l1 = lum(hex1)
    const l2 = lum(hex2)
    return (Math.max(l1, l2) + 0.05) / (Math.min(l1, l2) + 0.05)
  }

  loadPreferences() {
    let prefs
    try {
      const raw = localStorage.getItem(STORAGE_KEY)
      if (!raw) return
      prefs = JSON.parse(raw)
    } catch (e) {
      return
    }
    if (!prefs || typeof prefs !== "object") return
    if (prefs.activeFormat) this.activeFormat = prefs.activeFormat
    if (prefs.ecLevel) this.ecLevelTarget.value = prefs.ecLevel
    if (prefs.size) this.sizeInputTarget.value = prefs.size
    if (prefs.fg) this.fgColorTarget.value = prefs.fg
    if (prefs.bg) this.bgColorTarget.value = prefs.bg
    if (prefs.margin !== undefined && prefs.margin !== null) this.marginInputTarget.value = prefs.margin
  }

  savePreferences() {
    try {
      const prefs = {
        activeFormat: this.activeFormat,
        ecLevel: this.ecLevelTarget.value,
        size: this.sizeInputTarget.value,
        fg: this.fgColorTarget.value,
        bg: this.bgColorTarget.value,
        margin: this.marginInputTarget.value
      }
      localStorage.setItem(STORAGE_KEY, JSON.stringify(prefs))
    } catch (e) {
      // Storage disabled or quota exceeded — non-fatal
    }
  }

  logoChanged(event) {
    const file = event.currentTarget.files && event.currentTarget.files[0]
    if (!file) {
      this.logoImage = null
      this.logoDataUrl = null
      this.ecLevelTarget.disabled = false
      if (this.canvas) this.generate()
      return
    }
    const reader = new FileReader()
    reader.onload = e => {
      const dataUrl = e.target.result
      const img = new Image()
      img.onload = () => {
        this.logoImage = img
        this.logoDataUrl = dataUrl
        this.ecLevelTarget.value = "H"
        this.ecLevelTarget.disabled = true
        if (this.canvas) this.generate()
      }
      img.src = dataUrl
    }
    reader.readAsDataURL(file)
  }

  buildPayload() {
    switch (this.activeFormat) {
      case "wifi": return this.buildWifiPayload()
      case "vcard": return this.buildVcardPayload()
      case "sms": return this.buildSmsPayload()
      case "geo": return this.buildGeoPayload()
      default: return this.buildTextPayload()
    }
  }

  buildTextPayload() {
    const t = this.textInputTarget.value
    if (!t || !t.trim()) return { error: "Text cannot be empty" }
    return { text: t, label: this.detectTextType(t.trim()) }
  }

  buildWifiPayload() {
    const ssid = this.wifiSsidTarget.value
    const pwd = this.wifiPasswordTarget.value
    const enc = this.wifiEncryptionTarget.value
    const hidden = this.wifiHiddenTarget.checked
    if (!ssid.trim()) return { error: "SSID is required" }
    const esc = s => s.replace(/([\\;,:"])/g, "\\$1")
    const passPart = enc === "nopass" ? "" : `P:${esc(pwd)};`
    const hiddenPart = hidden ? "H:true;" : ""
    return { text: `WIFI:T:${enc};S:${esc(ssid)};${passPart}${hiddenPart};`, label: "Wi-Fi" }
  }

  buildVcardPayload() {
    const first = this.vcardFirstNameTarget.value.trim()
    const last = this.vcardLastNameTarget.value.trim()
    const org = this.vcardOrgTarget.value.trim()
    const phone = this.vcardPhoneTarget.value.trim()
    const email = this.vcardEmailTarget.value.trim()
    const url = this.vcardUrlTarget.value.trim()
    if (!first && !last && !org && !phone && !email && !url) {
      return { error: "At least one contact field is required" }
    }
    const lines = ["BEGIN:VCARD", "VERSION:3.0"]
    if (first || last) {
      lines.push(`N:${last};${first};;;`)
      lines.push(`FN:${(first + " " + last).trim()}`)
    }
    if (org) lines.push(`ORG:${org}`)
    if (phone) lines.push(`TEL:${phone}`)
    if (email) lines.push(`EMAIL:${email}`)
    if (url) lines.push(`URL:${url}`)
    lines.push("END:VCARD")
    return { text: lines.join("\r\n"), label: "Contact" }
  }

  buildSmsPayload() {
    const num = this.smsNumberTarget.value.trim()
    const body = this.smsBodyTarget.value
    if (!num) return { error: "Phone number is required" }
    return { text: `SMSTO:${num}:${body}`, label: "SMS" }
  }

  buildGeoPayload() {
    const lat = this.geoLatTarget.value.trim()
    const lng = this.geoLngTarget.value.trim()
    if (!lat || !lng) return { error: "Latitude and longitude are required" }
    return { text: `geo:${lat},${lng}`, label: "Location" }
  }

  detectTextType(text) {
    if (/^https?:\/\//i.test(text)) return "URL"
    if (/^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/.test(text)) return "Email"
    if (/^\+?[\d\s\-().]{7,}$/.test(text)) return "Phone"
    return "Text"
  }

  generate() {
    const payload = this.buildPayload()
    if (payload.error) return this.showError(payload.error)
    const { text, label } = payload
    if (text.length > MAX_PAYLOAD_LENGTH) {
      return this.showError(`Data exceeds maximum length of ${MAX_PAYLOAD_LENGTH} characters`)
    }

    const ecLevel = this.logoImage ? "H" : this.ecLevelTarget.value
    const scale = parseInt(this.sizeInputTarget.value, 10)
    const border = parseInt(this.marginInputTarget.value, 10)
    const fg = this.fgColorTarget.value
    const bg = this.bgColorTarget.value

    try {
      const qr = qrcode(0, ecLevel)
      qr.addData(text)
      qr.make()

      const moduleCount = qr.getModuleCount()
      const canvasSize = (moduleCount + border * 2) * scale

      const canvas = document.createElement("canvas")
      canvas.width = canvasSize
      canvas.height = canvasSize
      canvas.className = "mx-auto rounded-lg"
      canvas.style.imageRendering = "pixelated"
      canvas.style.maxWidth = "320px"
      canvas.style.width = "100%"

      const ctx = canvas.getContext("2d")
      ctx.fillStyle = bg
      ctx.fillRect(0, 0, canvasSize, canvasSize)
      ctx.fillStyle = fg
      for (let y = 0; y < moduleCount; y++) {
        for (let x = 0; x < moduleCount; x++) {
          if (qr.isDark(y, x)) {
            ctx.fillRect((x + border) * scale, (y + border) * scale, scale, scale)
          }
        }
      }

      if (this.logoImage) {
        const logoSize = Math.round(canvasSize * LOGO_FRACTION)
        const pad = Math.max(scale, 4)
        const cx = Math.round((canvasSize - logoSize) / 2)
        const cy = Math.round((canvasSize - logoSize) / 2)
        ctx.fillStyle = bg
        ctx.fillRect(cx - pad, cy - pad, logoSize + pad * 2, logoSize + pad * 2)
        ctx.drawImage(this.logoImage, cx, cy, logoSize, logoSize)
      }

      this.qrOutputTarget.innerHTML = ""
      this.qrOutputTarget.appendChild(canvas)
      this.canvas = canvas
      this.qr = qr
      this.moduleCount = moduleCount
      this.lastBorder = border
      this.lastFg = fg
      this.lastBg = bg

      this.renderActions()

      this.resultStatusTarget.textContent = "Generated"
      this.resultStatusTarget.classList.remove("text-red-500", "dark:text-red-400")
      this.resultStatusTarget.classList.add("text-green-600", "dark:text-green-400")
      this.resultCharCountTarget.textContent = text.length.toLocaleString()
      this.resultTypeTarget.textContent = label
    } catch (e) {
      this.showError("Failed to generate QR code: " + e.message)
    }
  }

  renderActions() {
    const buttons = [
      `<button type="button" data-action="click->qr-code-generator-calculator#downloadPng"
        class="px-4 py-2 bg-green-600 text-white text-sm font-semibold rounded-xl hover:bg-green-700 transition-colors shadow-sm cursor-pointer">Download PNG</button>`,
      `<button type="button" data-action="click->qr-code-generator-calculator#downloadSvg"
        class="px-4 py-2 bg-blue-600 text-white text-sm font-semibold rounded-xl hover:bg-blue-700 transition-colors shadow-sm cursor-pointer">Download SVG</button>`,
      `<button type="button" data-action="click->qr-code-generator-calculator#copyPng"
        class="px-4 py-2 bg-gray-700 text-white text-sm font-semibold rounded-xl hover:bg-gray-800 transition-colors shadow-sm cursor-pointer">Copy Image</button>`
    ]
    if (this.webShareSupported) {
      buttons.push(
        `<button type="button" data-action="click->qr-code-generator-calculator#sharePng"
          class="px-4 py-2 bg-purple-600 text-white text-sm font-semibold rounded-xl hover:bg-purple-700 transition-colors shadow-sm cursor-pointer">Share</button>`
      )
    }
    this.downloadAreaTarget.innerHTML = `<div class="flex flex-wrap gap-2 justify-center">${buttons.join("")}</div>`
  }

  downloadPng() {
    if (!this.canvas) return
    this.canvas.toBlob(blob => {
      const url = URL.createObjectURL(blob)
      const a = document.createElement("a")
      a.href = url
      a.download = "qr-code.png"
      a.click()
      URL.revokeObjectURL(url)
    }, "image/png")
  }

  downloadSvg() {
    if (!this.qr) return
    const size = this.moduleCount
    const border = this.lastBorder
    const totalSize = size + border * 2

    let rects = ""
    for (let y = 0; y < size; y++) {
      for (let x = 0; x < size; x++) {
        if (this.qr.isDark(y, x)) {
          rects += `<rect x="${x + border}" y="${y + border}" width="1" height="1"/>`
        }
      }
    }

    let logoMarkup = ""
    if (this.logoImage && this.logoDataUrl) {
      const logoSide = totalSize * LOGO_FRACTION
      const logoX = (totalSize - logoSide) / 2
      const logoY = (totalSize - logoSide) / 2
      const pad = Math.max(0.5, logoSide * 0.06)
      const href = this.escapeXml(this.logoDataUrl)
      const bgFill = this.escapeXml(this.lastBg)
      logoMarkup =
        `<rect x="${logoX - pad}" y="${logoY - pad}" width="${logoSide + pad * 2}" height="${logoSide + pad * 2}" fill="${bgFill}"/>` +
        `<image x="${logoX}" y="${logoY}" width="${logoSide}" height="${logoSide}" href="${href}" xlink:href="${href}" preserveAspectRatio="xMidYMid meet"/>`
    }

    const svg = '<?xml version="1.0" encoding="UTF-8"?>\n' +
      `<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 ${totalSize} ${totalSize}" width="320" height="320">` +
      `<rect width="100%" height="100%" fill="${this.escapeXml(this.lastBg)}"/>` +
      `<g fill="${this.escapeXml(this.lastFg)}">${rects}</g>` +
      logoMarkup +
      '</svg>'

    const blob = new Blob([svg], { type: "image/svg+xml" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = "qr-code.svg"
    a.click()
    URL.revokeObjectURL(url)
  }

  escapeXml(s) {
    return String(s)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&apos;")
  }

  copyPng() {
    if (!this.canvas) return
    if (!navigator.clipboard || typeof window.ClipboardItem === "undefined") {
      return this.flashStatus("Clipboard not supported")
    }
    this.canvas.toBlob(async blob => {
      try {
        await navigator.clipboard.write([new ClipboardItem({ "image/png": blob })])
        this.flashStatus("Copied!")
      } catch (e) {
        this.flashStatus("Copy failed")
      }
    }, "image/png")
  }

  sharePng() {
    if (!this.canvas) return
    this.canvas.toBlob(async blob => {
      const file = new File([blob], "qr-code.png", { type: "image/png" })
      try {
        if (navigator.canShare && navigator.canShare({ files: [file] })) {
          await navigator.share({ files: [file], title: "QR Code" })
        }
      } catch (e) {
        // User cancelled or share failed — no-op
      }
    }, "image/png")
  }

  detectWebShare() {
    if (typeof navigator === "undefined" || !navigator.canShare || !navigator.share) return false
    try {
      const probe = new File([new Blob([""])], "probe.png", { type: "image/png" })
      return navigator.canShare({ files: [probe] })
    } catch {
      return false
    }
  }

  flashStatus(msg) {
    const prev = this.resultStatusTarget.textContent
    this.resultStatusTarget.textContent = msg
    setTimeout(() => { this.resultStatusTarget.textContent = prev }, 1500)
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
    this.qrOutputTarget.innerHTML = '<p class="text-gray-400 text-center py-8">Enter data and click Generate</p>'
    this.downloadAreaTarget.innerHTML = ""
    this.resultStatusTarget.textContent = "\u2014"
    this.resultStatusTarget.classList.remove("text-green-600", "dark:text-green-400", "text-red-500", "dark:text-red-400")
    this.resultCharCountTarget.textContent = "\u2014"
    this.resultTypeTarget.textContent = "\u2014"
  }
}
