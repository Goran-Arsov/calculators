import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "plainInput", "encodedOutput",
    "numericOutput", "decodedOutput",
    "entityCount"
  ]

  static namedEntities = {
    "&": "&amp;", "<": "&lt;", ">": "&gt;",
    '"': "&quot;", "'": "&apos;",
    "\u00a9": "&copy;", "\u00ae": "&reg;", "\u2122": "&trade;",
    "\u00b0": "&deg;", "\u00d7": "&times;", "\u00f7": "&divide;",
    "\u2013": "&ndash;", "\u2014": "&mdash;",
    "\u2018": "&lsquo;", "\u2019": "&rsquo;",
    "\u201c": "&ldquo;", "\u201d": "&rdquo;",
    "\u2026": "&hellip;", "\u2022": "&bull;",
    "\u20ac": "&euro;", "\u00a3": "&pound;",
    "\u00a5": "&yen;", "\u00a2": "&cent;"
  }

  static reverseEntities = {
    "&amp;": "&", "&lt;": "<", "&gt;": ">",
    "&quot;": '"', "&apos;": "'",
    "&copy;": "\u00a9", "&reg;": "\u00ae", "&trade;": "\u2122",
    "&deg;": "\u00b0", "&times;": "\u00d7", "&divide;": "\u00f7",
    "&ndash;": "\u2013", "&mdash;": "\u2014",
    "&lsquo;": "\u2018", "&rsquo;": "\u2019",
    "&ldquo;": "\u201c", "&rdquo;": "\u201d",
    "&hellip;": "\u2026", "&bull;": "\u2022",
    "&euro;": "\u20ac", "&pound;": "\u00a3",
    "&yen;": "\u00a5", "&cent;": "\u00a2",
    "&nbsp;": " ",
    "&laquo;": "\u00ab", "&raquo;": "\u00bb",
    "&frac14;": "\u00bc", "&frac12;": "\u00bd", "&frac34;": "\u00be"
  }

  encode() {
    const text = this.plainInputTarget.value
    if (!text) {
      this.encodedOutputTarget.value = ""
      this.numericOutputTarget.value = ""
      this.entityCountTarget.textContent = "0"
      return
    }

    const named = this.encodeNamed(text)
    const numeric = this.encodeNumeric(text)

    this.encodedOutputTarget.value = named
    this.numericOutputTarget.value = numeric

    const entityMatches = named.match(/&[#\w]+;/g)
    this.entityCountTarget.textContent = entityMatches ? entityMatches.length : "0"
  }

  decode() {
    const encoded = this.encodedOutputTarget.value
    if (!encoded) {
      this.decodedOutputTarget.value = ""
      return
    }

    const decoded = this.decodeEntities(encoded)
    this.decodedOutputTarget.value = decoded
    this.plainInputTarget.value = decoded
  }

  encodeNamed(text) {
    const entities = this.constructor.namedEntities
    let result = ""
    for (const char of text) {
      if (entities[char]) {
        result += entities[char]
      } else if (char.charCodeAt(0) > 127) {
        result += `&#${char.charCodeAt(0)};`
      } else {
        result += char
      }
    }
    return result
  }

  encodeNumeric(text) {
    const basicEntities = { "&": "&#38;", "<": "&#60;", ">": "&#62;", '"': "&#34;", "'": "&#39;" }
    let result = ""
    for (const char of text) {
      if (basicEntities[char]) {
        result += basicEntities[char]
      } else if (char.charCodeAt(0) > 127) {
        result += `&#${char.charCodeAt(0)};`
      } else {
        result += char
      }
    }
    return result
  }

  decodeEntities(text) {
    const reverseEntities = this.constructor.reverseEntities
    let result = text

    for (const [entity, char] of Object.entries(reverseEntities)) {
      result = result.split(entity).join(char)
    }

    result = result.replace(/&#(\d+);/g, (match, code) => {
      return String.fromCharCode(parseInt(code, 10))
    })

    result = result.replace(/&#x([0-9a-fA-F]+);/g, (match, code) => {
      return String.fromCharCode(parseInt(code, 16))
    })

    return result
  }

  copyEncoded() {
    navigator.clipboard.writeText(this.encodedOutputTarget.value)
    this.flashCopyButton(event.currentTarget)
  }

  copyNumeric() {
    navigator.clipboard.writeText(this.numericOutputTarget.value)
    this.flashCopyButton(event.currentTarget)
  }

  copyDecoded() {
    navigator.clipboard.writeText(this.decodedOutputTarget.value)
    this.flashCopyButton(event.currentTarget)
  }

  copyPlain() {
    navigator.clipboard.writeText(this.plainInputTarget.value)
    this.flashCopyButton(event.currentTarget)
  }

  flashCopyButton(btn) {
    const original = btn.textContent
    btn.textContent = "Copied!"
    setTimeout(() => { btn.textContent = original }, 1500)
  }

  clearAll() {
    this.plainInputTarget.value = ""
    this.encodedOutputTarget.value = ""
    this.numericOutputTarget.value = ""
    if (this.hasDecodedOutputTarget) this.decodedOutputTarget.value = ""
    this.entityCountTarget.textContent = "0"
  }

  copy() {
    const text = [
      `Plain: ${this.plainInputTarget.value}`,
      `Named Entities: ${this.encodedOutputTarget.value}`,
      `Numeric Entities: ${this.numericOutputTarget.value}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
