import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output", "resultChanges", "resultInputLength", "resultOutputLength"]

  static ATTR_MAP = {
    "class": "className",
    "for": "htmlFor",
    "tabindex": "tabIndex",
    "readonly": "readOnly",
    "maxlength": "maxLength",
    "cellpadding": "cellPadding",
    "cellspacing": "cellSpacing",
    "rowspan": "rowSpan",
    "colspan": "colSpan",
    "enctype": "encType",
    "contenteditable": "contentEditable",
    "crossorigin": "crossOrigin",
    "accesskey": "accessKey",
    "autocomplete": "autoComplete",
    "autofocus": "autoFocus",
    "autoplay": "autoPlay",
    "formaction": "formAction",
    "novalidate": "noValidate",
    "spellcheck": "spellCheck",
    "srcdoc": "srcDoc",
    "srcset": "srcSet",
    "usemap": "useMap",
    "charset": "charSet",
    "datetime": "dateTime",
    "hreflang": "hrefLang",
    "http-equiv": "httpEquiv"
  }

  static VOID_ELEMENTS = ["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"]

  convert() {
    const html = this.inputTarget.value
    if (!html || !html.trim()) {
      this.clearResults()
      return
    }

    try {
      let jsx = html

      // Convert HTML comments to JSX comments
      jsx = jsx.replace(/<!--(.*?)-->/gs, "{/* $1 */}")

      // Self-close void elements
      for (const tag of this.constructor.VOID_ELEMENTS) {
        const regex = new RegExp(`<(${tag})((?:\\s[^>]*?)?)(?<!/)\\s*>`, "gi")
        jsx = jsx.replace(regex, "<$1$2 />")
      }

      // Convert attributes in tags
      jsx = jsx.replace(/<([a-zA-Z][a-zA-Z0-9]*)((?:\s+[^>]*?)?)\/?>/gs, (match, tag, attrs) => {
        if (!attrs || !attrs.trim()) return match
        let converted = this.convertAttributes(attrs)
        if (match.endsWith("/>")) return `<${tag}${converted} />`
        return `<${tag}${converted}>`
      })

      const changes = this.countChanges(html, jsx)
      this.outputTarget.value = jsx
      this.resultChangesTarget.textContent = changes
      this.resultInputLengthTarget.textContent = html.length.toLocaleString()
      this.resultOutputLengthTarget.textContent = jsx.length.toLocaleString()
    } catch (e) {
      this.outputTarget.value = "Error: " + e.message
      this.clearStats()
    }
  }

  convertAttributes(attrs) {
    let result = attrs

    // Convert mapped attributes
    for (const [html, jsx] of Object.entries(this.constructor.ATTR_MAP)) {
      const regex = new RegExp(`\\b${html.replace("-", "\\-")}(?=\\s*=|\\s*[>\\s/])`, "g")
      result = result.replace(regex, jsx)
    }

    // Convert event handlers (onclick -> onClick)
    result = result.replace(/\bon([a-z]+)(?=\s*=)/g, (_, event) => {
      return "on" + event.charAt(0).toUpperCase() + event.slice(1)
    })

    // Convert inline style strings to objects
    result = result.replace(/style\s*=\s*"([^"]*)"/g, (_, css) => {
      const props = css.split(";").map(s => s.trim()).filter(Boolean).map(prop => {
        const [key, ...rest] = prop.split(":")
        const value = rest.join(":").trim()
        const camelKey = key.trim().replace(/-([a-z])/g, (_, c) => c.toUpperCase())
        return `${camelKey}: '${value}'`
      })
      return `style={{${props.join(", ")}}}`
    })

    return result
  }

  countChanges(original, converted) {
    let changes = 0
    const diffs = ["className", "htmlFor", "{/*", "style={{"]
    for (const d of diffs) {
      const origCount = (original.match(new RegExp(d.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "g")) || []).length
      const convCount = (converted.match(new RegExp(d.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "g")) || []).length
      changes += Math.max(0, convCount - origCount)
    }
    // Count self-closed void elements
    const origSelfClose = (original.match(/\s\/>/g) || []).length
    const convSelfClose = (converted.match(/\s\/>/g) || []).length
    changes += Math.max(0, convSelfClose - origSelfClose)
    return changes
  }

  clearStats() {
    this.resultChangesTarget.textContent = "\u2014"
    this.resultInputLengthTarget.textContent = "\u2014"
    this.resultOutputLengthTarget.textContent = "\u2014"
  }

  clearResults() {
    this.outputTarget.value = ""
    this.clearStats()
  }

  copy() {
    navigator.clipboard.writeText(this.outputTarget.value)
  }
}
