import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output", "stats", "error"]

  static spacingScale = {
    "0": "0px", "px": "1px", "0.5": "0.125rem", "1": "0.25rem",
    "1.5": "0.375rem", "2": "0.5rem", "2.5": "0.625rem", "3": "0.75rem",
    "3.5": "0.875rem", "4": "1rem", "5": "1.25rem", "6": "1.5rem",
    "7": "1.75rem", "8": "2rem", "9": "2.25rem", "10": "2.5rem",
    "11": "2.75rem", "12": "3rem", "14": "3.5rem", "16": "4rem",
    "20": "5rem", "24": "6rem", "28": "7rem", "32": "8rem",
    "36": "9rem", "40": "10rem", "44": "11rem", "48": "12rem",
    "52": "13rem", "56": "14rem", "60": "15rem", "64": "16rem",
    "72": "18rem", "80": "20rem", "96": "24rem", "auto": "auto", "full": "100%"
  }

  static staticMap = {
    "block": "display: block;", "inline-block": "display: inline-block;", "inline": "display: inline;",
    "flex": "display: flex;", "inline-flex": "display: inline-flex;", "grid": "display: grid;",
    "inline-grid": "display: inline-grid;", "hidden": "display: none;",
    "static": "position: static;", "fixed": "position: fixed;", "absolute": "position: absolute;",
    "relative": "position: relative;", "sticky": "position: sticky;",
    "flex-row": "flex-direction: row;", "flex-row-reverse": "flex-direction: row-reverse;",
    "flex-col": "flex-direction: column;", "flex-col-reverse": "flex-direction: column-reverse;",
    "flex-wrap": "flex-wrap: wrap;", "flex-nowrap": "flex-wrap: nowrap;",
    "flex-1": "flex: 1 1 0%;", "flex-auto": "flex: 1 1 auto;", "flex-initial": "flex: 0 1 auto;", "flex-none": "flex: none;",
    "justify-start": "justify-content: flex-start;", "justify-end": "justify-content: flex-end;",
    "justify-center": "justify-content: center;", "justify-between": "justify-content: space-between;",
    "justify-around": "justify-content: space-around;", "justify-evenly": "justify-content: space-evenly;",
    "items-start": "align-items: flex-start;", "items-end": "align-items: flex-end;",
    "items-center": "align-items: center;", "items-baseline": "align-items: baseline;",
    "items-stretch": "align-items: stretch;",
    "text-left": "text-align: left;", "text-center": "text-align: center;", "text-right": "text-align: right;",
    "uppercase": "text-transform: uppercase;", "lowercase": "text-transform: lowercase;",
    "capitalize": "text-transform: capitalize;", "normal-case": "text-transform: none;",
    "italic": "font-style: italic;", "not-italic": "font-style: normal;",
    "underline": "text-decoration-line: underline;", "line-through": "text-decoration-line: line-through;",
    "no-underline": "text-decoration-line: none;",
    "truncate": "overflow: hidden;\n  text-overflow: ellipsis;\n  white-space: nowrap;",
    "overflow-auto": "overflow: auto;", "overflow-hidden": "overflow: hidden;",
    "overflow-visible": "overflow: visible;", "overflow-scroll": "overflow: scroll;",
    "cursor-pointer": "cursor: pointer;", "cursor-default": "cursor: default;",
    "cursor-not-allowed": "cursor: not-allowed;",
    "transition": "transition-property: color, background-color, border-color, text-decoration-color, fill, stroke, opacity, box-shadow, transform, filter, backdrop-filter;\n  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);\n  transition-duration: 150ms;",
    "transition-all": "transition-property: all;\n  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);\n  transition-duration: 150ms;",
    "transition-none": "transition-property: none;",
    "shadow-sm": "box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);",
    "shadow": "box-shadow: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);",
    "shadow-md": "box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);",
    "shadow-lg": "box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);",
    "shadow-xl": "box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);",
    "shadow-none": "box-shadow: 0 0 #0000;",
    "pointer-events-none": "pointer-events: none;", "pointer-events-auto": "pointer-events: auto;",
    "select-none": "user-select: none;", "select-text": "user-select: text;", "select-all": "user-select: all;",
    "resize-none": "resize: none;", "resize": "resize: both;", "resize-x": "resize: horizontal;", "resize-y": "resize: vertical;",
    "appearance-none": "appearance: none;"
  }

  static fontSizes = {
    "xs": "font-size: 0.75rem;\n  line-height: 1rem;",
    "sm": "font-size: 0.875rem;\n  line-height: 1.25rem;",
    "base": "font-size: 1rem;\n  line-height: 1.5rem;",
    "lg": "font-size: 1.125rem;\n  line-height: 1.75rem;",
    "xl": "font-size: 1.25rem;\n  line-height: 1.75rem;",
    "2xl": "font-size: 1.5rem;\n  line-height: 2rem;",
    "3xl": "font-size: 1.875rem;\n  line-height: 2.25rem;",
    "4xl": "font-size: 2.25rem;\n  line-height: 2.5rem;",
    "5xl": "font-size: 3rem;\n  line-height: 1;",
    "6xl": "font-size: 3.75rem;\n  line-height: 1;",
    "7xl": "font-size: 4.5rem;\n  line-height: 1;",
    "8xl": "font-size: 6rem;\n  line-height: 1;",
    "9xl": "font-size: 8rem;\n  line-height: 1;"
  }

  static fontWeights = {
    "thin": "100", "extralight": "200", "light": "300", "normal": "400",
    "medium": "500", "semibold": "600", "bold": "700", "extrabold": "800", "black": "900"
  }

  static borderRadius = {
    "none": "0px", "sm": "0.125rem", "": "0.25rem", "md": "0.375rem",
    "lg": "0.5rem", "xl": "0.75rem", "2xl": "1rem", "3xl": "1.5rem", "full": "9999px"
  }

  convert() {
    const input = this.inputTarget.value.trim()
    if (!input) {
      this.showError("Please enter Tailwind classes to convert.")
      return
    }
    this.hideError()

    const classes = input.split(/\s+/).filter(c => c)
    let converted = 0
    let notConverted = 0
    const cssLines = []

    classes.forEach(cls => {
      const css = this.convertClass(cls)
      if (css.startsWith("/*")) {
        notConverted++
      } else {
        converted++
      }
      cssLines.push(`  ${css}`)
    })

    const output = `.element {\n${cssLines.join("\n")}\n}`
    this.outputTarget.value = output
    this.statsTarget.innerHTML = `<span class="text-green-600 dark:text-green-400">${converted} converted</span> | <span class="text-amber-600 dark:text-amber-400">${notConverted} unmapped</span>`
  }

  convertClass(cls) {
    // Static mappings
    if (this.constructor.staticMap[cls]) return this.constructor.staticMap[cls]

    // Spacing: p-, px-, py-, pt-, pr-, pb-, pl-, m-, mx-, my-, mt-, mr-, mb-, ml-
    const spacingPatterns = [
      [/^p-(.+)$/, "padding"],
      [/^px-(.+)$/, ["padding-left", "padding-right"]],
      [/^py-(.+)$/, ["padding-top", "padding-bottom"]],
      [/^pt-(.+)$/, "padding-top"], [/^pr-(.+)$/, "padding-right"],
      [/^pb-(.+)$/, "padding-bottom"], [/^pl-(.+)$/, "padding-left"],
      [/^m-(.+)$/, "margin"],
      [/^mx-(.+)$/, ["margin-left", "margin-right"]],
      [/^my-(.+)$/, ["margin-top", "margin-bottom"]],
      [/^mt-(.+)$/, "margin-top"], [/^mr-(.+)$/, "margin-right"],
      [/^mb-(.+)$/, "margin-bottom"], [/^ml-(.+)$/, "margin-left"],
      [/^gap-(.+)$/, "gap"], [/^gap-x-(.+)$/, "column-gap"], [/^gap-y-(.+)$/, "row-gap"]
    ]

    for (const [pattern, prop] of spacingPatterns) {
      const m = cls.match(pattern)
      if (m) {
        const val = this.constructor.spacingScale[m[1]]
        if (!val) break
        if (Array.isArray(prop)) return prop.map(p => `${p}: ${val};`).join("\n  ")
        return `${prop}: ${val};`
      }
    }

    // Width/Height
    const dimPatterns = [
      [/^w-(.+)$/, "width"], [/^h-(.+)$/, "height"],
      [/^min-w-(.+)$/, "min-width"], [/^min-h-(.+)$/, "min-height"],
      [/^max-w-(.+)$/, "max-width"], [/^max-h-(.+)$/, "max-height"]
    ]
    for (const [pattern, prop] of dimPatterns) {
      const m = cls.match(pattern)
      if (m) {
        const val = this.constructor.spacingScale[m[1]]
        if (val) return `${prop}: ${val};`
      }
    }

    // Font size
    const fsMatch = cls.match(/^text-(xs|sm|base|lg|xl|[2-9]xl)$/)
    if (fsMatch && this.constructor.fontSizes[fsMatch[1]]) return this.constructor.fontSizes[fsMatch[1]]

    // Font weight
    const fwMatch = cls.match(/^font-(thin|extralight|light|normal|medium|semibold|bold|extrabold|black)$/)
    if (fwMatch && this.constructor.fontWeights[fwMatch[1]]) return `font-weight: ${this.constructor.fontWeights[fwMatch[1]]};`

    // Border radius
    if (cls === "rounded") return `border-radius: 0.25rem;`
    const brMatch = cls.match(/^rounded-(none|sm|md|lg|xl|2xl|3xl|full)$/)
    if (brMatch && this.constructor.borderRadius[brMatch[1]] !== undefined) return `border-radius: ${this.constructor.borderRadius[brMatch[1]]};`

    // Border width
    if (cls === "border") return "border-width: 1px;"
    const bwMatch = cls.match(/^border-(\d+)$/)
    if (bwMatch) return `border-width: ${bwMatch[1]}px;`

    // Opacity
    const opMatch = cls.match(/^opacity-(\d+)$/)
    if (opMatch) return `opacity: ${parseInt(opMatch[1]) / 100};`

    // Z-index
    const zMatch = cls.match(/^z-(\d+|auto)$/)
    if (zMatch) return `z-index: ${zMatch[1]};`

    // Grid cols
    const gcMatch = cls.match(/^grid-cols-(\d+)$/)
    if (gcMatch) return `grid-template-columns: repeat(${gcMatch[1]}, minmax(0, 1fr));`

    const csMatch = cls.match(/^col-span-(\d+)$/)
    if (csMatch) return `grid-column: span ${csMatch[1]} / span ${csMatch[1]};`

    // Duration
    const durMatch = cls.match(/^duration-(\d+)$/)
    if (durMatch) return `transition-duration: ${durMatch[1]}ms;`

    return `/* ${cls}: not mapped */`
  }

  showError(msg) { this.errorTarget.textContent = msg; this.errorTarget.classList.remove("hidden") }
  hideError() { this.errorTarget.classList.add("hidden") }

  copy() {
    const text = this.outputTarget.value
    if (!text) return
    navigator.clipboard.writeText(text).then(() => {
      const btn = this.element.querySelector("[data-action*='copy']")
      if (btn) { const o = btn.textContent; btn.textContent = "Copied!"; setTimeout(() => { btn.textContent = o }, 1500) }
    })
  }

  clear() {
    this.inputTarget.value = ""
    this.outputTarget.value = ""
    this.statsTarget.innerHTML = ""
    this.hideError()
  }
}
