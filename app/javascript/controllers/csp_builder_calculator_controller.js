import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "defaultSrc", "scriptSrc", "styleSrc", "imgSrc", "fontSrc",
    "connectSrc", "frameSrc", "mediaSrc", "objectSrc", "baseUri",
    "formAction", "frameAncestors", "reportUri",
    "headerOutput", "directiveCount"
  ]

  static DIRECTIVES = [
    { key: "defaultSrc",     name: "default-src" },
    { key: "scriptSrc",      name: "script-src" },
    { key: "styleSrc",       name: "style-src" },
    { key: "imgSrc",         name: "img-src" },
    { key: "fontSrc",        name: "font-src" },
    { key: "connectSrc",     name: "connect-src" },
    { key: "frameSrc",       name: "frame-src" },
    { key: "mediaSrc",       name: "media-src" },
    { key: "objectSrc",      name: "object-src" },
    { key: "baseUri",        name: "base-uri" },
    { key: "formAction",     name: "form-action" },
    { key: "frameAncestors", name: "frame-ancestors" },
    { key: "reportUri",      name: "report-uri" }
  ]

  calculate() {
    const parts = []

    for (const directive of this.constructor.DIRECTIVES) {
      const targetName = `${directive.key}Target`
      if (!this[`has${directive.key.charAt(0).toUpperCase() + directive.key.slice(1)}Target`]) continue

      const target = this[targetName]
      const value = target.value.trim()
      if (value) {
        parts.push(`${directive.name} ${value}`)
      }
    }

    if (parts.length === 0) {
      this.headerOutputTarget.value = ""
      this.directiveCountTarget.textContent = "0"
      return
    }

    this.headerOutputTarget.value = parts.join("; ")
    this.directiveCountTarget.textContent = parts.length.toString()
  }

  addSource(event) {
    const source = event.currentTarget.dataset.source
    const targetKey = event.currentTarget.dataset.directive
    const targetName = `${targetKey}Target`

    if (!this[`has${targetKey.charAt(0).toUpperCase() + targetKey.slice(1)}Target`]) return

    const target = this[targetName]
    const current = target.value.trim()
    const sources = current ? current.split(/\s+/) : []

    if (!sources.includes(source)) {
      sources.push(source)
      target.value = sources.join(" ")
      this.calculate()
    }
  }

  clearDirective(event) {
    const targetKey = event.currentTarget.dataset.directive
    const targetName = `${targetKey}Target`

    if (!this[`has${targetKey.charAt(0).toUpperCase() + targetKey.slice(1)}Target`]) return

    this[targetName].value = ""
    this.calculate()
  }

  copy() {
    const text = this.headerOutputTarget.value
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

  copyMeta() {
    const header = this.headerOutputTarget.value
    if (!header) return
    const meta = `<meta http-equiv="Content-Security-Policy" content="${header.replace(/"/g, '&quot;')}">`
    navigator.clipboard.writeText(meta).then(() => {
      const btn = this.element.querySelector("[data-action*='copyMeta']")
      if (btn) {
        const original = btn.textContent
        btn.textContent = "Copied!"
        setTimeout(() => { btn.textContent = original }, 1500)
      }
    })
  }
}
