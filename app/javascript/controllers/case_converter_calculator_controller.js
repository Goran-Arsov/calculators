import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input",
    "resultUppercase", "resultLowercase", "resultTitleCase",
    "resultSentenceCase", "resultCamelCase", "resultSnakeCase", "resultKebabCase"
  ]

  calculate() {
    const text = this.inputTarget.value
    if (!text || !text.trim()) {
      this.clearResults()
      return
    }

    this.resultUppercaseTarget.textContent = text.toUpperCase()
    this.resultLowercaseTarget.textContent = text.toLowerCase()
    this.resultTitleCaseTarget.textContent = this.toTitleCase(text)
    this.resultSentenceCaseTarget.textContent = this.toSentenceCase(text)
    this.resultCamelCaseTarget.textContent = this.toCamelCase(text)
    this.resultSnakeCaseTarget.textContent = this.toSnakeCase(text)
    this.resultKebabCaseTarget.textContent = this.toKebabCase(text)
  }

  toTitleCase(text) {
    return text.replace(/\b\w/g, c => c.toUpperCase())
  }

  toSentenceCase(text) {
    return text.toLowerCase().replace(/(^|[.!?]\s+)\w/g, c => c.toUpperCase())
  }

  toCamelCase(text) {
    const words = text.trim().split(/[\s_\-]+/)
    if (words.length === 0) return ""
    return words[0].toLowerCase() + words.slice(1).map(w => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase()).join("")
  }

  toSnakeCase(text) {
    return text.trim()
      .replace(/([A-Z]+)([A-Z][a-z])/g, "$1_$2")
      .replace(/([a-z\d])([A-Z])/g, "$1_$2")
      .replace(/[\s\-]+/g, "_")
      .toLowerCase()
  }

  toKebabCase(text) {
    return text.trim()
      .replace(/([A-Z]+)([A-Z][a-z])/g, "$1-$2")
      .replace(/([a-z\d])([A-Z])/g, "$1-$2")
      .replace(/[\s_]+/g, "-")
      .toLowerCase()
  }

  clearResults() {
    const targets = [
      "resultUppercase", "resultLowercase", "resultTitleCase",
      "resultSentenceCase", "resultCamelCase", "resultSnakeCase", "resultKebabCase"
    ]
    targets.forEach(t => {
      if (this[`has${t.charAt(0).toUpperCase() + t.slice(1)}Target`]) {
        this[`${t}Target`].textContent = "\u2014"
      }
    })
  }

  copyResult(event) {
    const targetName = event.params.target
    const el = this[`${targetName}Target`]
    if (el) {
      navigator.clipboard.writeText(el.textContent)
      const btn = event.currentTarget
      const original = btn.textContent
      btn.textContent = "Copied!"
      setTimeout(() => { btn.textContent = original }, 1500)
    }
  }

  copy() {
    const text = [
      `UPPERCASE: ${this.resultUppercaseTarget.textContent}`,
      `lowercase: ${this.resultLowercaseTarget.textContent}`,
      `Title Case: ${this.resultTitleCaseTarget.textContent}`,
      `Sentence case: ${this.resultSentenceCaseTarget.textContent}`,
      `camelCase: ${this.resultCamelCaseTarget.textContent}`,
      `snake_case: ${this.resultSnakeCaseTarget.textContent}`,
      `kebab-case: ${this.resultKebabCaseTarget.textContent}`
    ].join("\n")
    navigator.clipboard.writeText(text)
  }
}
